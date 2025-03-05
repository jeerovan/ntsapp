// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import {
  getFile,
  getUserPlanStatus,
  setDownloadToken,
} from "../_shared/supabase.ts";
import { authenticateB2 } from "../_shared/backblaze.ts";

const B2_BUCKET_ID = Deno.env.get("B2_BUCKET_ID")!;
const B2_BUCKET_NAME = Deno.env.get("B2_BUCKET_NAME")!;

const B2_API_URL = Deno.env.get("B2_API")!;
const B2_DOWNLOAD_URL = Deno.env.get("B2_STORAGE");
/**
 * Generate a Pre-signed Download URL
 */
async function b2GetDownloadUrl(generate: boolean, filePath: string) {
  const authorizationToken = await authenticateB2(generate);
  return await fetch(`${B2_API_URL}/b2_get_download_authorization`, {
    method: "POST",
    headers: {
      Authorization: authorizationToken,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      bucketId: B2_BUCKET_ID,
      fileNamePrefix: filePath,
      validDurationInSeconds: 604800, // one week in seconds
    }),
  });
}

async function getDownloadUrl(filePath: string) {
  let downloadUrlResponse = await b2GetDownloadUrl(false, filePath);
  let statusCode = downloadUrlResponse.status;
  let reqToken = null;
  let reqStatus = 400;
  let reqError = "Unhandled";
  if (statusCode == 200) {
    const { authorizationToken } = await downloadUrlResponse.json();
    reqToken = authorizationToken; // save token for filename
    reqStatus = 200;
    reqError = "";
  } else if (statusCode == 400) {
    const { message } = await downloadUrlResponse.json();
    reqStatus = 400;
    reqError = message;
  } else if (statusCode == 401) {
    downloadUrlResponse = await b2GetDownloadUrl(true, filePath);
    statusCode = downloadUrlResponse.status;
    if (statusCode == 200) {
      const { authorizationToken } = await downloadUrlResponse.json();
      reqToken = authorizationToken;
      reqStatus = 200;
      reqError = "";
    } else {
      reqStatus = statusCode;
    }
  } else {
    reqStatus = statusCode;
  }
  return { reqStatus, reqToken, reqError };
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
    });
  }

  const { fileName } = await req.json();

  if (!fileName) {
    return new Response(JSON.stringify({ error: "Missing fileName" }), {
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
    const userId = plan.userId;
    const userFileId = `${userId}|${fileName}`;
    const filePath = `${userId}/${fileName}`;

    const file = await getFile(
      userFileId,
    );

    let token = null;
    let status = 200;
    let error = "";
    const now = new Date().getSeconds();
    if (file != null && file.uploaded_at > 0) {
      if (
        file.token != null && file.expires > now
      ) {
        token = file.token;
      } else {
        const { reqStatus, reqToken, reqError } = await getDownloadUrl(
          filePath,
        );
        status = reqStatus;
        error = reqError;
        if (status == 200) {
          token = reqToken;
          const newExpires = now + 604700;
          await setDownloadToken(userFileId, token, newExpires);
        }
      }
    }

    let url = "";
    let key = "";
    let nonce = "";
    if (token) {
      url =
        `${B2_DOWNLOAD_URL}/file/${B2_BUCKET_NAME}/${filePath}?Authorization=${token}`;
      key = file.key_cipher;
      nonce = file.key_nonce;
    }
    const downloadData = {
      url,
      key,
      nonce,
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

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/get_download_url' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
