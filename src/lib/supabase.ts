import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL  as string;
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL as string;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY as string;

export const supabase = createClient(
  supabaseUrl,
  supabaseAnonKey
);

export { supabase };

// ── Core types ────────────────────────────────────────────────────────────────
export interface Profile {
  id: string;
  name: string;
  email: string;

  is_parent: boolean;
  role: 'parent' | 'child' | 'admin';

  last_child_id?: string | null;

  avatar: string;
  stars: number;
  xp: number;
  level: number;
  total_correct: number;
  treasure_keys: number;
  parent_id: string | null;
  verification_code: string;
  created_at: string;
}
  id: string;
  name: string;
  email: string;
  is_parent: boolean;
  role: 'parent' | 'child' | 'admin';
  avatar: string;
  stars: number;
  xp: number;
  level: number;
  total_correct: number;
  treasure_keys: number;
  parent_id: string | null;
  verification_code: string;
  created_at: string;
}

export interface ChildRecord {
  id: string;
  parent_id: string | null;
  profile_id: string | null;
  first_name: string;
  year_group: string;
  target_exam_type: string;
  target_school: string | null;
  exam_date: string | null;
  avatar: string;
  xp_points: number;
  level: number;
  created_at: string;
}

export interface SkillMastery {
  id: string;
  child_id: string;
  skill_name: string;
  mastery_score: number;
  last_updated: string;
}

export interface Achievement {
  id: string;
  child_id: string;
  badge_name: string;
  description: string | null;
  earned_date: string;
}

export interface AiWeeklyTest {
  id: string;
  child_id: string;
  week_number: number;
  exam_type: string;
  question_ids: string[];
  generated_by_ai: boolean;
  score: number | null;
  total_questions: number;
  completed_at: string | null;
  created_at: string;
}

export interface QuizAttempt {
  id: string;
  user_id: string;
  child_id: string | null;
  category: string;
  total_questions: number;
  correct_answers: number;
  completed_at: string;
  is_weekly_test: boolean;
  week_number: number | null;
}

export interface Question {
  id: string;
  category: string;
  topic: string | null;
  question_text: string;
  options: string[];
  // NOTE: historically stored as an integer index (0-3) into `options`.
  // Some rows may instead store the option text directly as a string.
  // Always resolve via `isCorrectOption()` below rather than comparing directly.
  correct_answer: string | number;
  difficulty: number;
  explanation: string | null;
  exam_types: string[];
  year_groups: string[];
}

/**
 * Determines whether a chosen option is the correct answer for a question.
 * Handles both legacy integer-index answers (0-3) and newer string-match answers,
 * since the `questions` table has historically stored both formats.
 */
export function isCorrectOption(question: Pick<Question, 'options' | 'correct_answer'>, chosenOption: string): boolean {
  const { correct_answer, options } = question;
  if (typeof correct_answer === 'number') {
    return options[correct_answer] === chosenOption;
  }
  // String form: could be the option text itself, or a numeric string index.
  const asIndex = Number(correct_answer);
  if (Number.isInteger(asIndex) && asIndex >= 0 && asIndex < options.length && !options.includes(correct_answer)) {
    return options[asIndex] === chosenOption;
  }
  return correct_answer === chosenOption;
}

/** Returns the correct option's display text, for rendering/highlighting purposes. */
export function getCorrectOptionText(question: Pick<Question, 'options' | 'correct_answer'>): string {
  const { correct_answer, options } = question;
  if (typeof correct_answer === 'number') return options[correct_answer] ?? '';
  const asIndex = Number(correct_answer);
  if (Number.isInteger(asIndex) && asIndex >= 0 && asIndex < options.length && !options.includes(correct_answer)) {
    return options[asIndex] ?? '';
  }
  return correct_answer;
}

export interface Badge {
  id: string;
  name: string;
  description: string;
  icon: string;
  condition_type: string;
  condition_value: number;
}

export interface UserBadge {
  id: string;
  user_id: string;
  badge_id: string;
  earned_at: string;
  badge?: Badge;
}

export interface TreasureChest {
  id: string;
  user_id: string;
  correct_count_at_unlock: number;
  unlocked_at: string;
}

export interface DailyMission {
  id: string;
  user_id: string;
  mission_date: string;
  mission_type: string;
  title: string;
  description: string;
  icon: string;
  target_value: number;
  current_value: number;
  completed: boolean;
  xp_reward: number;
  keys_reward: number;
  subject_filter: string | null;
}

export interface TopicMastery {
  user_id: string;
  category: string;
  topic: string;
  total_attempts: number;
  correct_answers: number;
  mastery_pct: number;
}

export interface AiChallenge {
  id: string;
  user_id: string;
  title: string;
  description: string;
  focus_topics: string[];
  focus_category: string;
  question_ids: string[];
  xp_reward: number;
  is_completed: boolean;
  score: number | null;
  total_questions: number;
  created_at: string;
  completed_at: string | null;
}

// ── Coins & character shop ─────────────────────────────────────────────────────
export type ShopSlot = 'hat' | 'outfit' | 'face' | 'background';

export interface ShopItem {
  id: string;
  slot: ShopSlot;
  name: string;
  emoji: string;
  cost: number;
  rarity: 'common' | 'rare' | 'epic' | 'legendary';
  sort_order: number;
}

export interface ChildCoins {
  child_id: string;
  balance: number;
  updated_at: string;
}

export interface CoinTransaction {
  id: string;
  child_id: string;
  amount: number;
  reason: string;
  source_type: 'achievement' | 'streak' | 'weekly_test' | 'purchase' | 'manual';
  source_id: string | null;
  created_at: string;
}

export interface ChildInventoryItem {
  id: string;
  child_id: string;
  shop_item_id: string;
  acquired_at: string;
  shop_item?: ShopItem;
}

export interface ChildEquipped {
  child_id: string;
  slot: ShopSlot;
  shop_item_id: string;
  equipped_at: string;
  shop_item?: ShopItem;
}

// Slot render order (bottom to top) when layering accessories over the base avatar emoji.
// Background sits behind everything; hat/face/outfit-accent sit in front, in this order.
export const SHOP_SLOT_ORDER: ShopSlot[] = ['background', 'outfit', 'face', 'hat'];

export const SHOP_SLOT_LABELS: Record<ShopSlot, string> = {
  hat: 'Hats',
  face: 'Face',
  outfit: 'Outfits',
  background: 'Backgrounds',
};

// Coin amounts awarded for each kind of accomplishment. Mirrors the XP_AWARDS
// pattern below — keep both in sync when adjusting reward balance.
export const COIN_AWARDS = {
  achievement:        25,
  weeklyTestComplete: 15,
  weeklyTestPerfect:  40,
  streakMilestone:    30,  // awarded every 7-day streak milestone
} as const;

// ── Zone / subject config (legacy, kept for existing components) ──────────────
export const ZONES = [
  { id: 'math',             name: 'Maths',            emoji: '🏝️', color: 'from-blue-500 to-cyan-500',    description: 'Numbers, algebra & problem solving' },
  { id: 'english',          name: 'English',           emoji: '🏰', color: 'from-amber-500 to-yellow-500', description: 'Grammar, comprehension & writing' },
  { id: 'vocabulary',       name: 'Vocabulary',        emoji: '📚', color: 'from-emerald-500 to-teal-500', description: 'Word meanings & synonyms' },
  { id: 'verbal_reasoning', name: 'Verbal Reasoning',  emoji: '🧠', color: 'from-violet-500 to-purple-500',description: 'Logic, sequences & analogies' },
  { id: 'non_verbal',       name: 'Non-Verbal',        emoji: '🔷', color: 'from-rose-500 to-pink-500',    description: 'Patterns, shapes & spatial reasoning' },
] as const;

export function xpProgressInLevel(xp: number): number {
  return xp % 100;
}

// ── XP awards ─────────────────────────────────────────────────────────────────
export const XP_AWARDS = {
  dailyLogin:      10,
  quizCompletion:  20,
  perfectScore:    50,
  weeklyStreak:   100,
} as const;
