import { createClient } from "https://esm.sh/@supabase/supabase-js@2.57.0";

const PROJECT_DEFAULT = "https://zrrmqrmedgfgbejhagcc.supabase.co";
const STORAGE_KEY = "il_supabase_browser_config";
const CATEGORY_LABELS = {
  non_emergency_transport: "Accessible, non-emergency transportation",
  companionship: "Companionship",
  errands_groceries: "Errands and groceries",
  light_household_help: "Light household assistance",
  home_accessibility: "Home accessibility"
};
const STATUS_LABELS = {
  received: "Received",
  reviewing: "Under review",
  matching: "Finding suitable options",
  options_shared: "Options shared",
  booked: "Booked",
  closed: "Closed",
  cancelled: "Cancelled"
};
let supabase = null;
let currentUser = null;
let authMode = "signin";
let toastTimer;

const $ = (id) => document.getElementById(id);
const showToast = (message, error = false) => {
  const toast = $("toast");
  toast.textContent = message;
  toast.classList.toggle("error", error);
  toast.style.display = "block";
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => { toast.style.display = "none"; }, 5200);
};
const formObject = (form) => Object.fromEntries(new FormData(form).entries());
const safeText = (value) => value == null || value === "" ? "Not provided" : String(value);
const formatDate = (value) => value ? new Date(value + "T12:00:00").toLocaleDateString("en-CA", {year:"numeric",month:"short",day:"numeric"}) : "Flexible";
const isValidProjectUrl = (value) => {
  try {
    const url = new URL(value);
    return url.protocol === "https:" && url.hostname.endsWith(".supabase.co");
  } catch { return false; }
};

function setTab(tabName) {
  const tabs = [
    ["requestsTab","requestsPanel","requests"],
    ["newRequestTab","newRequestPanel","newRequest"],
    ["providerTab","providerPanel","provider"]
  ];
  for (const [tabId,panelId,key] of tabs) {
    const active = key === tabName;
    $(tabId).classList.toggle("active",active);
    $(tabId).setAttribute("aria-selected",String(active));
    $(panelId).hidden = !active;
  }
}
function setAuthMode(mode) {
  authMode = mode;
  $("authSubmit").textContent = mode === "signup" ? "Create account" : "Sign in";
  $("authModeText").textContent = mode === "signup" ? "Already have an account?" : "New here?";
  $("authModeToggle").textContent = mode === "signup" ? "Sign in" : "Create an account";
  $("password").autocomplete = mode === "signup" ? "new-password" : "current-password";
  $("authHeading").textContent = mode === "signup" ? "Create your account" : "Welcome back";
}
function showAuthenticated(user) {
  currentUser = user;
  $("authGate").hidden = true;
  $("accountArea").hidden = false;
  $("configPanel").hidden = true;
  $("signOutButton").hidden = false;
  $("signedInEmail").textContent = user.email || "Signed-in account";
  refreshAccount();
}
function showSignedOut() {
  currentUser = null;
  $("authGate").hidden = false;
  $("accountArea").hidden = true;
  $("signOutButton").hidden = true;
}
async function connectBrowser(url,key) {
  if (!isValidProjectUrl(url)) throw new Error("Enter the Independent Living Supabase project URL.");
  if (!key || !key.startsWith("sb_publishable_")) throw new Error("Use the Supabase publishable key, not a service-role or secret key.");
  supabase = createClient(url.replace(/\/$/,""),key,{
    auth:{persistSession:true,autoRefreshToken:true,detectSessionInUrl:true}
  });
  const {data,error} = await supabase.auth.getSession();
  if (error) throw error;
  localStorage.setItem(STORAGE_KEY,JSON.stringify({url:url.replace(/\/$/,""),key}));
  $("configPanel").hidden = true;
  $("authGate").hidden = false;
  if (data.session?.user) showAuthenticated(data.session.user);
  else showSignedOut();
  supabase.auth.onAuthStateChange((_event,session) => {
    window.setTimeout(() => {
      if (session?.user) showAuthenticated(session.user);
      else showSignedOut();
    },0);
  });
}

async function refreshAccount() {
  if (!supabase || !currentUser) return;
  await Promise.all([loadRequests(),loadProviderProfile()]);
}
async function loadRequests() {
  const target = $("requestList");
  target.replaceChildren();
  const {data,error} = await supabase.from("il_service_requests")
    .select("id,category,city,service_area,status,preferred_date,preferred_time_window,created_at")
    .eq("requester_user_id",currentUser.id).order("created_at",{ascending:false}).limit(50);
  if (error) {
    target.textContent = "Your requests could not be loaded. " + error.message;
    return;
  }
  if (!data?.length) {
    const p=document.createElement("p");p.className="muted";p.textContent="You have not submitted a request yet. Choose “Request support” when you are ready.";target.append(p);return;
  }
  for (const item of data) {
    const card=document.createElement("article");card.className="request-item";
    const h=document.createElement("h4");h.textContent=CATEGORY_LABELS[item.category]||"Service request";
    const status=document.createElement("span");status.className="pill";status.textContent=STATUS_LABELS[item.status]||item.status;
    const p1=document.createElement("p");p1.textContent=[item.city,item.service_area].filter(Boolean).join(" · ");
    const p2=document.createElement("p");p2.textContent="Preferred date: "+formatDate(item.preferred_date)+(item.preferred_time_window?" · "+item.preferred_time_window:"");
    const p3=document.createElement("p");p3.textContent="Submitted "+new Date(item.created_at).toLocaleDateString("en-CA");
    card.append(h,status,p1,p2,p3);target.append(card);
  }
}
async function loadProviderProfile() {
  const {data,error}=await supabase.from("il_provider_profiles").select("*").eq("owner_user_id",currentUser.id).maybeSingle();
  if (error) { showToast("Provider information could not be loaded: "+error.message,true); return; }
  const statusBox=$("providerStatus");
  if (data) {
    statusBox.hidden=false;
    statusBox.textContent="Application status: "+data.onboarding_status.replaceAll("_"," ")+". Your services are not publicly listed. A team member must complete the required checks before approval.";
    const form=$("providerForm");
    form.elements.display_name.value=data.display_name||"";
    form.elements.business_name.value=data.business_name||"";
    form.elements.contact_email.value=data.contact_email||currentUser.email||"";
    form.elements.contact_phone.value=data.contact_phone||"";
    form.elements.service_description.value=data.service_description||"";
    const {data:services}=await supabase.from("il_provider_services").select("category").eq("provider_id",data.id);
    if (services) {
      const chosen=new Set(services.map(s=>s.category));
      for (const option of form.elements.categories.options) option.selected=chosen.has(option.value);
    }
  } else {
    statusBox.hidden=true;
    $("providerForm").elements.contact_email.value=currentUser.email||"";
  }
}
async function submitRequest(event) {
  event.preventDefault();
  const form=event.currentTarget;
  if (!form.reportValidity()) return;
  const v=formObject(form);
  if (!v.contact_email.trim() && !v.contact_phone.trim()) { showToast("Please provide an email address or phone number.",true); return; }
  if (v.preferred_contact_method==="email" && !v.contact_email.trim()) { showToast("Please provide the email address you prefer us to use.",true); return; }
  if (v.preferred_contact_method==="phone" && !v.contact_phone.trim()) { showToast("Please provide the phone number you prefer us to use.",true); return; }
  const submit=form.querySelector('button[type="submit"]');submit.disabled=true;submit.textContent="Submitting securely…";
  const {data,error}=await supabase.rpc("il_submit_service_request",{
    p_category:v.category,p_city:v.city,p_service_area:v.service_area||null,
    p_description:v.description,p_preferred_date:v.preferred_date||null,
    p_preferred_time_window:v.preferred_time_window||null,
    p_accessibility_logistics:v.accessibility_logistics||"",
    p_recipient_name:v.recipient_name||null,p_contact_name:v.contact_name,
    p_contact_email:v.contact_email||null,p_contact_phone:v.contact_phone||null,
    p_preferred_contact_method:v.preferred_contact_method
  });
  submit.disabled=false;submit.textContent="Submit service request";
  if (error) { showToast("Request not submitted: "+error.message,true); return; }
  form.reset();
  showToast("Your request was submitted. Reference: "+String(data).slice(0,8).toUpperCase());
  setTab("requests");
  await loadRequests();
}
async function submitProvider(event) {
  event.preventDefault();
  const form=event.currentTarget;
  if (!form.reportValidity()) return;
  const v=formObject(form);
  const categories=[...form.elements.categories.selectedOptions].map(o=>o.value);
  if (!categories.length) { showToast("Choose at least one service category.",true); return; }
  const button=form.querySelector('button[type="submit"]');button.disabled=true;button.textContent="Submitting application…";
  let {data:profile,error}=await supabase.from("il_provider_profiles").select("id,onboarding_status").eq("owner_user_id",currentUser.id).maybeSingle();
  if (error) { button.disabled=false;button.textContent="Submit provider application";showToast(error.message,true);return; }
  const profileData={
    display_name:v.display_name.trim(),business_name:v.business_name.trim()||null,
    contact_email:v.contact_email.trim(),contact_phone:v.contact_phone.trim()||null,
    service_description:v.service_description.trim()
  };
  if (profile) {
    const updated=await supabase.from("il_provider_profiles").update(profileData).eq("id",profile.id).select("id,onboarding_status").single();
    profile=updated.data;error=updated.error;
  } else {
    const created=await supabase.from("il_provider_profiles").insert({...profileData,owner_user_id:currentUser.id,onboarding_status:"pending"}).select("id,onboarding_status").single();
    profile=created.data;error=created.error;
  }
  if (!error && profile) {
    const {data:existing,error:serviceReadError}=await supabase.from("il_provider_services").select("category,service_area").eq("provider_id",profile.id);
    if (serviceReadError) error=serviceReadError;
    else {
      const rows=categories.filter(c=>!existing.some(s=>s.category===c&&s.service_area.toLowerCase()===v.service_area.trim().toLowerCase()))
        .map(category=>({provider_id:profile.id,category,service_area:v.service_area.trim(),active:false}));
      if (rows.length) {
        const inserted=await supabase.from("il_provider_services").insert(rows);
        error=inserted.error;
      }
    }
  }
  button.disabled=false;button.textContent="Submit provider application";
  if (error) { showToast("Application could not be saved: "+error.message,true);return; }
  showToast("Provider application saved. It is pending review and is not publicly listed.");
  await loadProviderProfile();
}
function setupEvents() {
  $("configForm").addEventListener("submit",async e=>{
    e.preventDefault();
    const url=$("projectUrl").value.trim(),key=$("publishableKey").value.trim();
    try { await connectBrowser(url,key);showToast("This browser is connected to the development service."); }
    catch(err) { showToast(err.message||"Connection failed.",true); }
  });
  $("authModeToggle").addEventListener("click",()=>setAuthMode(authMode==="signup"?"signin":"signup"));
  $("authForm").addEventListener("submit",async e=>{
    e.preventDefault();const form=e.currentTarget;if(!form.reportValidity())return;
    const email=$("email").value.trim(),password=$("password").value;
    const button=$("authSubmit");button.disabled=true;
    if(authMode==="signup") {
      const {data,error}=await supabase.auth.signUp({email,password,options:{emailRedirectTo:window.location.origin+window.location.pathname}});
      button.disabled=false;
      if(error){showToast(error.message,true);return;}
      if(data.session?.user) showAuthenticated(data.session.user);
      else showToast("Account created. Check your email to confirm the address, then return here and sign in.");
    } else {
      const {data,error}=await supabase.auth.signInWithPassword({email,password});
      button.disabled=false;
      if(error){showToast(error.message,true);return;}
      showAuthenticated(data.user);
      showToast("You are signed in.");
    }
  });
  $("signOutButton").addEventListener("click",async()=>{
    const {error}=await supabase.auth.signOut();
    if(error)showToast(error.message,true);else showToast("You have signed out.");
  });
  $("requestForm").addEventListener("submit",submitRequest);
  $("providerForm").addEventListener("submit",submitProvider);
  $("requestsTab").addEventListener("click",()=>setTab("requests"));
  $("newRequestTab").addEventListener("click",()=>setTab("newRequest"));
  $("providerTab").addEventListener("click",()=>setTab("provider"));
}
async function start() {
  setupEvents();
  $("projectUrl").value=PROJECT_DEFAULT;
  const runtimeConfig=window.IL_CONFIG;
  const saved=localStorage.getItem(STORAGE_KEY);
  if (runtimeConfig?.url && runtimeConfig?.key) {
    $("projectUrl").value=runtimeConfig.url;
    try { await connectBrowser(runtimeConfig.url,runtimeConfig.key); return; }
    catch (error) { showToast("Hosted connection failed: "+(error.message||"Configuration error"),true); }
  }
  if (!saved) { $("configPanel").hidden=false; $("authGate").hidden=true; return; }
  try {
    const config=JSON.parse(saved);
    $("projectUrl").value=config.url||PROJECT_DEFAULT;
    await connectBrowser(config.url,config.key);
  } catch (error) {
    localStorage.removeItem(STORAGE_KEY);
    $("configPanel").hidden=false;$("authGate").hidden=true;
    showToast("Please reconnect this browser: "+(error.message||"Configuration error"),true);
  }
}
start();
