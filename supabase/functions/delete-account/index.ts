// Supabase Edge Function: delete the caller's cloud account.
//
// Flow:
//   1. Verify the caller's JWT (Authorization header) → user id.
//   2. Run public.prepare_account_deletion() *as the user* (RLS-aware): shared
//      group history is kept, ownership is handed over, profile/devices removed.
//   3. Delete the auth user with the service-role key, which only exists here
//      as a server-side secret — never in the mobile app.
//
// Deploy: supabase functions deploy delete-account
// Secrets SUPABASE_URL / SUPABASE_ANON_KEY / SUPABASE_SERVICE_ROLE_KEY are
// provided by the Supabase runtime.
import { createClient } from "jsr:@supabase/supabase-js@2";

const json = (body: Record<string, unknown>, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const authHeader = req.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ")) return json({ error: "not_authenticated" }, 401);

  const url = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!url || !anonKey || !serviceKey) return json({ error: "server_misconfigured" }, 500);

  const asUser = createClient(url, anonKey, {
    global: { headers: { Authorization: authHeader } },
    auth: { persistSession: false },
  });
  const { data: userData, error: userError } = await asUser.auth.getUser();
  if (userError || !userData?.user) return json({ error: "not_authenticated" }, 401);
  const userId = userData.user.id;

  const { error: prepareError } = await asUser.rpc("prepare_account_deletion");
  if (prepareError) {
    // Never echo database details to the client.
    console.error("prepare_account_deletion failed", prepareError.code);
    return json({ error: "prepare_failed" }, 500);
  }

  const admin = createClient(url, serviceKey, { auth: { persistSession: false } });
  const { error: deleteError } = await admin.auth.admin.deleteUser(userId);
  if (deleteError) {
    console.error("auth delete failed", deleteError.status);
    return json({ error: "delete_failed" }, 500);
  }
  return json({ ok: true });
});
