// Database types matching Supabase schema

export type Json = string | number | boolean | null | { [key: string]: Json | undefined } | Json[]

export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: Profile
        Insert: ProfileInsert
        Update: ProfileUpdate
      }
      daily_checkins: {
        Row: DailyCheckin
        Insert: DailyCheckinInsert
        Update: DailyCheckinUpdate
      }
      thought_reframes: {
        Row: ThoughtReframe
        Insert: ThoughtReframeInsert
        Update: ThoughtReframeUpdate
      }
      weekly_reflections: {
        Row: WeeklyReflection
        Insert: WeeklyReflectionInsert
        Update: WeeklyReflectionUpdate
      }
      badge_achievements: {
        Row: BadgeAchievement
        Insert: BadgeAchievementInsert
        Update: BadgeAchievementUpdate
      }
      feedback_submissions: {
        Row: FeedbackSubmission
        Insert: FeedbackSubmissionInsert
        Update: FeedbackSubmissionUpdate
      }
    }
  }
}

// Profiles
export interface Profile {
  id: string
  display_name: string | null
  timezone: string
  onboarding_complete: boolean
  created_at: string
  updated_at: string
}

export interface ProfileInsert {
  id: string
  display_name?: string | null
  timezone?: string
  onboarding_complete?: boolean
}

export interface ProfileUpdate {
  display_name?: string | null
  timezone?: string
  onboarding_complete?: boolean
  updated_at?: string
}

// Daily Check-ins
export interface DailyCheckin {
  id: string
  user_id: string
  mood_score: number          // 1-5
  anxiety_level: number       // 1-10
  sleep_hours: number         // 0-12, step 0.5
  gratitude_note: string | null
  general_notes: string | null
  created_at: string
  date: string                // YYYY-MM-DD for deduplication
}

export interface DailyCheckinInsert {
  user_id: string
  mood_score: number
  anxiety_level: number
  sleep_hours: number
  gratitude_note?: string | null
  general_notes?: string | null
  date: string
}

export interface DailyCheckinUpdate {
  mood_score?: number
  anxiety_level?: number
  sleep_hours?: number
  gratitude_note?: string | null
  general_notes?: string | null
}

// Thought Reframes
export interface ThoughtReframe {
  id: string
  user_id: string
  negative_thought: string
  intensity_level: number     // 1-10
  emotion_tags: string[]
  context_note: string | null
  reframed_thought: string | null
  ai_assisted: boolean
  created_at: string
}

export interface ThoughtReframeInsert {
  user_id: string
  negative_thought: string
  intensity_level: number
  emotion_tags?: string[]
  context_note?: string | null
  reframed_thought?: string | null
  ai_assisted?: boolean
}

export interface ThoughtReframeUpdate {
  reframed_thought?: string | null
  ai_assisted?: boolean
}

// Weekly Reflections
export interface WeeklyReflection {
  id: string
  user_id: string
  week_start: string          // YYYY-MM-DD (Monday)
  biggest_challenge: string | null
  biggest_win: string | null
  next_week_goal: string | null
  mood_average: number | null
  created_at: string
}

export interface WeeklyReflectionInsert {
  user_id: string
  week_start: string
  biggest_challenge?: string | null
  biggest_win?: string | null
  next_week_goal?: string | null
  mood_average?: number | null
}

export interface WeeklyReflectionUpdate {
  biggest_challenge?: string | null
  biggest_win?: string | null
  next_week_goal?: string | null
  mood_average?: number | null
}

// Badge Achievements
export type BadgeSlug =
  | 'first_entry'
  | 'three_checkins'
  | 'seven_day_streak'
  | 'first_reflection'
  | 'ten_entries'
  | 'thought_reframer'
  | 'gratitude_builder'
  | 'thirty_day_consistency'

export interface BadgeAchievement {
  id: string
  user_id: string
  badge_slug: BadgeSlug
  earned_at: string
}

export interface BadgeAchievementInsert {
  user_id: string
  badge_slug: BadgeSlug
}

export interface BadgeAchievementUpdate {
  earned_at?: string
}

// Feedback
export type FeedbackType = 'bug' | 'feature' | 'general'

export interface FeedbackSubmission {
  id: string
  user_id: string | null
  feedback_type: FeedbackType
  message: string
  email: string | null
  created_at: string
}

export interface FeedbackSubmissionInsert {
  user_id?: string | null
  feedback_type: FeedbackType
  message: string
  email?: string | null
}

export interface FeedbackSubmissionUpdate {
  message?: string
}

// App-level types

export interface MoodOption {
  score: number
  label: string
  emoji: string
  description: string
}

export const MOOD_OPTIONS: MoodOption[] = [
  { score: 1, label: 'Very Low', emoji: '😞', description: 'Struggling significantly' },
  { score: 2, label: 'Low', emoji: '😟', description: 'Not feeling great' },
  { score: 3, label: 'Neutral', emoji: '😐', description: 'Getting by' },
  { score: 4, label: 'Good', emoji: '🙂', description: 'Doing reasonably well' },
  { score: 5, label: 'Great', emoji: '😊', description: 'Feeling positive' },
]

export const EMOTION_TAGS = [
  'Anxious', 'Overwhelmed', 'Frustrated', 'Sad', 'Angry',
  'Fearful', 'Lonely', 'Ashamed', 'Hopeless', 'Irritable',
  'Worried', 'Stressed', 'Exhausted', 'Numb', 'Confused',
]

export interface BadgeDefinition {
  slug: BadgeSlug
  name: string
  description: string
  icon: string
}

export const BADGE_DEFINITIONS: BadgeDefinition[] = [
  { slug: 'first_entry', name: 'First Step', description: 'Completed your first check-in', icon: '✨' },
  { slug: 'three_checkins', name: 'Building Habit', description: 'Completed 3 check-ins', icon: '🌱' },
  { slug: 'seven_day_streak', name: '7-Day Streak', description: 'Checked in 7 days in a row', icon: '🔥' },
  { slug: 'first_reflection', name: 'Reflective', description: 'Completed your first weekly reflection', icon: '🪞' },
  { slug: 'ten_entries', name: 'Committed', description: 'Logged 10 total entries', icon: '💪' },
  { slug: 'thought_reframer', name: 'Reframer', description: 'Used thought reframing for the first time', icon: '🔄' },
  { slug: 'gratitude_builder', name: 'Grateful', description: 'Added 5 gratitude notes', icon: '🌸' },
  { slug: 'thirty_day_consistency', name: '30 Days Strong', description: 'Checked in 30 days total', icon: '🏆' },
]

// Dashboard summary type
export interface DashboardSummary {
  recentCheckins: DailyCheckin[]
  recentReframes: ThoughtReframe[]
  recentReflection: WeeklyReflection | null
  badges: BadgeAchievement[]
  streakDays: number
  totalCheckins: number
  avgMoodThisWeek: number | null
  avgAnxietyThisWeek: number | null
  avgSleepThisWeek: number | null
}

// Form action results
export interface ActionResult<T = void> {
  success: boolean
  data?: T
  error?: string
  fieldErrors?: Record<string, string[]>
}
