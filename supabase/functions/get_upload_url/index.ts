// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { authenticateB2 } from '../_common/backblaze.ts'

const B2_BUCKET_ID = Deno.env.get("B2_BUCKET_ID")!;
const B2_BUCKET_NAME = Deno.env.get("B2_BUCKET_NAME")!;

const B2_API_URL = Deno.env.get("B2_API")!;

/**
 * Get an upload URL from Backblaze B2
 */
async function getUploadUrl(filePath:string) {
  
  const authData = await authenticateB2();
  const uploadUrlResponse = await fetch(`${B2_API_URL}/b2_get_upload_url`, {
    method: "POST",
    headers: {
      Authorization: authData.authorizationToken,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ bucketId: B2_BUCKET_ID }),
  });

  if (!uploadUrlResponse.ok) {
    throw new Error("Failed to get upload URL");
  }

  const { uploadUrl, authorizationToken } = await uploadUrlResponse.json();

  return {
    uploadUrl,
    authorizationToken,
    fileName: filePath,
    contentType: "application/octet-stream",
  };
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), { status: 405 });
  }
  try {
    const { fileName } = await req.json();
    if (!fileName ) {
      return new Response(JSON.stringify({ error: "Missing fileName" }), { status: 400 });
    }
    const filePath = `${fileName}`; // ${userId}/${fileName}
    const uploadData = await getUploadUrl(filePath);
      return new Response(JSON.stringify(uploadData), { status: 200, headers: { "Content-Type": "application/json" } });
  } catch (error) {
    console.error(error);
    return new Response(JSON.stringify({ error: "Internal server error" }), { status: 500 });
  }
})

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/get_upload_url' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
