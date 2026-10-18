# 🗄️ Supabase Backend & Database Setup — Victora School Management

This directory contains the database schema, seed data, configuration, and data access client for the Victora School Management System.

---

## 🏗️ Database Architecture

The database consists of 8 core PostgreSQL tables with Row Level Security (RLS) enabled and real-time replication:

| Table | Purpose |
|-------|---------|
| `campuses` | Campus locations, capacity, student/teacher counts, collection rates |
| `students` | Student profiles, guardians, grades, GPA, risk scores, attendance |
| `invoices` | Billing invoices, amounts, due dates, payment status |
| `pipeline_leads` | Admissions funnel leads across 5 stages (Inquiry to Enrolled) |
| `gradebook` | Student assignment scores, final letter grades, trend indicators |
| `messages` | Internal messaging between staff, guardians, and administration |
| `attendance_logs`| Gate QR check-ins and daily classroom attendance events |
| `schedule_items` | Timetable slots, subjects, classrooms, and active session markers |

---

## 🚀 Setup Option A: Supabase Cloud (Recommended)

1. **Create a project**:
   - Go to [supabase.com](https://supabase.com) and create a new project.
   - Note your **Project URL** and **anon public key** from `Project Settings > API`.

2. **Run Migrations & Seed**:
   - In your Supabase Dashboard, open the **SQL Editor**.
   - Copy the contents of `supabase/migrations/20261018000000_school_mgmt_schema.sql` and run it.
   - Copy the contents of `supabase/seed.sql` and run it to populate demo records.

3. **Deploy to Vercel**:
   - Add `SUPABASE_URL` and `SUPABASE_ANON_KEY` to your Vercel Environment Variables:
     ```bash
     vercel env add SUPABASE_URL
     vercel env add SUPABASE_ANON_KEY
     ```

---

## 💻 Setup Option B: Local Development (Supabase CLI)

If you have Docker installed, you can run Supabase entirely locally:

```bash
# 1. Start local Supabase stack (PostgreSQL, PostgREST, Studio)
npx supabase start

# 2. Apply migrations and seed data
npx supabase db reset

# 3. View database in local Studio UI
# http://localhost:54323
```

---

## 🔌 Frontend Integration

The app uses `supabase/client.js` to fetch and persist data. When `SUPABASE_URL` and `SUPABASE_ANON_KEY` are provided (either via `window.SUPABASE_URL` or environment variables), the UI connects directly to Supabase. If credentials are not present, it gracefully falls back to local reactive storage.
