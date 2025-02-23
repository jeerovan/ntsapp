// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { getUserPlanStatus } from "../_shared/supabase.ts";
import { authenticateB2 } from "../_shared/backblaze.ts";

const B2_API_URL = Deno.env.get("B2_API")!;

/**
 * Get an upload URL from Backblaze B2
 * Free API: always request new token
 */
async function b2GetUploadPartUrl(generate: boolean, fileId: string) {
  const accountToken = await authenticateB2(generate);
  return await fetch(`${B2_API_URL}/b2_get_upload_part_url`, {
    method: "POST",
    headers: {
      Authorization: accountToken,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      fileId: fileId,
    }),
  });
}

// tries twice with old and new account auth token if necessary
async function getUploadPartUrl(fileId: string) {
  let response = await b2GetUploadPartUrl(false, fileId);
  let statusCode = response.status;
  let url = "";
  let token = "";
  let status = 400;
  let error = "Unhandled";
  if (statusCode == 200) {
    const { uploadUrl, authorizationToken } = await response.json();
    url = uploadUrl;
    token = authorizationToken;
    status = 200;
    error = "";
  } else if (statusCode == 400) {
    const { message } = await response.json();
    status = 400;
    error = message;
  } else if (statusCode == 401) {
    response = await b2GetUploadPartUrl(true, fileId);
    statusCode = response.status;
    if (statusCode == 200) {
      const { uploadUrl, authorizationToken } = await response.json();
      url = uploadUrl;
      token = authorizationToken;
      status = 200;
    } else {
      status = statusCode;
    }
  } else {
    status = statusCode;
  }
  return { status, url, token, error };
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "B2 Method not allowed" }), {
      status: 405,
    });
  }
  const { fileId } = await req.json();
  if (!fileId) {
    return new Response(JSON.stringify({ error: "fileId is required" }), {
      status: 400,
    });
  }
  try {
    const authorization = req.headers.get("Authorization") ?? "";

    const plan = await getUserPlanStatus(authorization, 0);
    if (plan.status > 200) {
      return new Response(JSON.stringify({ error: plan.error }), {
        status: plan.status,
      });
    }
    // in case of error, alwaya get a new upload token
    const { status, url, token, error } = await getUploadPartUrl(fileId);
    const uploadData = {
      url,
      token,
      error,
    };
    return new Response(JSON.stringify(uploadData), { status: status });
  } catch (error) {
    return new Response(JSON.stringify({ error: error }), { status: 400 });
  }
});

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/get_upload_part_url' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
