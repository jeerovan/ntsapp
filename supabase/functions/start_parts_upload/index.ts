// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import {
  getUserPlanStatus,
  setB2FileId,
  setFileEntry,
} from "../_shared/supabase.ts";
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
  let b2FileId = "";
  let callStatus = 400;
  let callError = "Unhandled";
  if (statusCode == 200) {
    const { fileId } = await response.json();
    b2FileId = fileId;
    callStatus = 200;
    callError = "";
  } else if (statusCode == 400) {
    const { message } = await response.json();
    callStatus = 400;
    callError = message;
  } else if (statusCode == 401) {
    response = await b2StartPartsUpload(true, fileName);
    statusCode = response.status;
    if (statusCode == 200) {
      const { fileId } = await response.json();
      b2FileId = fileId;
      callStatus = 200;
      callError = "";
    } else {
      callStatus = statusCode;
    }
  } else {
    callStatus = statusCode;
  }
  return { callStatus, b2FileId, callError };
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
    });
  }

  const { file_name, size, key_cipher, key_nonce, parts } = await req.json();

  try {
    const authorization = req.headers.get("Authorization") ?? "";
    const plan = await getUserPlanStatus(authorization, size);
    if (plan.status > 200) {
      return new Response(JSON.stringify({ error: plan.error }), {
        status: plan.status,
      });
    }
    const userId = plan.userId;
    const userFileId = `${userId}|${file_name}`;
    const filePath = `${userId}/${file_name}`;

    const file = await setFileEntry(
      userId!,
      userFileId,
      key_cipher,
      key_nonce,
      parts,
      size,
    );

    let error = "";
    let status = 200;

    if (file.b2_id == null && file.parts > 1) {
      const { callStatus, b2FileId, callError } = await startPartsUpload(
        filePath,
      );
      if (callStatus == 200) {
        file.b2_id = b2FileId;
        await setB2FileId(userFileId, b2FileId);
      } else {
        status = callStatus;
        error = callError;
      }
    }

    const b2Data = {
      file,
      error,
    };
    return new Response(JSON.stringify(b2Data), {
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
