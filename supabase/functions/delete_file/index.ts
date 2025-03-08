// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import {
  deleteFileEntry,
  getFile,
  getUserPlanStatus,
} from "../_shared/supabase.ts";
import { authenticateB2 } from "../_shared/backblaze.ts";

const B2_API_URL = Deno.env.get("B2_API")!;

async function b2DeleteFile(
  generate: boolean,
  fileId: string,
  fileName: string,
) {
  const accountToken = await authenticateB2(generate);
  return await fetch(`${B2_API_URL}/b2_delete_file_version`, {
    method: "POST",
    headers: {
      Authorization: accountToken,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      fileId: fileId,
      fileName: fileName,
    }),
  });
}

async function deleteFile(fileName: string, fileId: string) {
  let response = await b2DeleteFile(false, fileId, fileName);
  let statusCode = response.status;
  let callStatus = 400;
  let callError = "Unhandled";
  if (statusCode == 200) {
    callStatus = 200;
    callError = "";
  } else if (statusCode == 400) {
    const { message } = await response.json();
    callStatus = 400;
    callError = message;
  } else if (statusCode == 401) {
    response = await b2DeleteFile(false, fileId, fileName);
    statusCode = response.status;
    if (statusCode == 200) {
      callStatus = 200;
      callError = "";
    } else {
      callStatus = statusCode;
    }
  } else {
    callStatus = statusCode;
  }
  return { callStatus, callError };
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
    });
  }

  const { fileName } = await req.json();
  try {
    const authorization = req.headers.get("Authorization") ?? "";
    const plan = await getUserPlanStatus(authorization, 0);
    if (plan.status > 200) {
      return new Response(JSON.stringify({ error: plan.error }), {
        status: plan.status,
      });
    }
    const userId = plan.userId;
    const userFileId = `${userId}|${fileName}`;
    const filePath = `${userId}/${fileName}`;

    let status = 200;
    let error = "";
    const file = await getFile(userFileId);
    if (file != null) {
      const b2FileId = file.b2_id;
      if (b2FileId == null) {
        await deleteFileEntry(userFileId);
      } else {
        const { callStatus, callError } = await deleteFile(
          filePath,
          b2FileId,
        );
        if (callStatus == 200) {
          await deleteFileEntry(userFileId);
        }
        status = callStatus;
        error = callError;
      }
    }

    return new Response(
      JSON.stringify({ error: error }),
      { status: status, headers: { "Content-Type": "application/json" } },
    );
  } catch (error) {
    return new Response(JSON.stringify({ error: error }), { status: 500 });
  }
});

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/delete_file' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
