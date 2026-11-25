import { createClient } from "npm:@supabase/supabase-js@2";
import Stripe from "npm:stripe@17";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY") ?? "", { apiVersion: "2024-06-20" });
const supabase = createClient(
  Deno.env.get("SUPABASE_URL") ?? "",
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  { auth: { persistSession: false } },
);

Deno.serve(async (req) => {
  if (req.method !== "POST") return new Response("Method not allowed", { status: 405 });
  const signature = req.headers.get("stripe-signature");
  const secret = Deno.env.get("STRIPE_WEBHOOK_SECRET");
  if (!signature || !secret) return new Response("Webhook not configured", { status: 500 });
  let event: Stripe.Event;
  try {
    event = await stripe.webhooks.constructEventAsync(await req.text(), signature, secret);
  } catch (error) {
    return new Response(`Invalid signature: ${(error as Error).message}`, { status: 400 });
  }

  const { data: existing } = await supabase.from("stripe_events").select("id").eq("id", event.id).maybeSingle();
  if (existing) return new Response(JSON.stringify({ received: true, duplicate: true }), { status: 200 });

  try {
    if (event.type === "checkout.session.completed") {
      const session = event.data.object as Stripe.Checkout.Session;
      const userId = session.client_reference_id;
      if (!userId || !session.subscription || !session.customer) {
        return new Response("Checkout must include client_reference_id, customer and subscription", { status: 400 });
      }
      const sub = await stripe.subscriptions.retrieve(String(session.subscription));
      const priceId = sub.items.data[0]?.price.id ?? "";
      const starterPrice = Deno.env.get("STRIPE_STARTER_PRICE_ID");
      const growthPrice = Deno.env.get("STRIPE_GROWTH_PRICE_ID");
      const plan = priceId === growthPrice ? "growth" : priceId === starterPrice ? "starter" : null;
      if (!plan) return new Response("Unrecognized Stripe price", { status: 400 });
      const { error } = await supabase.from("subscriptions").upsert({
        user_id: userId,
        stripe_customer_id: String(session.customer),
        stripe_subscription_id: sub.id,
        plan,
        status: sub.status,
        current_period_end: new Date(sub.current_period_end * 1000).toISOString(),
        cancel_at_period_end: sub.cancel_at_period_end,
        updated_at: new Date().toISOString(),
      }, { onConflict: "stripe_subscription_id" });
      if (error) throw error;
    } else if (event.type.startsWith("customer.subscription.")) {
      const sub = event.data.object as Stripe.Subscription;
      const { error } = await supabase.from("subscriptions").update({
        status: sub.status,
        current_period_end: new Date(sub.current_period_end * 1000).toISOString(),
        cancel_at_period_end: sub.cancel_at_period_end,
        updated_at: new Date().toISOString(),
      }).eq("stripe_subscription_id", sub.id);
      if (error) throw error;
    } else if (event.type === "invoice.payment_failed") {
      const invoice = event.data.object as Stripe.Invoice;
      if (invoice.subscription) {
        const { error } = await supabase.from("subscriptions").update({ status: "past_due", updated_at: new Date().toISOString() })
          .eq("stripe_subscription_id", String(invoice.subscription));
        if (error) throw error;
      }
    }
    const { error: logError } = await supabase.from("stripe_events").insert({ id: event.id, event_type: event.type });
    if (logError) throw logError;
    return new Response(JSON.stringify({ received: true }), { status: 200 });
  } catch (error) {
    console.error("Stripe webhook processing failed", error);
    return new Response("Webhook processing failed", { status: 500 });
  }
});
