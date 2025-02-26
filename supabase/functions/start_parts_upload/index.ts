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
 * Start part file upload
 */
async function b2StartPartsUpload(generate: boolean, fileName: string) {
  const accountToken = await authenticateB2(generate);
  return await fetch(`${B2_API_URL}/b2_start_large_file`, {
    method: "POST",
    headers: {
      Authorization: accountToken,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      bucketId: B2_BUCKET_ID,
      fileName: fileName,
      contentType: "application/octet-stream",
    }),
  });
}

// tries twice with old and new account auth token if necessary
async function startPartsUpload(fileName: string) {
  let response = await b2StartPartsUpload(false, fileName);
  let statusCode = response.status;
  let largeFileId = "";
  let status = 400;
  let error = "Unhandled";
  if (statusCode == 200) {
    const { fileId } = await response.json();
    largeFileId = fileId;
    status = 200;
    error = "";
  } else if (statusCode == 400) {
    const { message } = await response.json();
    status = 400;
    error = message;
  } else if (statusCode == 401) {
    response = await b2StartPartsUpload(true, fileName);
    statusCode = response.status;
    if (statusCode == 200) {
      const { fileId } = await response.json();
      largeFileId = fileId;
      status = 200;
      error = "";
    } else {
      status = statusCode;
    }
  } else {
    status = statusCode;
  }
  return { status, largeFileId, error };
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
    });
  }

  const { fileName, fileSize } = await req.json();

  if (!fileName || !fileSize) {
    return new Response(
      JSON.stringify({ error: "Missing fileName/fileSize" }),
      {
        status: 400,
      },
    );
  }
  try {
    const authorization = req.headers.get("Authorization") ?? "";

    const plan = await getUserPlanStatus(authorization, fileSize);
    if (plan.status > 200) {
      return new Response(JSON.stringify({ error: plan.error }), {
        status: plan.status,
      });
    }
    const userId = plan.userId;

    const filePath = `${userId}/${fileName}`;

    const { status, largeFileId, error } = await startPartsUpload(filePath);
    let fileId = "";
    if (status == 200) {
      fileId = largeFileId;
      //TODO save this b2_file_id against user_file_id
    }
    const downloadData = {
      fileId,
      error,
    };
    return new Response(JSON.stringify(downloadData), {
      status: status,
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error }), { status: 500 });
  }
});

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/start_parts_upload' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
