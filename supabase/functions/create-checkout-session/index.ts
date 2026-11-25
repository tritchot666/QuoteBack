import { createClient } from "npm:@supabase/supabase-js@2";
import Stripe from "npm:stripe@17";

const corsHeaders = {
  "Access-Control-Allow-Origin": "https://tritchot666.github.io",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const authHeader = req.headers.get("Authorization") ?? "";
  const token = authHeader.replace(/^Bearer\s+/i, "");
  if (!token) return json({ error: "Sign in to QuoteBack before starting checkout." }, 401);

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const stripeKey = Deno.env.get("STRIPE_SECRET_KEY");
  if (!supabaseUrl || !anonKey || !stripeKey) {
    return json({ error: "Checkout is not configured yet." }, 503);
  }

  const authClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: `Bearer ${token}` } },
    auth: { persistSession: false },
  });
  const { data: { user }, error: authError } = await authClient.auth.getUser(token);
  if (authError || !user) return json({ error: "Your session is invalid. Sign in again." }, 401);

  let body: { plan?: string };
  try {
    body = await req.json();
  } catch {
    return json({ error: "Invalid request body." }, 400);
  }
  if (body.plan !== "starter" && body.plan !== "growth") {
    return json({ error: "Choose a valid QuoteBack plan." }, 400);
  }

  const priceId = Deno.env.get(body.plan === "starter" ? "STRIPE_STARTER_PRICE_ID" : "STRIPE_GROWTH_PRICE_ID");
  if (!priceId) return json({ error: "This plan is not configured for checkout yet." }, 503);

  try {
    const stripe = new Stripe(stripeKey, { apiVersion: "2024-06-20" });
    const session = await stripe.checkout.sessions.create({
      mode: "subscription",
      client_reference_id: user.id,
      customer_email: user.email,
      line_items: [{ price: priceId, quantity: 1 }],
      success_url: "https://tritchot666.github.io/QuoteBack/app.html?checkout=success",
      cancel_url: "https://tritchot666.github.io/QuoteBack/?checkout=cancelled",
      metadata: { user_id: user.id, plan: body.plan },
      subscription_data: { metadata: { user_id: user.id, plan: body.plan } },
    });
    if (!session.url) return json({ error: "Stripe did not return a checkout URL." }, 502);
    return json({ url: session.url });
  } catch (error) {
    console.error("Stripe checkout creation failed", error);
    return json({ error: "Could not start checkout. Please try again later." }, 502);
  }
});
