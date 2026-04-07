-- MindGuard Database Schema
-- Run in Supabase SQL Editor

-- ============================================================
-- PROFILES
-- ============================================================
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  timezone TEXT NOT NULL DEFAULT 'UTC',
  onboarding_complete BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name)
  VALUES (
    NEW.id,
    SPLIT_PART(NEW.email, '@', 1)
  );
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at();

-- ============================================================
-- DAILY CHECK-INS
-- ============================================================
CREATE TABLE IF NOT EXISTS public.daily_checkins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  mood_score INTEGER NOT NULL CHECK (mood_score BETWEEN 1 AND 5),
  anxiety_level INTEGER NOT NULL CHECK (anxiety_level BETWEEN 1 AND 10),
  sleep_hours NUMERIC(3,1) NOT NULL CHECK (sleep_hours BETWEEN 0 AND 18),
  gratitude_note TEXT,
  general_notes TEXT,
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, date)   -- One check-in per day per user
);

CREATE INDEX IF NOT EXISTS daily_checkins_user_date_idx ON public.daily_checkins(user_id, date DESC);

-- ============================================================
-- THOUGHT REFRAMES
-- ============================================================
CREATE TABLE IF NOT EXISTS public.thought_reframes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  negative_thought TEXT NOT NULL,
  intensity_level INTEGER NOT NULL CHECK (intensity_level BETWEEN 1 AND 10),
  emotion_tags TEXT[] NOT NULL DEFAULT '{}',
  context_note TEXT,
  reframed_thought TEXT,
  ai_assisted BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS thought_reframes_user_idx ON public.thought_reframes(user_id, created_at DESC);

-- ============================================================
-- WEEKLY REFLECTIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS public.weekly_reflections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  week_start DATE NOT NULL,            -- Always Monday
  biggest_challenge TEXT,
  biggest_win TEXT,
  next_week_goal TEXT,
  mood_average NUMERIC(3,1),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, week_start)
);

CREATE INDEX IF NOT EXISTS weekly_reflections_user_idx ON public.weekly_reflections(user_id, week_start DESC);

-- ============================================================
-- BADGE ACHIEVEMENTS
-- ============================================================
CREATE TYPE IF NOT EXISTS public.badge_slug AS ENUM (
  'first_entry',
  'three_checkins',
  'seven_day_streak',
  'first_reflection',
  'ten_entries',
  'thought_reframer',
  'gratitude_builder',
  'thirty_day_consistency'
);

CREATE TABLE IF NOT EXISTS public.badge_achievements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  badge_slug public.badge_slug NOT NULL,
  earned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, badge_slug)
);

CREATE INDEX IF NOT EXISTS badge_achievements_user_idx ON public.badge_achievements(user_id, earned_at DESC);

-- ============================================================
-- FEEDBACK SUBMISSIONS
-- ============================================================
CREATE TYPE IF NOT EXISTS public.feedback_type AS ENUM ('bug', 'feature', 'general');

CREATE TABLE IF NOT EXISTS public.feedback_submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  feedback_type public.feedback_type NOT NULL DEFAULT 'general',
  message TEXT NOT NULL CHECK (LENGTH(message) >= 10 AND LENGTH(message) <= 2000),
  email TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_checkins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.thought_reframes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weekly_reflections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.badge_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feedback_submissions ENABLE ROW LEVEL SECURITY;

-- Profiles: users can only see and edit their own
CREATE POLICY "profiles_select_own" ON public.profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "profiles_update_own" ON public.profiles
  FOR UPDATE USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

-- Daily check-ins: full CRUD for own data
CREATE POLICY "checkins_select_own" ON public.daily_checkins
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "checkins_insert_own" ON public.daily_checkins
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "checkins_update_own" ON public.daily_checkins
  FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "checkins_delete_own" ON public.daily_checkins
  FOR DELETE USING (auth.uid() = user_id);

-- Thought reframes
CREATE POLICY "reframes_select_own" ON public.thought_reframes
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "reframes_insert_own" ON public.thought_reframes
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "reframes_update_own" ON public.thought_reframes
  FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "reframes_delete_own" ON public.thought_reframes
  FOR DELETE USING (auth.uid() = user_id);

-- Weekly reflections
CREATE POLICY "reflections_select_own" ON public.weekly_reflections
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "reflections_insert_own" ON public.weekly_reflections
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "reflections_update_own" ON public.weekly_reflections
  FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "reflections_delete_own" ON public.weekly_reflections
  FOR DELETE USING (auth.uid() = user_id);

-- Badge achievements
CREATE POLICY "badges_select_own" ON public.badge_achievements
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "badges_insert_own" ON public.badge_achievements
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Feedback: authenticated users see own, anyone can insert
CREATE POLICY "feedback_select_own" ON public.feedback_submissions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "feedback_insert" ON public.feedback_submissions
  FOR INSERT WITH CHECK (TRUE);

-- ============================================================
-- VIEWS (for easier querying)
-- ============================================================

-- Weekly stats view
CREATE OR REPLACE VIEW public.weekly_checkin_stats AS
SELECT
  user_id,
  DATE_TRUNC('week', date) AS week_start,
  COUNT(*) AS checkin_count,
  ROUND(AVG(mood_score), 1) AS avg_mood,
  ROUND(AVG(anxiety_level), 1) AS avg_anxiety,
  ROUND(AVG(sleep_hours), 1) AS avg_sleep
FROM public.daily_checkins
GROUP BY user_id, DATE_TRUNC('week', date);
