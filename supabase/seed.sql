-- Victora School Management System - Seed Data

-- 1. Campuses
INSERT INTO public.campuses (name, campus_type, students_count, teachers_count, attendance_rate, collection_rate, status, head_master, established_year, address, room_utilization, total_rooms, flags_count, grades_breakdown, attendance_trend)
VALUES
('Northbridge High', 'Main Campus', 1240, 82, 94.1, 96.0, 'Healthy', 'Dr. Alan Pierce', 1974, '1200 Bridge Road, Northbridge', 88, 46, 18, 
 '[["Grade 9", 318], ["Grade 10", 322], ["Grade 11", 305], ["Grade 12", 295]]'::jsonb, 
 '[91, 93, 92, 95, 94, 96, 94, 95, 93, 96, 94, 94]'::jsonb),

('Northbridge Middle', 'West Campus', 680, 44, 89.4, 84.0, 'Watch', 'Maria Santos', 1988, '450 Sunset Ave, Westpark', 74, 28, 24, 
 '[["Grade 6", 220], ["Grade 7", 235], ["Grade 8", 225]]'::jsonb, 
 '[86, 88, 87, 89, 90, 89, 88, 91, 89, 90, 89, 89]'::jsonb),

('Valley Primary', 'South Campus', 410, 26, 92.0, 79.0, 'Watch', 'David Kim', 2002, '82 Valley View Lane', 82, 18, 12, 
 '[["Grade 1", 75], ["Grade 2", 80], ["Grade 3", 82], ["Grade 4", 85], ["Grade 5", 88]]'::jsonb, 
 '[90, 91, 93, 92, 91, 92, 92, 93, 91, 92, 92, 92]'::jsonb),

('Beacon Elementary', 'East Campus', 121, 11, 85.0, 95.0, 'Healthy', 'Sarah Jenkins', 2016, '14 Lighthouse Road', 68, 8, 5, 
 '[["Kindergarten", 30], ["Grade 1", 30], ["Grade 2", 31], ["Grade 3", 30]]'::jsonb, 
 '[82, 84, 85, 83, 86, 85, 84, 86, 85, 85, 85, 85]'::jsonb)
ON CONFLICT DO NOTHING;

-- 2. Students
INSERT INTO public.students (id, name, grade, guardian_name, status, attendance_rate, gpa, risk_level, progress, enrolled_since)
VALUES
(1, 'Emma Johnson', '10A', 'Marcus Johnson', 'Active', 96, 3.8, 'Low', 78, 'Aug 2023'),
(2, 'Noah Williams', '12B', 'Priya Williams', 'Active', 88, 3.1, 'Low', 60, 'Aug 2021'),
(3, 'Olivia Chen', '10A', 'Wei Chen', 'Active', 62, 2.4, 'High', 34, 'Jan 2024'),
(4, 'Ethan Walker', '11B', 'Dana Walker', 'Active', 79, 2.7, 'Medium', 52, 'Aug 2022'),
(5, 'Sofia Ramirez', '9C', 'Luis Ramirez', 'Active', 94, 3.6, 'Low', 85, 'Aug 2025'),
(6, 'Liam Doherty', '11B', 'Fiona Doherty', 'Pending docs', 91, 3.3, 'Low', 71, 'Aug 2022'),
(7, 'Aisha Bello', '12B', 'Tunde Bello', 'Active', 84, 3.9, 'Low', 92, 'Aug 2021'),
(8, 'Mateo Rossi', '9C', 'Elena Rossi', 'Archived', 71, 2.9, 'Medium', 44, 'Aug 2025')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  grade = EXCLUDED.grade,
  guardian_name = EXCLUDED.guardian_name,
  status = EXCLUDED.status;

-- 3. Invoices
INSERT INTO public.invoices (id, student_name, student_id, grade, amount, amount_formatted, due_date, status, payment_method)
VALUES
('INV-20841', 'Emma Johnson', 1, '10A', 1240.00, ',240.00', '30 Sep 2026', 'Paid', 'Card'),
('INV-20842', 'Noah Williams', 2, '12B', 1480.00, ',480.00', '30 Sep 2026', 'Paid', 'Bank'),
('INV-20843', 'Olivia Chen', 3, '10A', 1240.00, ',240.00', '12 Sep 2026', 'Overdue', '—'),
('INV-20844', 'Ethan Walker', 4, '11B', 1360.00, ',360.00', '30 Sep 2026', 'Pending', '—'),
('INV-20845', 'Sofia Ramirez', 5, '9C', 1120.00, ',120.00', '30 Sep 2026', 'Paid', 'Card'),
('INV-20846', 'Liam Doherty', 6, '11B', 1360.00, ',360.00', '05 Sep 2026', 'Overdue', '—'),
('INV-20847', 'Aisha Bello', 7, '12B', 1480.00, ',480.00', '30 Sep 2026', 'Pending', '—')
ON CONFLICT (id) DO NOTHING;

-- 4. Admissions Pipeline
INSERT INTO public.pipeline_leads (stage, student_name, grade, time_badge, guardian_name, guardian_email, guardian_phone, source, previous_school, score, notes)
VALUES
('Inquiry', 'Zara Ahmed', 'Grade 6', '2d ago', 'Nadia Ahmed', 'nadia.ahmed@email.com', '+1 (415) 555-0118', 'Open day', 'Maple Park Primary', 0, 'Requested a tour of the science block. Sibling already at Middle.'),
('Inquiry', 'Felix Brandt', 'Grade 9', '3d ago', 'Karl Brandt', 'k.brandt@email.com', '+1 (415) 555-0163', 'Website form', 'Eastvale Junior High', 0, 'Relocating from out of state in January.'),
('Inquiry', 'Nina Kowalski', 'Grade 7', '4d ago', 'Ewa Kowalski', 'ewa.k@email.com', '+1 (415) 555-0194', 'Referral', 'St. Brigid School', 0, 'Referred by the Delgado family.'),
('Applied', 'Omar Haddad', 'Grade 10', '1d ago', 'Layla Haddad', 'layla.haddad@email.com', '+1 (415) 555-0142', 'Website form', 'Cedar Ridge High', 78, 'Strong maths transcript. Requesting scholarship assessment.'),
('Applied', 'Grace Lin', 'Grade 6', '5d ago', 'Wen Lin', 'wen.lin@email.com', '+1 (415) 555-0177', 'Open day', 'Harborview Primary', 71, 'Music programme is the deciding factor for the family.'),
('Interviewed', 'Isla Murray', 'Grade 8', 'today', 'Fiona Murray', 'f.murray@email.com', '+1 (415) 555-0155', 'Referral', 'Glenfield Middle', 88, 'Excellent interview. Panel recommends immediate offer.'),
('Interviewed', 'Tobias Lund', 'Grade 11', '2d ago', 'Anders Lund', 'a.lund@email.com', '+1 (415) 555-0131', 'Agent', 'Nordvik Gymnasium', 74, 'International transfer. Awaiting translated transcripts.'),
('Interviewed', 'Maya Iyer', 'Grade 9', '6d ago', 'Ravi Iyer', 'ravi.iyer@email.com', '+1 (415) 555-0186', 'Website form', 'Lakeshore Junior High', 81, 'Panel split on placement year — recommend maths re-test.'),
('Accepted', 'Dante Moreau', 'Grade 7', '1d ago', 'Celine Moreau', 'c.moreau@email.com', '+1 (415) 555-0109', 'Open day', 'Rosemont Primary', 85, 'Offer accepted. Deposit invoice pending guardian action.'),
('Enrolled', 'Ruby Sinclair', 'Grade 10', 'today', 'Ian Sinclair', 'i.sinclair@email.com', '+1 (415) 555-0126', 'Referral', 'Fairmount High', 90, 'Enrolled and timetabled. Homeroom 10A confirmed.'),
('Enrolled', 'Kai Tanaka', 'Grade 6', '3d ago', 'Yuki Tanaka', 'y.tanaka@email.com', '+1 (415) 555-0148', 'Website form', 'Brookline Primary', 83, 'Enrolled. Bus route 4 assigned.');

-- 5. Gradebook
INSERT INTO public.gradebook (student_name, student_id, scores, final_grade, trend)
VALUES
('Emma Johnson', 1, '[94, 88, 91, 96]'::jsonb, 'A', 'up'),
('Noah Williams', 2, '[78, 82, 74, 80]'::jsonb, 'B-', 'flat'),
('Olivia Chen', 3, '[61, 58, 66, 54]'::jsonb, 'D+', 'down'),
('Ethan Walker', 4, '[72, 68, 70, 66]'::jsonb, 'C', 'down'),
('Sofia Ramirez', 5, '[89, 92, 86, 94]'::jsonb, 'A-', 'up'),
('Aisha Bello', 7, '[96, 94, 98, 95]'::jsonb, 'A+', 'up');

-- 6. Messages
INSERT INTO public.messages (sender_name, sender_role, message, time_ago, is_unread)
VALUES
('Ms. Alvarez', 'Algebra II teacher', 'Emma’s midterm was excellent — she’s ready for the accelerated track next term.', '2h ago', true),
('Front Office', 'Northbridge Middle', 'Field trip consent form is due Friday 18 Sep. Please sign in the portal.', 'Yesterday', true),
('Mr. Okafor', 'Chemistry teacher', 'Lab safety briefing rescheduled to Thursday, period 3.', '3d ago', false),
('Counseling Office', 'Student wellbeing', 'Quarterly check-in slots are open. Book any time before 30 Sep.', '5d ago', false);

-- 7. Schedule
INSERT INTO public.schedule_items (time_slot, subject, room, is_active_now)
VALUES
('08:00', 'Algebra II', 'Room 204', false),
('09:00', 'Biology', 'Lab 2', true),
('10:00', 'English Lit', 'Room 118', false),
('13:00', 'Chemistry', 'Lab 1', false),
('14:00', 'PE', 'Indoor Court', false);
