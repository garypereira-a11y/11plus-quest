// ─── Exam type definitions ────────────────────────────────────────────────────
// Each exam provider has a specific set of subjects, skills, and progression rules.

export type ExamType =
  | 'GL Assessment'
  | 'CEM'
  | 'BSG'
  | 'Poole Grammar'
  | 'CSSE'
  | 'Independent School'
  | 'Bournemouth School for Girls'
  | 'Bournemouth School'
  | 'Other';

export type YearGroup = 'Year 3' | 'Year 4' | 'Year 5' | 'Year 6';

export interface ExamSubject {
  id: string;
  name: string;
  emoji: string;
  color: string;
  description: string;
  skills: string[];
  weeklyTargetQuestions: number;
}

export interface ExamProfile {
  type: ExamType;
  fullName: string;
  description: string;
  subjects: ExamSubject[];
  totalWeeks: number;
  weeklyTestQuestions: number;
  difficultyProgression: { week: number; difficulty: number }[];
}

// ─── Subject library ──────────────────────────────────────────────────────────
const MATHS: ExamSubject = {
  id: 'math', name: 'Maths', emoji: '🔢', color: 'from-blue-500 to-cyan-500',
  description: 'Arithmetic, fractions, algebra & problem solving',
  skills: ['Arithmetic', 'Fractions', 'Decimals', 'Percentages', 'Algebra', 'Geometry', 'Data Handling', 'Number Sequences'],
  weeklyTargetQuestions: 20,
};

const ENGLISH: ExamSubject = {
  id: 'english', name: 'English', emoji: '📖', color: 'from-amber-500 to-yellow-500',
  description: 'Grammar, comprehension, punctuation & writing',
  skills: ['Grammar', 'Punctuation', 'Comprehension', 'Spelling', 'Synonyms', 'Antonyms', 'Sentence Structure', 'Writing Techniques'],
  weeklyTargetQuestions: 20,
};

const VERBAL: ExamSubject = {
  id: 'verbal_reasoning', name: 'Verbal Reasoning', emoji: '🧠', color: 'from-violet-500 to-purple-500',
  description: 'Analogies, sequences & word relationships',
  skills: ['Word Analogies', 'Letter Sequences', 'Number Codes', 'Word Codes', 'Missing Words', 'Odd One Out', 'Compound Words'],
  weeklyTargetQuestions: 15,
};

const NON_VERBAL: ExamSubject = {
  id: 'non_verbal', name: 'Non-Verbal Reasoning', emoji: '🔷', color: 'from-rose-500 to-pink-500',
  description: 'Patterns, shapes & spatial reasoning',
  skills: ['Pattern Recognition', 'Rotation', 'Reflection', 'Matrices', '3D Shapes', 'Sequences', 'Odd Shape Out'],
  weeklyTargetQuestions: 15,
};

const VOCABULARY: ExamSubject = {
  id: 'vocabulary', name: 'Vocabulary', emoji: '📚', color: 'from-emerald-500 to-teal-500',
  description: 'Word meanings, synonyms & antonyms',
  skills: ['Synonyms', 'Antonyms', 'Word Meanings', 'Context Clues', 'Root Words', 'Prefixes', 'Suffixes'],
  weeklyTargetQuestions: 15,
};

const NUMERICAL: ExamSubject = {
  id: 'numerical_reasoning', name: 'Numerical Reasoning', emoji: '📊', color: 'from-sky-500 to-blue-500',
  description: 'Data interpretation & numerical logic',
  skills: ['Data Interpretation', 'Number Patterns', 'Logic Puzzles', 'Ratio', 'Probability', 'Mental Arithmetic'],
  weeklyTargetQuestions: 15,
};

const CLOZE: ExamSubject = {
  id: 'cloze', name: 'Cloze', emoji: '✏️', color: 'from-orange-500 to-amber-500',
  description: 'Fill-in-the-blank comprehension passages',
  skills: ['Cloze Comprehension', 'Context Reading', 'Word Inference', 'Passage Understanding'],
  weeklyTargetQuestions: 10,
};

// ─── Exam profiles ────────────────────────────────────────────────────────────
const defaultProgression = Array.from({ length: 12 }, (_, i) => ({
  week: i + 1,
  difficulty: Math.min(10, 3 + Math.floor(i * 0.7)),
}));

export const EXAM_PROFILES: Record<string, ExamProfile> = {
  'GL Assessment': {
    type: 'GL Assessment', fullName: 'GL Assessment', totalWeeks: 12, weeklyTestQuestions: 30,
    description: 'GL Assessment covers Maths, English, Verbal Reasoning and Non-Verbal Reasoning',
    subjects: [MATHS, ENGLISH, VERBAL, NON_VERBAL],
    difficultyProgression: defaultProgression,
  },
  'CEM': {
    type: 'CEM', fullName: 'CEM (Centre for Evaluation & Monitoring)', totalWeeks: 12, weeklyTestQuestions: 30,
    description: 'CEM focuses on Verbal Reasoning, Vocabulary, Numerical Reasoning and Cloze',
    subjects: [VERBAL, VOCABULARY, NUMERICAL, CLOZE],
    difficultyProgression: defaultProgression,
  },
  'BSG': {
    type: 'BSG', fullName: 'Bournemouth School for Girls', totalWeeks: 12, weeklyTestQuestions: 25,
    description: 'BSG entrance covers English, Maths and Verbal Reasoning',
    subjects: [ENGLISH, MATHS, VERBAL],
    difficultyProgression: defaultProgression,
  },
  'Bournemouth School for Girls': {
    type: 'Bournemouth School for Girls', fullName: 'Bournemouth School for Girls', totalWeeks: 12, weeklyTestQuestions: 25,
    description: 'BSG entrance covers English, Maths and Verbal Reasoning',
    subjects: [ENGLISH, MATHS, VERBAL],
    difficultyProgression: defaultProgression,
  },
  'Bournemouth School': {
    type: 'Bournemouth School', fullName: 'Bournemouth School (Boys)', totalWeeks: 12, weeklyTestQuestions: 25,
    description: 'Bournemouth School entrance covers Maths, English and Verbal Reasoning',
    subjects: [MATHS, ENGLISH, VERBAL],
    difficultyProgression: defaultProgression,
  },
  'Poole Grammar': {
    type: 'Poole Grammar', fullName: 'Poole Grammar School', totalWeeks: 12, weeklyTestQuestions: 25,
    description: 'Poole Grammar covers English, Maths and Verbal Reasoning',
    subjects: [ENGLISH, MATHS, VERBAL],
    difficultyProgression: defaultProgression,
  },
  'CSSE': {
    type: 'CSSE', fullName: 'CSSE (Consortium for Selective Schools in Essex)', totalWeeks: 14, weeklyTestQuestions: 30,
    description: 'CSSE covers Maths, English, Verbal Reasoning and Non-Verbal Reasoning',
    subjects: [MATHS, ENGLISH, VERBAL, NON_VERBAL],
    difficultyProgression: defaultProgression,
  },
  'Independent School': {
    type: 'Independent School', fullName: 'Independent School Entrance', totalWeeks: 16, weeklyTestQuestions: 30,
    description: 'Comprehensive preparation across all 11+ subjects',
    subjects: [MATHS, ENGLISH, VERBAL, NON_VERBAL, VOCABULARY],
    difficultyProgression: defaultProgression,
  },
  'Other': {
    type: 'Other', fullName: 'General 11+ Preparation', totalWeeks: 12, weeklyTestQuestions: 30,
    description: 'Broad 11+ preparation covering all key areas',
    subjects: [MATHS, ENGLISH, VERBAL, NON_VERBAL],
    difficultyProgression: defaultProgression,
  },
};

export function getExamProfile(examType: string): ExamProfile {
  return EXAM_PROFILES[examType] ?? EXAM_PROFILES['Other'];
}

export const ALL_EXAM_TYPES: ExamType[] = [
  'GL Assessment', 'CEM', 'CSSE', 'Independent School',
  'Bournemouth School for Girls', 'Bournemouth School', 'Poole Grammar', 'Other',
];

export const ALL_YEAR_GROUPS: YearGroup[] = ['Year 3', 'Year 4', 'Year 5', 'Year 6'];

export const ALL_TARGET_SCHOOLS = [
  'Bournemouth School for Girls',
  'Bournemouth School',
  'Poole Grammar',
  'Parkstone Grammar',
  'GL Assessment School',
  'CEM School',
  'Other',
];
