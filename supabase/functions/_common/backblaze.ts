

const B2_KEY_ID = Deno.env.get("B2_APPLICATION_KEY_ID")!;
const B2_KEY = Deno.env.get("B2_APPLICATION_KEY")!;

const B2_API_URL = "https://api006.backblazeb2.com/b2api/v3";

/**
 * Authenticate with Backblaze B2 and get an authorization token
 */
export async function authenticateB2() {
  const authResponse = await fetch(`${B2_API_URL}/b2_authorize_account`, {
    headers: {
      Authorization: `Basic ${btoa(`${B2_KEY_ID}:${B2_KEY}`)}`,
    },
  });

  if (!authResponse.ok) {
    throw new Error("Failed to authenticate with Backblaze B2");
  }

  return await authResponse.json();
}