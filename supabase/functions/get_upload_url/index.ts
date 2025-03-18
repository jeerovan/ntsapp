// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { getUserPlanStatus } from "../_shared/supabase.ts";
import { authenticateB2 } from "../_shared/backblaze.ts";

const B2_BUCKET_ID = Deno.env.get("B2_BUCKET_ID")!;
const B2_API_URL = Deno.env.get("B2_API")!;

/**
 * Get an upload URL from Backblaze B2
 * Free API: can request new everytime
 */
async function b2GetUploadUrl(generate: boolean) {
  const accountToken = await authenticateB2(generate);
  return await fetch(`${B2_API_URL}/b2_get_upload_url`, {
    method: "POST",
    headers: {
      Authorization: accountToken,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ bucketId: B2_BUCKET_ID }),
  });
}

// tries twice with old and new account auth token if necessary
async function getUploadUrl() {
  let uploadUrlResponse = await b2GetUploadUrl(false);
  let statusCode = uploadUrlResponse.status;
  let url = "";
  let token = "";
  let status = 400;
  let error = "Unhandled";
  if (statusCode == 200) {
    const { uploadUrl, authorizationToken } = await uploadUrlResponse.json();
    url = uploadUrl;
    token = authorizationToken;
    status = 200;
    error = "";
  } else if (statusCode == 400) {
    const { message } = await uploadUrlResponse.json();
    status = 400;
    error = message;
  } else if (statusCode == 401) {
    uploadUrlResponse = await b2GetUploadUrl(true);
    statusCode = uploadUrlResponse.status;
    if (statusCode == 200) {
      const { uploadUrl, authorizationToken } = await uploadUrlResponse.json();
      url = uploadUrl;
      token = authorizationToken;
      status = 200;
      error = "";
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
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
    });
  }
  const { fileSize } = await req.json();
  if (!fileSize) {
    return new Response(JSON.stringify({ error: "fileSize is required" }), {
      status: 400,
    });
  }
  try {
    const authorization = req.headers.get("Authorization") ?? "";
    const deviceId = req.headers.get("deviceId") ?? "";
    const plan = await getUserPlanStatus(authorization, fileSize, deviceId);
    if (plan.status > 200) {
      return new Response(JSON.stringify({ error: plan.error }), {
        status: plan.status,
      });
    }
    // in case of error, alwaya get a new upload token
    const { status, url, token, error } = await getUploadUrl();
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

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/get_upload_url' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
