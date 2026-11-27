-- Atomic authenticated request submission. Runs as caller so RLS applies.
create or replace function public.il_submit_service_request(
  p_category text, p_city text, p_service_area text, p_description text,
  p_preferred_date date, p_preferred_time_window text, p_accessibility_logistics text,
  p_recipient_name text, p_contact_name text, p_contact_email text,
  p_contact_phone text, p_preferred_contact_method text
)
returns uuid language plpgsql security invoker set search_path = public
as $$
declare v_user_id uuid := auth.uid(); v_request_id uuid;
begin
  if v_user_id is null then raise exception 'Sign in is required to submit a request'; end if;
  if p_category not in ('non_emergency_transport','companionship','errands_groceries','light_household_help','home_accessibility') then raise exception 'Choose a valid service category'; end if;
  if nullif(trim(p_city),'') is null or length(p_city)>100 then raise exception 'Enter a valid city or community'; end if;
  if nullif(trim(p_description),'') is null or length(p_description)>1200 then raise exception 'Describe the practical help needed (maximum 1,200 characters)'; end if;
  if length(coalesce(p_accessibility_logistics,''))>600 then raise exception 'Accessibility arrangements are too long'; end if;
  if length(coalesce(p_recipient_name,''))>100 or length(p_contact_name)>100 then raise exception 'Name is too long'; end if;
  if p_preferred_contact_method not in ('email','phone') then raise exception 'Choose a valid contact method'; end if;
  if p_contact_email is null and p_contact_phone is null then raise exception 'Provide an email address or phone number'; end if;
  if length(coalesce(p_contact_email,''))>254 or length(coalesce(p_contact_phone,''))>40 then raise exception 'Contact details are too long'; end if;
  insert into public.il_service_requests(requester_user_id,recipient_name,category,city,service_area,description,preferred_date,preferred_time_window,accessibility_logistics,status)
  values(v_user_id,nullif(trim(p_recipient_name),''),p_category,trim(p_city),nullif(trim(p_service_area),''),trim(p_description),p_preferred_date,nullif(trim(p_preferred_time_window),''),coalesce(trim(p_accessibility_logistics),''),'received')
  returning id into v_request_id;
  insert into public.il_request_private_contacts(request_id,contact_name,contact_email,contact_phone,preferred_contact_method)
  values(v_request_id,trim(p_contact_name),nullif(trim(p_contact_email),''),nullif(trim(p_contact_phone),''),p_preferred_contact_method);
  return v_request_id;
end; $$;
revoke all on function public.il_submit_service_request(text,text,text,text,date,text,text,text,text,text,text,text) from public, anon;
grant execute on function public.il_submit_service_request(text,text,text,text,date,text,text,text,text,text,text,text) to authenticated;
