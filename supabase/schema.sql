-- ==============================================================================
-- DATABASE SCHEMA: APLIKASI MAGANGIN
-- PostgreSQL schema for Supabase
-- ==============================================================================

-- 1. EXTENSIONS
create extension if not exists "uuid-ossp";

-- 2. ENUMS & DOMAINS
-- Role check constraint values: 'student', 'company', 'admin'
-- Work type: 'On-site', 'Hybrid', 'Remote'
-- Internship status: 'draft', 'published', 'closed'
-- Application status: 'submitted', 'reviewing', 'interview', 'accepted', 'rejected', 'withdrawn'

-- 3. UPDATED_AT TRIGGER FUNCTION
create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- 4. TABLE: PROFILES
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  full_name text not null,
  phone text,
  role text not null check (role in ('student', 'company', 'admin')),
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger tr_profiles_updated_at
  before update on public.profiles
  for each row execute function public.handle_updated_at();

-- 5. TABLE: STUDENT_PROFILES
create table if not exists public.student_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.profiles(id) on delete cascade,
  university text,
  major text,
  semester integer check (semester >= 1 and semester <= 14),
  location text,
  bio text,
  skills text[] default '{}',
  cv_url text,
  portfolio_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger tr_student_profiles_updated_at
  before update on public.student_profiles
  for each row execute function public.handle_updated_at();

-- 6. TABLE: COMPANY_PROFILES
create table if not exists public.company_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.profiles(id) on delete cascade,
  company_name text not null,
  description text,
  industry text,
  location text,
  website text,
  logo_url text,
  phone text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger tr_company_profiles_updated_at
  before update on public.company_profiles
  for each row execute function public.handle_updated_at();

-- 7. TABLE: INTERNSHIPS
create table if not exists public.internships (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.company_profiles(id) on delete cascade,
  title text not null,
  description text not null,
  requirements text[] default '{}',
  category text not null,
  location text not null,
  work_type text not null check (work_type in ('On-site', 'Hybrid', 'Remote')),
  duration text not null,
  salary_min numeric not null default 0,
  salary_max numeric not null default 0,
  quota integer not null default 1 check (quota > 0),
  deadline timestamptz not null,
  status text not null default 'draft' check (status in ('draft', 'published', 'closed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger tr_internships_updated_at
  before update on public.internships
  for each row execute function public.handle_updated_at();

create index if not exists idx_internships_category on public.internships(category);
create index if not exists idx_internships_location on public.internships(location);
create index if not exists idx_internships_status on public.internships(status);
create index if not exists idx_internships_deadline on public.internships(deadline);

-- 8. TABLE: APPLICATIONS
create table if not exists public.applications (
  id uuid primary key default gen_random_uuid(),
  internship_id uuid not null references public.internships(id) on delete cascade,
  student_id uuid not null references public.student_profiles(id) on delete cascade,
  cv_url text not null,
  cover_letter text,
  status text not null default 'submitted' check (status in ('submitted', 'reviewing', 'interview', 'accepted', 'rejected', 'withdrawn')),
  applied_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint uq_internship_student unique (internship_id, student_id)
);

create trigger tr_applications_updated_at
  before update on public.applications
  for each row execute function public.handle_updated_at();

create index if not exists idx_applications_student on public.applications(student_id);
create index if not exists idx_applications_internship on public.applications(internship_id);
create index if not exists idx_applications_status on public.applications(status);

-- 9. TABLE: SAVED_INTERNSHIPS
create table if not exists public.saved_internships (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.student_profiles(id) on delete cascade,
  internship_id uuid not null references public.internships(id) on delete cascade,
  created_at timestamptz not null default now(),
  constraint uq_saved_internship unique (student_id, internship_id)
);

create index if not exists idx_saved_internships_student on public.saved_internships(student_id);

-- 10. TABLE: PORTFOLIOS
create table if not exists public.portfolios (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.student_profiles(id) on delete cascade,
  title text not null,
  description text,
  project_url text,
  image_url text,
  created_at timestamptz not null default now()
);

create index if not exists idx_portfolios_student on public.portfolios(student_id);

-- 11. TABLE: NOTIFICATIONS
create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  message text not null,
  type text not null,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists idx_notifications_user on public.notifications(user_id);
create index if not exists idx_notifications_is_read on public.notifications(is_read);

-- ==============================================================================
-- AUTH AUTOMATION TRIGGER (When user signs up via auth.users)
-- ==============================================================================
create or replace function public.handle_new_user()
returns trigger as $$
declare
  user_role text;
  full_name text;
begin
  user_role := coalesce(new.raw_user_meta_data->>'role', 'student');
  full_name := coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1));

  -- Insert profile
  insert into public.profiles (id, email, full_name, phone, role)
  values (
    new.id,
    new.email,
    full_name,
    new.raw_user_meta_data->>'phone',
    user_role
  );

  -- Insert role specific profile
  if user_role = 'student' then
    insert into public.student_profiles (user_id, university, major, semester)
    values (
      new.id,
      new.raw_user_meta_data->>'university',
      new.raw_user_meta_data->>'major',
      coalesce((new.raw_user_meta_data->>'semester')::integer, 1)
    );
  elsif user_role = 'company' then
    insert into public.company_profiles (user_id, company_name, phone)
    values (
      new.id,
      coalesce(new.raw_user_meta_data->>'company_name', full_name),
      new.raw_user_meta_data->>'phone'
    );
  end if;

  return new;
end;
$$ language plpgsql security definer;

-- Trigger on auth.users
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================

alter table public.profiles enable row level security;
alter table public.student_profiles enable row level security;
alter table public.company_profiles enable row level security;
alter table public.internships enable row level security;
alter table public.applications enable row level security;
alter table public.saved_internships enable row level security;
alter table public.portfolios enable row level security;
alter table public.notifications enable row level security;

-- PROFILES POLICIES
create policy "Profiles are viewable by authenticated users"
  on public.profiles for select
  to authenticated
  using (true);

create policy "Users can update their own profile"
  on public.profiles for update
  to authenticated
  using (auth.uid() = id);

-- STUDENT PROFILES POLICIES
create policy "Student profiles are viewable by authenticated users"
  on public.student_profiles for select
  to authenticated
  using (true);

create policy "Students can insert their own student profile"
  on public.student_profiles for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "Students can update their own student profile"
  on public.student_profiles for update
  to authenticated
  using (auth.uid() = user_id);

-- COMPANY PROFILES POLICIES
create policy "Company profiles are viewable by everyone"
  on public.company_profiles for select
  using (true);

create policy "Companies can insert their own company profile"
  on public.company_profiles for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "Companies can update their own company profile"
  on public.company_profiles for update
  to authenticated
  using (auth.uid() = user_id);

-- INTERNSHIPS POLICIES
create policy "Anyone can view published internships"
  on public.internships for select
  using (
    status = 'published'
    or exists (
      select 1 from public.company_profiles cp
      where cp.id = internships.company_id and cp.user_id = auth.uid()
    )
    or exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

create policy "Companies can create internships"
  on public.internships for insert
  to authenticated
  with check (
    exists (
      select 1 from public.company_profiles cp
      where cp.id = internships.company_id and cp.user_id = auth.uid()
    )
  );

create policy "Companies can update own internships"
  on public.internships for update
  to authenticated
  using (
    exists (
      select 1 from public.company_profiles cp
      where cp.id = internships.company_id and cp.user_id = auth.uid()
    )
  );

create policy "Companies can delete own internships"
  on public.internships for delete
  to authenticated
  using (
    exists (
      select 1 from public.company_profiles cp
      where cp.id = internships.company_id and cp.user_id = auth.uid()
    )
  );

-- APPLICATIONS POLICIES
create policy "Students can view their own applications"
  on public.applications for select
  to authenticated
  using (
    exists (
      select 1 from public.student_profiles sp
      where sp.id = applications.student_id and sp.user_id = auth.uid()
    )
    or exists (
      select 1 from public.internships i
      join public.company_profiles cp on cp.id = i.company_id
      where i.id = applications.internship_id and cp.user_id = auth.uid()
    )
    or exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

create policy "Students can submit applications"
  on public.applications for insert
  to authenticated
  with check (
    exists (
      select 1 from public.student_profiles sp
      where sp.id = applications.student_id and sp.user_id = auth.uid()
    )
  );

create policy "Companies can update application status or Student can withdraw"
  on public.applications for update
  to authenticated
  using (
    exists (
      select 1 from public.internships i
      join public.company_profiles cp on cp.id = i.company_id
      where i.id = applications.internship_id and cp.user_id = auth.uid()
    )
    or exists (
      select 1 from public.student_profiles sp
      where sp.id = applications.student_id and sp.user_id = auth.uid()
    )
  );

-- SAVED INTERNSHIPS POLICIES
create policy "Students can view own saved internships"
  on public.saved_internships for select
  to authenticated
  using (
    exists (
      select 1 from public.student_profiles sp
      where sp.id = saved_internships.student_id and sp.user_id = auth.uid()
    )
  );

create policy "Students can save internships"
  on public.saved_internships for insert
  to authenticated
  with check (
    exists (
      select 1 from public.student_profiles sp
      where sp.id = saved_internships.student_id and sp.user_id = auth.uid()
    )
  );

create policy "Students can remove saved internships"
  on public.saved_internships for delete
  to authenticated
  using (
    exists (
      select 1 from public.student_profiles sp
      where sp.id = saved_internships.student_id and sp.user_id = auth.uid()
    )
  );

-- PORTFOLIOS POLICIES
create policy "Portfolios viewable by authenticated users"
  on public.portfolios for select
  to authenticated
  using (true);

create policy "Students can create own portfolio"
  on public.portfolios for insert
  to authenticated
  with check (
    exists (
      select 1 from public.student_profiles sp
      where sp.id = portfolios.student_id and sp.user_id = auth.uid()
    )
  );

create policy "Students can update own portfolio"
  on public.portfolios for update
  to authenticated
  using (
    exists (
      select 1 from public.student_profiles sp
      where sp.id = portfolios.student_id and sp.user_id = auth.uid()
    )
  );

create policy "Students can delete own portfolio"
  on public.portfolios for delete
  to authenticated
  using (
    exists (
      select 1 from public.student_profiles sp
      where sp.id = portfolios.student_id and sp.user_id = auth.uid()
    )
  );

-- NOTIFICATIONS POLICIES
create policy "Users can view own notifications"
  on public.notifications for select
  to authenticated
  using (auth.uid() = user_id);

create policy "Users can update own notifications"
  on public.notifications for update
  to authenticated
  using (auth.uid() = user_id);

create policy "System or authenticated can insert notifications"
  on public.notifications for insert
  to authenticated
  with check (true);

-- ==============================================================================
-- STORAGE BUCKETS (avatars, cv, company-logos, portfolio)
-- ==============================================================================
insert into storage.buckets (id, name, public)
values 
  ('avatars', 'avatars', true),
  ('cv', 'cv', false),
  ('company-logos', 'company-logos', true),
  ('portfolio', 'portfolio', true)
on conflict (id) do update set public = excluded.public;

-- Storage Policies:
-- Avatars
create policy "Avatar images are publicly accessible"
  on storage.objects for select
  using (bucket_id = 'avatars');

create policy "Authenticated users can upload avatar"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]);

create policy "Users can update own avatar"
  on storage.objects for update
  to authenticated
  using (bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]);

-- CV
create policy "Users can view own CV and companies can view applicant CV"
  on storage.objects for select
  to authenticated
  using (
    bucket_id = 'cv' and (
      auth.uid()::text = (storage.foldername(name))[1]
      or exists (
        select 1 from public.applications a
        join public.student_profiles sp on sp.id = a.student_id
        join public.internships i on i.id = a.internship_id
        join public.company_profiles cp on cp.id = i.company_id
        where sp.user_id::text = (storage.foldername(name))[1]
        and cp.user_id = auth.uid()
      )
    )
  );

create policy "Authenticated users can upload CV"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'cv' and auth.uid()::text = (storage.foldername(name))[1]);

create policy "Users can update own CV"
  on storage.objects for update
  to authenticated
  using (bucket_id = 'cv' and auth.uid()::text = (storage.foldername(name))[1]);

-- Company Logos
create policy "Company logos are publicly accessible"
  on storage.objects for select
  using (bucket_id = 'company-logos');

create policy "Companies can upload company logo"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'company-logos');

-- Portfolios
create policy "Portfolio images are publicly accessible"
  on storage.objects for select
  using (bucket_id = 'portfolio');

create policy "Users can upload portfolio images"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'portfolio' and auth.uid()::text = (storage.foldername(name))[1]);
