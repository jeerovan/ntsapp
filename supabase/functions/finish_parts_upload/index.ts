// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { getUserPlanStatus } from "../_shared/supabase.ts";
import { authenticateB2 } from "../_shared/backblaze.ts";

const B2_API_URL = Deno.env.get("B2_API")!;

/**
 * Finish large file upload
 */
async function b2FinishPartsUpload(
  generate: boolean,
  fileId: string,
  partSha1Array: [string],
) {
  const accountToken = await authenticateB2(generate);
  return await fetch(`${B2_API_URL}/b2_finish_large_file`, {
    method: "POST",
    headers: {
      Authorization: accountToken,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      fileId: fileId,
      partSha1Array: partSha1Array,
    }),
  });
}

// tries twice with old and new account auth token if necessary
async function finishPartsUpload(fileId: string, partSha1Array: [string]) {
  let response = await b2FinishPartsUpload(false, fileId, partSha1Array);
  let status = response.status;
  let error = "Unhandled";
  if (status == 200) {
    error = "";
  } else if (status == 400) {
    const { message } = await response.json();
    error = message;
  } else if (status == 401) {
    response = await b2FinishPartsUpload(true, fileId, partSha1Array);
    status = response.status;
  }
  return { status, error };
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "B2 Method not allowed" }), {
      status: 405,
    });
  }
  const { fileId, partSha1Array } = await req.json();
  if (!fileId || !partSha1Array) {
    return new Response(
      JSON.stringify({ error: "fileId,partSha1Array required" }),
      {
        status: 400,
      },
    );
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
    const { status, error } = await finishPartsUpload(fileId, partSha1Array);
    return new Response(JSON.stringify({ error: error }), { status: status });
  } catch (error) {
    return new Response(JSON.stringify({ error: error }), { status: 400 });
  }
});

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/finish_parts_upload' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
