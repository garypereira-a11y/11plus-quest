/*
# 11+ Adventure: Seed Data

This migration populates the database with initial educational content.

## Data Added

1. **questions** - 50+ educational questions across all categories
2. **badges** - 15 achievement badges
*/

-- Insert Mathematics questions
INSERT INTO questions (category, question_text, options, correct_answer, explanation, difficulty, age_range) VALUES
('math', 'What is 15 + 27?', '["32", "42", "52", "62"]', 1, '15 + 27 = 42. Add the ones first: 5 + 7 = 12, then the tens: 10 + 20 = 30. Total: 30 + 12 = 42', 1, '8-9'),
('math', 'What is 100 - 37?', '["63", "73", "67", "53"]', 0, '100 - 37 = 63. To subtract easily, think 100 - 30 = 70, then 70 - 7 = 63', 1, '8-9'),
('math', 'What is 8 × 7?', '["54", "56", "58", "48"]', 1, '8 × 7 = 56. Remember: 8 × 5 = 40, 8 × 2 = 16, so 40 + 16 = 56', 1, '8-9'),
('math', 'What is 72 ÷ 8?', '["7", "8", "9", "10"]', 2, '72 ÷ 8 = 9. Think: 8 × ? = 72. Since 8 × 9 = 72, the answer is 9', 1, '8-9'),
('math', 'A book costs £4.50. How much do 3 books cost?', '["£12.50", "£13.00", "£13.50", "£14.00"]', 2, '£4.50 × 3 = £13.50. £4 × 3 = £12, and 50p × 3 = £1.50. Total: £12 + £1.50 = £13.50', 2, '9-10'),
('math', 'What is 25% of 80?', '["15", "20", "25", "40"]', 1, '25% means 1/4. 80 ÷ 4 = 20. So 25% of 80 is 20', 2, '9-10'),
('math', 'What is the next number in the sequence: 5, 10, 15, 20, ...?', '["22", "24", "25", "30"]', 2, 'This sequence increases by 5 each time. 20 + 5 = 25', 1, '8-9'),
('math', 'If a train leaves at 9:15 AM and arrives at 10:45 AM, how long was the journey?', '["1 hour 15 mins", "1 hour 30 mins", "1 hour 45 mins", "2 hours"]', 1, 'From 9:15 to 10:15 is 1 hour. From 10:15 to 10:45 is 30 minutes. Total: 1 hour 30 minutes', 2, '9-10'),
('math', 'What is 3/4 + 1/4?', '["1/2", "3/4", "1", "1 1/4"]', 2, '3/4 + 1/4 = 4/4 = 1. When you add fractions with the same denominator, just add the numerators', 2, '9-10'),
('math', 'A rectangle has length 8cm and width 5cm. What is the area?', '["13 sq cm", "26 sq cm", "40 sq cm", "45 sq cm"]', 2, 'Area = length × width = 8 × 5 = 40 square centimetres', 2, '9-10');

-- Insert Verbal Reasoning questions
INSERT INTO questions (category, question_text, options, correct_answer, explanation, difficulty, age_range) VALUES
('verbal_reasoning', 'If CAR is coded as 3-1-18, how is BUS coded?', '["2-21-19", "2-20-19", "2-22-19", "2-21-20"]', 0, 'Each letter is replaced by its position in the alphabet. B=2, U=21, S=19', 2, '9-10'),
('verbal_reasoning', 'Find the odd one out: Apple, Banana, Carrot, Orange', '["Apple", "Banana", "Carrot", "Orange"]', 2, 'Carrot is a vegetable. All the others (Apple, Banana, Orange) are fruits', 1, '8-9'),
('verbal_reasoning', 'START is to BEGIN as FINISH is to ___?', '["RACE", "END", "COMPLETE", "WIN"]', 1, 'START and BEGIN are synonyms (same meaning). So FINISH and END are also synonyms', 1, '8-9'),
('verbal_reasoning', 'If all cats have tails, and Fluffy is a cat, what can we conclude?', '["Fluffy has no tail", "Fluffy has a tail", "Fluffy is a dog", "Cats like Fluffy"]', 1, 'Since all cats have tails and Fluffy is a cat, Fluffy must have a tail', 1, '8-9'),
('verbal_reasoning', 'Which word does not belong: Fast, Quick, Slow, Rapid?', '["Fast", "Quick", "Slow", "Rapid"]', 2, 'Fast, Quick, and Rapid all mean the same thing (speedy). Slow is the opposite', 1, '8-9'),
('verbal_reasoning', 'DOG is to PUPPY as CAT is to ___?', '["PET", "KITTEN", "ANIMAL", "BABY"]', 1, 'A puppy is a young dog. A kitten is a young cat', 1, '8-9'),
('verbal_reasoning', 'What comes next: A, C, E, G, __?', '["H", "I", "J", "K"]', 1, 'The letters skip one each time: A, (skip B), C, (skip D), E, (skip F), G, (skip H), I', 2, '9-10'),
('verbal_reasoning', 'If REASON is coded as SFBTPO, how is THINK coded?', '["UIJOL", "UJ IJL", "UJ ILM", "UJ KLM"]', 0, 'Each letter is replaced by the next letter in the alphabet. T→U, H→I, I→J, N→O, K→L', 2, '9-10'),
('verbal_reasoning', 'Bird is to Fly as Fish is to ___?', '["Water", "Swim", "Ocean", "Scales"]', 1, 'Birds fly through the air. Fish swim through water', 1, '8-9'),
('verbal_reasoning', 'Find the pattern: 2, 4, 8, 16, __?', '["24", "28", "32", "34"]', 2, 'Each number is doubled. 2×2=4, 4×2=8, 8×2=16, 16×2=32', 2, '9-10');

-- Insert English questions
INSERT INTO questions (category, question_text, options, correct_answer, explanation, difficulty, age_range) VALUES
('english', 'Which word is spelled correctly?', '["Recieve", "Receive", "Receeve", "Recive"]', 1, 'Remember the rule: i before e, except after c. R-e-c-e-i-v-e', 1, '8-9'),
('english', 'Which sentence has correct punctuation?', '["The cat sat on the mat", "The cat sat, on the mat", "The cat sat on the mat.", "the cat sat on the mat."]', 2, 'The sentence starts with a capital letter and ends with a full stop', 1, '8-9'),
('english', 'Which word is a noun?', '["Run", "Beautiful", "Happiness", "Quickly"]', 2, 'Happiness is a noun (a thing). Run is a verb, Beautiful is an adjective, Quickly is an adverb', 1, '8-9'),
('english', 'Choose the correct word: The dog wagged ___ tail.', '["its", "it''s", "its''", "it s"]', 0, 'Its shows possession (belonging to it). It''s means it is', 1, '8-9'),
('english', 'Which sentence uses the correct homophone?', '["Their going to the park", "They''re going to the park", "There going to the park", "Theire going to the park"]', 1, 'They''re means they are. Their shows possession. There refers to a place', 2, '9-10'),
('english', 'What type of word is beautifully?', '["Noun", "Verb", "Adjective", "Adverb"]', 3, 'Words ending in -ly are usually adverbs. Beautifully describes how something is done', 1, '8-9'),
('english', 'Which sentence is a question?', '["You like apples", "Do you like apples.", "Do you like apples?", "You like apples?"]', 2, 'Questions start with words like Do/What/Where and end with a question mark', 1, '8-9'),
('english', 'Choose the correct plural: The _____ were in the field.', '["sheep", "sheeps", "sheepes", "sheep''s"]', 0, 'Sheep is one of those words that has the same singular and plural form', 1, '8-9'),
('english', 'Which word is an antonym of happy?', '["Joyful", "Sad", "Glad", "Cheerful"]', 1, 'An antonym is a word with the opposite meaning. Sad is the opposite of happy', 1, '8-9'),
('english', 'Identify the verb: The children played happily in the garden.', '["Children", "Played", "Happily", "Garden"]', 1, 'Played is a verb - it shows action. Children (noun), happily (adverb), garden (noun)', 1, '8-9');

-- Insert Odd One Out questions
INSERT INTO questions (category, question_text, options, correct_answer, explanation, difficulty, age_range) VALUES
('odd_one_out', 'Find the odd one out: Circle, Square, Triangle, Ball', '["Circle", "Square", "Triangle", "Ball"]', 3, 'Ball is an object. Circle, Square, and Triangle are 2D shapes', 1, '8-9'),
('odd_one_out', 'Find the odd one out: January, Monday, March, May', '["January", "Monday", "March", "May"]', 1, 'Monday is a day of the week. January, March, and May are months', 1, '8-9'),
('odd_one_out', 'Find the odd one out: Red, Blue, Green, Apple', '["Red", "Blue", "Green", "Apple"]', 3, 'Apple is a fruit. Red, Blue, and Green are colours', 1, '8-9'),
('odd_one_out', 'Find the odd one out: Dog, Cat, Lion, Car', '["Dog", "Cat", "Lion", "Car"]', 3, 'Car is a vehicle. Dog, Cat, and Lion are animals', 1, '8-9'),
('odd_one_out', 'Find the odd one out: 2, 4, 6, 7', '["2", "4", "6", "7"]', 3, '7 is an odd number. 2, 4, and 6 are even numbers', 1, '8-9'),
('odd_one_out', 'Find the odd one out: Rose, Tulip, Carrot, Daisy', '["Rose", "Tulip", "Carrot", "Daisy"]', 2, 'Carrot is a vegetable. Rose, Tulip, and Daisy are flowers', 1, '8-9'),
('odd_one_out', 'Find the odd one out: Pen, Pencil, Eraser, Table', '["Pen", "Pencil", "Eraser", "Table"]', 3, 'Table is furniture. Pen, Pencil, and Eraser are stationery items', 1, '8-9'),
('odd_one_out', 'Find the odd one out: 3, 6, 9, 10', '["3", "6", "9", "10"]', 3, 'The pattern is multiples of 3. 10 does not fit (3, 6, 9, 12 would continue)', 2, '9-10'),
('odd_one_out', 'Find the odd one out: Milk, Juice, Water, Bread', '["Milk", "Juice", "Water", "Bread"]', 3, 'Bread is solid food. Milk, Juice, and Water are liquids', 1, '8-9'),
('odd_one_out', 'Find the odd one out: London, Paris, Rome, Thames', '["London", "Paris", "Rome", "Thames"]', 3, 'Thames is a river. London, Paris, and Rome are capital cities', 2, '9-10');

-- Insert Vocabulary questions
INSERT INTO questions (category, question_text, options, correct_answer, explanation, difficulty, age_range) VALUES
('vocabulary', 'What does enormous mean?', '["Very small", "Very large", "Very fast", "Very slow"]', 1, 'Enormous means very large or huge in size', 1, '8-9'),
('vocabulary', 'Which word means the same as happy?', '["Sad", "Joyful", "Angry", "Tired"]', 1, 'Joyful is a synonym of happy - both mean feeling good or pleased', 1, '8-9'),
('vocabulary', 'What does ancient mean?', '["New", "Very old", "Modern", "Future"]', 1, 'Ancient means very old, from a long time ago', 1, '8-9'),
('vocabulary', 'Which word means to make something better?', '["Worsen", "Improve", "Destroy", "Create"]', 1, 'Improve means to make something better', 1, '8-9'),
('vocabulary', 'What is another word for begin?', '["End", "Start", "Finish", "Stop"]', 1, 'Start and begin are synonyms - they both mean to start something', 1, '8-9'),
('vocabulary', 'What does delicious mean?', '["Very tasty", "Very ugly", "Very loud", "Very fast"]', 0, 'Delicious describes food that tastes very good', 1, '8-9'),
('vocabulary', 'Which word is an antonym (opposite) of noisy?', '["Loud", "Quiet", "Busy", "Fast"]', 1, 'Quiet is the opposite of noisy. It means making little or no sound', 1, '8-9'),
('vocabulary', 'What does exhausted mean?', '["Very happy", "Very tired", "Very hungry", "Very excited"]', 1, 'Exhausted means extremely tired or worn out', 2, '9-10'),
('vocabulary', 'Which word means almost the same?', '["Different", "Similar", "Opposite", "Better"]', 1, 'Similar means nearly the same or alike in some way', 1, '8-9'),
('vocabulary', 'What does disappear mean?', '["To appear", "To vanish", "To find", "To show"]', 1, 'Disappear means to vanish or become invisible', 1, '8-9'),
('vocabulary', 'Which word means very important?', '["Trivial", "Crucial", "Simple", "Easy"]', 1, 'Crucial means extremely important or necessary', 2, '9-10'),
('vocabulary', 'What does generous mean?', '["Selfish", "Kind and giving", "Mean", "Angry"]', 1, 'Generous means willing to give and share with others', 1, '8-9'),
('vocabulary', 'Which word means the opposite of expand?', '["Grow", "Shrink", "Increase", "Stretch"]', 1, 'Shrink is the opposite of expand. To expand is to grow larger, to shrink is to become smaller', 2, '9-10'),
('vocabulary', 'What does anxious mean?', '["Happy", "Worried", "Calm", "Asleep"]', 1, 'Anxious means feeling worried, nervous, or uneasy about something', 2, '9-10'),
('vocabulary', 'Which word means able to be trusted?', '["Reliable", "Dangerous", "Careless", "Unknown"]', 0, 'Reliable means dependable and trustworthy', 2, '9-10');

-- Insert badges
INSERT INTO badges (name, description, icon, requirement_type, requirement_value, category) VALUES
('First Steps', 'Complete your first quiz!', '🎯', 'quiz_complete', 1, NULL),
('Getting Started', 'Complete 5 quizzes', '🌟', 'quiz_complete', 5, NULL),
('Quiz Explorer', 'Complete 10 quizzes', '🏆', 'quiz_complete', 10, NULL),
('Perfect 5', 'Get 5 correct in a row!', '🔥', 'correct_streak', 5, NULL),
('Double Digits', 'Get 10 correct in a row!', '💎', 'correct_streak', 10, NULL),
('Math Master', 'Score 100% in Mathematics', '🔢', 'category_perfect', 10, 'math'),
('Word Wizard', 'Score 100% in Vocabulary', '📚', 'category_perfect', 10, 'vocabulary'),
('Logic Legend', 'Score 100% in Verbal Reasoning', '🧠', 'category_perfect', 10, 'verbal_reasoning'),
('Grammar Guru', 'Score 100% in English', '✏️', 'category_perfect', 10, 'english'),
('Pattern Pro', 'Score 100% in Odd One Out', '🔍', 'category_perfect', 10, 'odd_one_out'),
('Treasure Hunter', 'Unlock your first treasure chest!', '📦', 'treasure_unlock', 1, NULL),
('Gold Rush', 'Unlock 5 treasure chests!', '💰', 'treasure_unlock', 5, NULL),
('Weekly Warrior', 'Complete your first weekly test!', '📅', 'weekly_test', 1, NULL),
('Super Scholar', 'Complete all weekly tests in a month!', '🎓', 'weekly_month', 4, NULL),
('Century Club', 'Reach 100 total correct answers!', '💯', 'total_correct', 100, NULL);