-- Victora School Management System - Database Schema
-- Supabase Migration

-- Enable pgcrypto for UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. CAMPUSES TABLE
CREATE TABLE IF NOT EXISTS public.campuses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    campus_type TEXT NOT NULL DEFAULT 'Main Campus',
    head_master TEXT,
    address TEXT,
    established_year INTEGER,
    students_count INTEGER DEFAULT 0,
    teachers_count INTEGER DEFAULT 0,
    attendance_rate NUMERIC(5,2) DEFAULT 90.0,
    collection_rate NUMERIC(5,2) DEFAULT 90.0,
    status TEXT DEFAULT 'Healthy' CHECK (status IN ('Healthy', 'Watch', 'Attention', 'Overdue')),
    room_utilization INTEGER DEFAULT 85,
    total_rooms INTEGER DEFAULT 40,
    flags_count INTEGER DEFAULT 0,
    grades_breakdown JSONB DEFAULT '[]'::jsonb,
    attendance_trend JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. STUDENTS TABLE
CREATE TABLE IF NOT EXISTS public.students (
    id BIGINT PRIMARY KEY,
    name TEXT NOT NULL,
    grade TEXT NOT NULL DEFAULT '10A',
    guardian_name TEXT,
    guardian_email TEXT,
    guardian_phone TEXT,
    status TEXT DEFAULT 'Active' CHECK (status IN ('Active', 'Pending docs', 'Archived', 'Suspended')),
    attendance_rate NUMERIC(5,2) DEFAULT 95.0,
    gpa NUMERIC(3,2) DEFAULT 3.0,
    risk_level TEXT DEFAULT 'Low' CHECK (risk_level IN ('Low', 'Medium', 'High')),
    progress INTEGER DEFAULT 50,
    enrolled_since TEXT DEFAULT 'Aug 2023',
    campus_id UUID REFERENCES public.campuses(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. INVOICES TABLE
CREATE TABLE IF NOT EXISTS public.invoices (
    id TEXT PRIMARY KEY,
    student_name TEXT NOT NULL,
    student_id BIGINT REFERENCES public.students(id) ON DELETE SET NULL,
    grade TEXT DEFAULT '10A',
    amount NUMERIC(10,2) NOT NULL DEFAULT 1240.00,
    amount_formatted TEXT DEFAULT '$1,240.00',
    due_date TEXT DEFAULT '30 Sep 2026',
    status TEXT DEFAULT 'Pending' CHECK (status IN ('Paid', 'Pending', 'Overdue', 'Cancelled')),
    payment_method TEXT DEFAULT '—',
    campus_id UUID REFERENCES public.campuses(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. ADMISSIONS PIPELINE LEADS TABLE
CREATE TABLE IF NOT EXISTS public.pipeline_leads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    stage TEXT NOT NULL CHECK (stage IN ('Inquiry', 'Applied', 'Interviewed', 'Accepted', 'Enrolled')),
    student_name TEXT NOT NULL,
    grade TEXT NOT NULL,
    guardian_name TEXT,
    guardian_email TEXT,
    guardian_phone TEXT,
    source TEXT DEFAULT 'Website form',
    previous_school TEXT,
    score INTEGER DEFAULT 0,
    notes TEXT,
    time_badge TEXT DEFAULT 'today',
    campus_id UUID REFERENCES public.campuses(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. GRADEBOOK SCORES TABLE
CREATE TABLE IF NOT EXISTS public.gradebook (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_name TEXT NOT NULL,
    student_id BIGINT REFERENCES public.students(id) ON DELETE CASCADE,
    scores JSONB NOT NULL DEFAULT '[0, 0, 0, 0]'::jsonb,
    final_grade TEXT DEFAULT 'B',
    trend TEXT DEFAULT 'flat' CHECK (trend IN ('up', 'down', 'flat')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. MESSAGES TABLE
CREATE TABLE IF NOT EXISTS public.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_name TEXT NOT NULL,
    sender_role TEXT,
    message TEXT NOT NULL,
    time_ago TEXT DEFAULT 'Just now',
    is_unread BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. ATTENDANCE & GATE CHECK-IN LOGS
CREATE TABLE IF NOT EXISTS public.attendance_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id BIGINT REFERENCES public.students(id) ON DELETE CASCADE,
    student_name TEXT,
    date DATE DEFAULT CURRENT_DATE,
    status TEXT NOT NULL CHECK (status IN ('P', 'L', 'A')),
    source TEXT DEFAULT 'QR Gate',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. SCHEDULE ITEMS
CREATE TABLE IF NOT EXISTS public.schedule_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    time_slot TEXT NOT NULL,
    subject TEXT NOT NULL,
    room TEXT NOT NULL,
    is_active_now BOOLEAN DEFAULT FALSE,
    campus_id UUID REFERENCES public.campuses(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security (RLS) on all tables
ALTER TABLE public.campuses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pipeline_leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gradebook ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.schedule_items ENABLE ROW LEVEL SECURITY;

-- Allow Public / Authenticated read access
CREATE POLICY "Public read campuses" ON public.campuses FOR SELECT USING (true);
CREATE POLICY "Public read students" ON public.students FOR SELECT USING (true);
CREATE POLICY "Public read invoices" ON public.invoices FOR SELECT USING (true);
CREATE POLICY "Public read pipeline" ON public.pipeline_leads FOR SELECT USING (true);
CREATE POLICY "Public read gradebook" ON public.gradebook FOR SELECT USING (true);
CREATE POLICY "Public read messages" ON public.messages FOR SELECT USING (true);
CREATE POLICY "Public read attendance" ON public.attendance_logs FOR SELECT USING (true);
CREATE POLICY "Public read schedule" ON public.schedule_items FOR SELECT USING (true);

-- Allow Public / Authenticated write access
CREATE POLICY "Public insert students" ON public.students FOR INSERT WITH CHECK (true);
CREATE POLICY "Public update students" ON public.students FOR UPDATE USING (true);

CREATE POLICY "Public insert invoices" ON public.invoices FOR INSERT WITH CHECK (true);
CREATE POLICY "Public update invoices" ON public.invoices FOR UPDATE USING (true);

CREATE POLICY "Public insert pipeline" ON public.pipeline_leads FOR INSERT WITH CHECK (true);
CREATE POLICY "Public update pipeline" ON public.pipeline_leads FOR UPDATE USING (true);

CREATE POLICY "Public insert messages" ON public.messages FOR INSERT WITH CHECK (true);
CREATE POLICY "Public update messages" ON public.messages FOR UPDATE USING (true);

CREATE POLICY "Public insert attendance" ON public.attendance_logs FOR INSERT WITH CHECK (true);

-- Enable Realtime subscriptions
ALTER PUBLICATION supabase_realtime ADD TABLE public.students;
ALTER PUBLICATION supabase_realtime ADD TABLE public.invoices;
ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.pipeline_leads;
ALTER PUBLICATION supabase_realtime ADD TABLE public.attendance_logs;
