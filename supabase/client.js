/**
 * Supabase Client & Data Access Layer for Victora School Management
 * Supports both hosted Supabase project and local development.
 */

// Read config from global window or environment variables
const SUPABASE_URL = (typeof window !== 'undefined' && window.SUPABASE_URL) || 
  (typeof process !== 'undefined' && process.env && process.env.SUPABASE_URL) || 
  'https://your-project.supabase.co';

const SUPABASE_ANON_KEY = (typeof window !== 'undefined' && window.SUPABASE_ANON_KEY) || 
  (typeof process !== 'undefined' && process.env && process.env.SUPABASE_ANON_KEY) || 
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';

// Check if credentials have been customized
const isConfigured = Boolean(
  SUPABASE_URL && 
  SUPABASE_ANON_KEY && 
  !SUPABASE_URL.includes('your-project')
);

let supabaseInstance = null;

export function getSupabase() {
  if (supabaseInstance) return supabaseInstance;

  if (typeof window !== 'undefined' && window.supabase && window.supabase.createClient) {
    supabaseInstance = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
  } else if (typeof require !== 'undefined') {
    try {
      const { createClient } = require('@supabase/supabase-js');
      supabaseInstance = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
    } catch (e) {
      console.warn('Supabase JS not installed or bundled locally.');
    }
  }
  return supabaseInstance;
}

// ── DATA SERVICE METHODS ──

export async function getStudents() {
  const sb = getSupabase();
  if (!sb || !isConfigured) return null;
  const { data, error } = await sb.from('students').select('*').order('id', { ascending: true });
  if (error) {
    console.error('Error fetching students:', error);
    return null;
  }
  return data.map(s => ({
    id: s.id,
    n: s.name,
    g: s.grade,
    gu: s.guardian_name,
    st: s.status,
    at: s.attendance_rate,
    gpa: s.gpa,
    r: s.risk_level,
    prog: s.progress,
    since: s.enrolled_since
  }));
}

export async function saveStudent(student) {
  const sb = getSupabase();
  if (!sb || !isConfigured) return null;
  const payload = {
    id: student.id || Date.now(),
    name: student.n,
    grade: student.g || '10A',
    guardian_name: student.gu || '—',
    status: student.st || 'Active',
    attendance_rate: student.at || 100,
    gpa: student.gpa || 3.0,
    risk_level: student.r || 'Low',
    progress: student.prog || 0,
    enrolled_since: student.since || 'Sep 2026'
  };
  const { data, error } = await sb.from('students').upsert(payload).select().single();
  if (error) {
    console.error('Error saving student to Supabase:', error);
    throw error;
  }
  return data;
}

export async function getInvoices() {
  const sb = getSupabase();
  if (!sb || !isConfigured) return null;
  const { data, error } = await sb.from('invoices').select('*').order('created_at', { ascending: false });
  if (error) {
    console.error('Error fetching invoices:', error);
    return null;
  }
  return data.map(inv => ({
    id: inv.id,
    n: inv.student_name,
    g: inv.grade,
    amt: inv.amount_formatted,
    due: inv.due_date,
    st: inv.status,
    m: inv.payment_method
  }));
}

export async function createInvoice(invoice) {
  const sb = getSupabase();
  if (!sb || !isConfigured) return null;
  const numAmt = parseFloat((invoice.amt || '0').replace(/[^0-9.]/g, '')) || 0;
  const payload = {
    id: invoice.id,
    student_name: invoice.n,
    grade: invoice.g,
    amount: numAmt,
    amount_formatted: invoice.amt.startsWith('$') ? invoice.amt : '$' + invoice.amt,
    due_date: invoice.due,
    status: invoice.st || 'Pending',
    payment_method: invoice.m || '—'
  };
  const { data, error } = await sb.from('invoices').insert(payload).select().single();
  if (error) {
    console.error('Error creating invoice in Supabase:', error);
    throw error;
  }
  return data;
}

export async function getMessages() {
  const sb = getSupabase();
  if (!sb || !isConfigured) return null;
  const { data, error } = await sb.from('messages').select('*').order('created_at', { ascending: false });
  if (error) {
    console.error('Error fetching messages:', error);
    return null;
  }
  return data.map(m => ({
    w: m.sender_name,
    r: m.sender_role,
    m: m.message,
    t: m.time_ago,
    unread: m.is_unread
  }));
}

export async function createMessage(msg) {
  const sb = getSupabase();
  if (!sb || !isConfigured) return null;
  const payload = {
    sender_name: msg.w || 'Admin',
    sender_role: msg.r || 'Staff',
    message: msg.m,
    time_ago: 'Just now',
    is_unread: true
  };
  const { data, error } = await sb.from('messages').insert(payload).select().single();
  if (error) {
    console.error('Error sending message via Supabase:', error);
    throw error;
  }
  return data;
}

export async function recordGateCheckIn(studentId, status = 'P') {
  const sb = getSupabase();
  if (!sb || !isConfigured) return null;
  const { data, error } = await sb.from('attendance_logs').insert({
    student_id: studentId,
    status: status,
    source: 'QR Gate'
  });
  if (error) {
    console.error('Error logging gate check-in:', error);
    throw error;
  }
  return data;
}

export { isConfigured };
