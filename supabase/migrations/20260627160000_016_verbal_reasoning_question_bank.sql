/*
# 11+ Quest: Verbal Reasoning Question Bank Expansion

Adds 105 new verbal_reasoning questions (15 per topic × 7 topics), even
spread across difficulty 1/2/3 (5 each per topic), spanning Year 3-6.

All code-breaking / cipher answers were pre-computed and verified
programmatically (alphabet shift ciphers, position codes) before being
written into this file, to avoid hand-arithmetic errors on letter shifts.

Purely additive — existing seed questions (migration 002) are untouched.
correct_answer uses the integer index format (0-3) into `options`.
*/

INSERT INTO questions (category, topic, question_text, options, correct_answer, explanation, difficulty, age_range) VALUES

-- ═══════════════════════════════════════════════════════════════════════
-- ANALOGIES (15)
-- ═══════════════════════════════════════════════════════════════════════
('verbal_reasoning', 'Analogies', 'HOT is to COLD as UP is to ___?', '["High", "Down", "Sky", "Top"]', 1, 'HOT and COLD are opposites. UP and DOWN are also opposites', 1, '8-9'),
('verbal_reasoning', 'Analogies', 'BIG is to SMALL as FAST is to ___?', '["Quick", "Slow", "Speed", "Run"]', 1, 'BIG and SMALL are opposites. FAST and SLOW are also opposites', 1, '8-9'),
('verbal_reasoning', 'Analogies', 'FINGER is to HAND as TOE is to ___?', '["Leg", "Foot", "Shoe", "Walk"]', 1, 'A finger is part of a hand, just as a toe is part of a foot', 1, '8-9'),
('verbal_reasoning', 'Analogies', 'TEACHER is to SCHOOL as DOCTOR is to ___?', '["Patient", "Hospital", "Medicine", "Nurse"]', 1, 'A teacher works at a school, just as a doctor works at a hospital', 1, '8-9'),
('verbal_reasoning', 'Analogies', 'PUPPY is to DOG as KITTEN is to ___?', '["Cat", "Mouse", "Pet", "Paw"]', 0, 'A puppy is a young dog, just as a kitten is a young cat', 1, '8-9'),
('verbal_reasoning', 'Analogies', 'AUTHOR is to BOOK as COMPOSER is to ___?', '["Orchestra", "Music", "Piano", "Concert"]', 1, 'An author creates a book, just as a composer creates music', 2, '9-10'),
('verbal_reasoning', 'Analogies', 'WHEEL is to CAR as WING is to ___?', '["Bird", "Sky", "Feather", "Fly"]', 0, 'A wheel is a part that helps a car move, just as a wing is a part that helps a bird move', 2, '9-10'),
('verbal_reasoning', 'Analogies', 'THERMOMETER is to TEMPERATURE as RULER is to ___?', '["Length", "Wood", "Straight", "School"]', 0, 'A thermometer measures temperature, just as a ruler measures length', 2, '9-10'),
('verbal_reasoning', 'Analogies', 'CATERPILLAR is to BUTTERFLY as TADPOLE is to ___?', '["Pond", "Frog", "Egg", "Fish"]', 1, 'A caterpillar transforms into a butterfly, just as a tadpole transforms into a frog', 2, '9-10'),
('verbal_reasoning', 'Analogies', 'LIBRARY is to BOOKS as MUSEUM is to ___?', '["Tickets", "Artefacts", "Visitors", "Buildings"]', 1, 'A library houses and displays books, just as a museum houses and displays artefacts', 2, '9-10'),
('verbal_reasoning', 'Analogies', 'OPTIMIST is to HOPEFUL as PESSIMIST is to ___?', '["Negative", "Cheerful", "Curious", "Calm"]', 0, 'An optimist tends to be hopeful, just as a pessimist tends to be negative', 3, '10-11'),
('verbal_reasoning', 'Analogies', 'DROUGHT is to WATER as FAMINE is to ___?', '["Money", "Food", "Disease", "Rain"]', 1, 'A drought is caused by a lack of water, just as a famine is caused by a lack of food', 3, '10-11'),
('verbal_reasoning', 'Analogies', 'CONDUCTOR is to ORCHESTRA as MANAGER is to ___?', '["Office", "Team", "Business", "Boss"]', 1, 'A conductor leads and directs an orchestra, just as a manager leads and directs a team', 3, '10-11'),
('verbal_reasoning', 'Analogies', 'MICROSCOPE is to SMALL as TELESCOPE is to ___?', '["Near", "Distant", "Bright", "Heavy"]', 1, 'A microscope helps you see very small things, just as a telescope helps you see very distant things', 3, '10-11'),
('verbal_reasoning', 'Analogies', 'INSOMNIA is to SLEEP as AMNESIA is to ___?', '["Memory", "Hunger", "Sight", "Speech"]', 0, 'Insomnia is the inability to sleep, just as amnesia is the inability to remember (loss of memory)', 3, '10-11'),

-- ═══════════════════════════════════════════════════════════════════════
-- SEQUENCES (15)
-- ═══════════════════════════════════════════════════════════════════════
('verbal_reasoning', 'Sequences', 'What comes next in the alphabet sequence? A, B, C, D, __?', '["E", "F", "G", "H"]', 0, 'This follows the alphabet in order. The letter after D is E', 1, '8-9'),
('verbal_reasoning', 'Sequences', 'What comes next? Z, Y, X, W, __?', '["U", "V", "T", "S"]', 1, 'This sequence goes backwards through the alphabet. The letter before W is V', 1, '8-9'),
('verbal_reasoning', 'Sequences', 'What comes next? B, D, F, H, __?', '["I", "J", "K", "L"]', 1, 'This sequence skips one letter each time (every other letter). After H comes J', 1, '8-9'),
('verbal_reasoning', 'Sequences', 'What comes next? Monday, Wednesday, Friday, __?', '["Saturday", "Sunday", "Tuesday", "Thursday"]', 1, 'This sequence skips one day each time. After Friday, skipping Saturday, comes Sunday', 1, '8-9'),
('verbal_reasoning', 'Sequences', 'What comes next? A, C, E, G, __?', '["H", "I", "J", "K"]', 1, 'The letters skip one each time: A, (skip B), C, (skip D), E, (skip F), G, (skip H), I', 1, '8-9'),
('verbal_reasoning', 'Sequences', 'What comes next? J, L, N, P, __?', '["Q", "R", "S", "T"]', 1, 'This sequence skips one letter each time. After P, skipping Q, comes R', 2, '9-10'),
('verbal_reasoning', 'Sequences', 'What comes next? January, March, May, __?', '["June", "July", "August", "April"]', 1, 'This sequence skips one month each time. After May, skipping June, comes July', 2, '9-10'),
('verbal_reasoning', 'Sequences', 'What comes next? Z, X, V, T, __?', '["S", "R", "Q", "P"]', 1, 'This sequence moves backwards, skipping one letter each time. After T, skipping U, comes R', 2, '9-10'),
('verbal_reasoning', 'Sequences', 'What comes next? AB, DE, GH, JK, __?', '["LM", "MN", "NO", "OP"]', 1, 'Each pair starts 3 letters after the previous pair started (A, D, G, J, M), so the next pair starts with M: MN', 2, '9-10'),
('verbal_reasoning', 'Sequences', 'What comes next? C, F, I, L, __?', '["M", "N", "O", "P"]', 2, 'This sequence skips two letters each time. After L, skipping M and N, comes O', 2, '9-10'),
('verbal_reasoning', 'Sequences', 'What comes next? Z, W, T, Q, __?', '["O", "N", "M", "P"]', 1, 'This sequence moves backwards by 3 letters each time. After Q, going back 3, comes N', 3, '10-11'),
('verbal_reasoning', 'Sequences', 'What comes next? B, E, I, N, __?', '["R", "S", "T", "U"]', 2, 'The gap between letters increases each time: +3, +4, +5, so the next gap is +6. N is the 14th letter; 14 + 6 = 20, which is T', 3, '10-11'),
('verbal_reasoning', 'Sequences', 'What comes next? AZ, BY, CX, DW, __?', '["EV", "EU", "FV", "FW"]', 0, 'The first letter moves forward (A,B,C,D,E) while the second letter moves backward (Z,Y,X,W,V) — so next is EV', 3, '10-11'),
('verbal_reasoning', 'Sequences', 'What comes next? Sunday, Tuesday, Friday, __?', '["Saturday", "Sunday", "Tuesday", "Wednesday"]', 2, 'The gap between days increases each time: +2, +3, so the next gap is +4. Friday plus 4 days lands on Tuesday', 3, '10-11'),
('verbal_reasoning', 'Sequences', 'What comes next? A, D, I, P, __?', '["Y", "X", "W", "Z"]', 0, 'The gaps between letters are square numbers: +3(=A to D... checking positions: A=1,D=4,I=9,P=16, which are 1²,2²,3²,4², so next is 5²=25=Y', 3, '10-11'),

-- ═══════════════════════════════════════════════════════════════════════
-- WORD RELATIONSHIPS (15)
-- ═══════════════════════════════════════════════════════════════════════
('verbal_reasoning', 'Word Relationships', 'HAPPY is to SAD as DAY is to ___?', '["Sun", "Night", "Bright", "Light"]', 1, 'HAPPY and SAD are opposites. DAY and NIGHT are also opposites', 1, '8-9'),
('verbal_reasoning', 'Word Relationships', 'BOOK is to READ as FOOD is to ___?', '["Eat", "Cook", "Kitchen", "Plate"]', 0, 'A book is something you read, just as food is something you eat', 1, '8-9'),
('verbal_reasoning', 'Word Relationships', 'KEY is to LOCK as ___ is to DOOR?', '["Wall", "Handle", "House", "Window"]', 1, 'A key is used to open a lock, just as a handle is used to open a door', 1, '8-9'),
('verbal_reasoning', 'Word Relationships', 'BEE is to HONEY as COW is to ___?', '["Grass", "Milk", "Farm", "Field"]', 1, 'A bee produces honey, just as a cow produces milk', 1, '8-9'),
('verbal_reasoning', 'Word Relationships', 'SCISSORS is to CUT as PENCIL is to ___?', '["Write", "Sharp", "Paper", "Draw"]', 0, 'Scissors are used to cut, just as a pencil is used to write', 1, '8-9'),
('verbal_reasoning', 'Word Relationships', 'CHAPTER is to BOOK as SCENE is to ___?', '["Actor", "Play", "Stage", "Curtain"]', 1, 'A chapter is a section of a book, just as a scene is a section of a play', 2, '9-10'),
('verbal_reasoning', 'Word Relationships', 'PETAL is to FLOWER as LEAF is to ___?', '["Tree", "Green", "Branch", "Root"]', 0, 'A petal is a part of a flower, just as a leaf is a part of a tree', 2, '9-10'),
('verbal_reasoning', 'Word Relationships', 'NOVEL is to FICTION as BIOGRAPHY is to ___?', '["Fantasy", "Non-fiction", "Poetry", "Drama"]', 1, 'A novel belongs to the fiction category, just as a biography belongs to the non-fiction category', 2, '9-10'),
('verbal_reasoning', 'Word Relationships', 'WHISPER is to QUIET as SHOUT is to ___?', '["Loud", "Angry", "Far", "Speak"]', 0, 'A whisper is associated with being quiet, just as a shout is associated with being loud', 2, '9-10'),
('verbal_reasoning', 'Word Relationships', 'HIBERNATE is to WINTER as MIGRATE is to ___?', '["Season change", "Summer only", "Sleep", "Food"]', 0, 'Hibernation is a behaviour linked to surviving winter, just as migration is a behaviour linked to a change in season', 2, '9-10'),
('verbal_reasoning', 'Word Relationships', 'TYRANNY is to OPPRESSION as DEMOCRACY is to ___?', '["Freedom", "Royalty", "War", "Silence"]', 0, 'Tyranny is associated with oppression, just as democracy is associated with freedom', 3, '10-11'),
('verbal_reasoning', 'Word Relationships', 'PRECEDE is to BEFORE as FOLLOW is to ___?', '["After", "Beside", "Above", "Within"]', 0, 'To precede means to come before, just as to follow means to come after', 3, '10-11'),
('verbal_reasoning', 'Word Relationships', 'SCARCITY is to SHORTAGE as ABUNDANCE is to ___?', '["Plenty", "Lack", "Demand", "Cost"]', 0, 'Scarcity means a shortage, just as abundance means a plentiful supply', 3, '10-11'),
('verbal_reasoning', 'Word Relationships', 'CRITIC is to JUDGE as ADVOCATE is to ___?', '["Oppose", "Support", "Ignore", "Question"]', 1, 'A critic tends to judge or find fault, just as an advocate tends to support or argue for something', 3, '10-11'),
('verbal_reasoning', 'Word Relationships', 'TRANSIENT is to TEMPORARY as PERMANENT is to ___?', '["Lasting", "Brief", "Changing", "Fading"]', 0, 'Transient means temporary, just as permanent means lasting', 3, '10-11'),

-- ═══════════════════════════════════════════════════════════════════════
-- CODE BREAKING (15) — all shift values pre-verified programmatically
-- ═══════════════════════════════════════════════════════════════════════
('verbal_reasoning', 'Code Breaking', 'If DOG is coded as 4-15-7, how is CAT coded?', '["3-1-19", "3-1-20", "3-2-20", "4-1-20"]', 1, 'Each letter is replaced by its position in the alphabet. C=3, A=1, T=20', 1, '8-9'),
('verbal_reasoning', 'Code Breaking', 'If SUN is coded as 19-21-14, how is PEN coded?', '["16-5-14", "16-4-14", "15-5-14", "16-5-13"]', 0, 'Each letter is replaced by its position in the alphabet. P=16, E=5, N=14', 1, '8-9'),
('verbal_reasoning', 'Code Breaking', 'If each letter shifts forward by 1 (A becomes B), how is CAT coded?', '["DBT", "DBU", "DCU", "EBU"]', 1, 'Shift each letter forward by one: C→D, A→B, T→U, giving DBU', 1, '8-9'),
('verbal_reasoning', 'Code Breaking', 'If each letter shifts forward by 1, how is DOG coded?', '["EPH", "EPI", "FPH", "EQH"]', 0, 'Shift each letter forward by one: D→E, O→P, G→H, giving EPH', 1, '8-9'),
('verbal_reasoning', 'Code Breaking', 'If MAP is coded as 13-1-16, how is BOX coded?', '["2-15-23", "2-15-24", "2-16-24", "3-15-24"]', 1, 'Each letter is replaced by its position in the alphabet. B=2, O=15, X=24', 1, '8-9'),
('verbal_reasoning', 'Code Breaking', 'If each letter shifts forward by 2, how is SUN coded?', '["UWO", "UWP", "TVP", "UVP"]', 1, 'Shift each letter forward by two: S→U, U→W, N→P, giving UWP', 2, '9-10'),
('verbal_reasoning', 'Code Breaking', 'If each letter shifts forward by 2, how is FISH coded?', '["HJTI", "HKTJ", "HKUJ", "GKUJ"]', 2, 'Shift each letter forward by two: F→H, I→K, S→U, H→J, giving HKUJ', 2, '9-10'),
('verbal_reasoning', 'Code Breaking', 'If TREE is coded as WUHH (shift forward by 3), how is CLOUD coded?', '["FORXG", "FOQXG", "FOQWG", "EORXG"]', 0, 'Shift each letter forward by three: C→F, L→O, O→R, U→X, D→G, giving FORXG', 2, '9-10'),
('verbal_reasoning', 'Code Breaking', 'If REASON is coded as SFBTPO, how is THINK coded?', '["UIJOL", "UIJOM", "UJJOL", "UIKOL"]', 0, 'Each letter is replaced by the next letter in the alphabet (shift +1). T→U, H→I, I→J, N→O, K→L', 2, '9-10'),
('verbal_reasoning', 'Code Breaking', 'If each letter shifts forward by 1, how is HAPPY coded?', '["IBQQY", "IBQQZ", "IBPQZ", "JBQQZ"]', 1, 'Shift each letter forward by one: H→I, A→B, P→Q, P→Q, Y→Z, giving IBQQZ', 2, '9-10'),
('verbal_reasoning', 'Code Breaking', 'If each letter shifts forward by 3, how is WINTER coded?', '["ZLQWHU", "ZLQWHT", "YLQWHU", "ZKQWHU"]', 0, 'Shift each letter forward by three: W→Z, I→L, N→Q, T→W, E→H, R→U, giving ZLQWHU', 3, '10-11'),
('verbal_reasoning', 'Code Breaking', 'If each letter shifts backward by 1 (B becomes A), how is MOUSE coded?', '["LNTRD", "LNTRE", "MNTRD", "LOTRD"]', 0, 'Shift each letter backward by one: M→L, O→N, U→T, S→R, E→D, giving LNTRD', 3, '10-11'),
('verbal_reasoning', 'Code Breaking', 'If GARDEN is coded as ICTFGP, what is the shift used?', '["Forward by 1", "Forward by 2", "Backward by 1", "Backward by 2"]', 1, 'Checking: G→I is +2, A→C is +2, R→T is +2 — confirming a forward shift of 2', 3, '10-11'),
('verbal_reasoning', 'Code Breaking', 'If a code shifts each letter back by 2 (C becomes A), how is FISH coded?', '["DGQF", "DGRF", "DGQE", "EGQF"]', 0, 'Shift each letter backward by two: F→D, I→G, S→Q, H→F, giving DGQF', 3, '10-11'),
('verbal_reasoning', 'Code Breaking', 'If RIVER is coded as ULYHU (shift forward by 3), what would the shift forward by 3 code for STONE be?', '["VWRQH", "VWRPH", "VVRQH", "VWQQH"]', 0, 'Shift each letter forward by three: S→V, T→W, O→R, N→Q, E→H, giving VWRQH', 3, '10-11'),

-- ═══════════════════════════════════════════════════════════════════════
-- LOGIC (15)
-- ═══════════════════════════════════════════════════════════════════════
('verbal_reasoning', 'Logic', 'If all birds can fly, and a robin is a bird, what can we conclude?', '["A robin cannot fly", "A robin can fly", "A robin is not a bird", "Nothing can be concluded"]', 1, 'Since all birds can fly and a robin is a bird, it follows logically that a robin can fly', 1, '8-9'),
('verbal_reasoning', 'Logic', 'If it is raining, Tom takes an umbrella. It is raining. What does Tom do?', '["Tom stays inside", "Tom takes an umbrella", "Tom gets wet", "Tom cannot be sure"]', 1, 'The rule states that rain means Tom takes an umbrella. Since it is raining, Tom takes an umbrella', 1, '8-9'),
('verbal_reasoning', 'Logic', 'All squares have 4 sides. This shape has 4 sides. Is it definitely a square?', '["Yes, definitely", "No, not necessarily", "Only if it is red", "Only if it is small"]', 1, 'Having 4 sides does not guarantee it is a square — it could be a rectangle or another 4-sided shape', 1, '8-9'),
('verbal_reasoning', 'Logic', 'If Sam is older than Ben, and Ben is older than Amy, who is the oldest?', '["Sam", "Ben", "Amy", "Cannot tell"]', 0, 'Sam is older than Ben, and Ben is older than Amy, so Sam must be the oldest of the three', 1, '8-9'),
('verbal_reasoning', 'Logic', 'If all cats chase mice, and Whiskers is a cat, what can we conclude?', '["Whiskers chases mice", "Whiskers does not chase mice", "Whiskers is not a cat", "Mice chase Whiskers"]', 0, 'Since all cats chase mice and Whiskers is a cat, Whiskers must chase mice', 1, '8-9'),
('verbal_reasoning', 'Logic', 'If no fish can walk, and a trout is a fish, can a trout walk?', '["Yes", "No", "Only on land", "Sometimes"]', 1, 'Since no fish can walk and a trout is a fish, a trout cannot walk', 2, '9-10'),
('verbal_reasoning', 'Logic', 'Anna is taller than Beth. Beth is taller than Clara. Clara is taller than Dana. Who is the shortest?', '["Anna", "Beth", "Clara", "Dana"]', 3, 'Following the chain: Anna > Beth > Clara > Dana, so Dana is the shortest', 2, '9-10'),
('verbal_reasoning', 'Logic', 'If some dogs are brown, and Rex is a dog, can we conclude Rex is brown?', '["Yes, definitely", "No, not necessarily", "Only if Rex is small", "Only if Rex barks"]', 1, '"Some dogs are brown" does not mean all dogs are brown, so we cannot be certain Rex is brown', 2, '9-10'),
('verbal_reasoning', 'Logic', 'If Maya arrives before Noah, and Noah arrives before Priya, who arrives last?', '["Maya", "Noah", "Priya", "Cannot tell"]', 2, 'Maya arrives before Noah, and Noah arrives before Priya, so Priya arrives last', 2, '9-10'),
('verbal_reasoning', 'Logic', 'If every student in the class passed the test except for two, and there are 28 students, how many passed?', '["24", "25", "26", "27"]', 2, '28 students minus 2 who did not pass leaves 26 who passed', 2, '9-10'),
('verbal_reasoning', 'Logic', 'If P implies Q, and Q implies R, and P is true, what can we conclude about R?', '["R is false", "R is true", "R is unrelated", "Cannot be determined"]', 1, 'Since P implies Q, and Q implies R, and P is true, then Q must be true, and so R must also be true', 3, '10-11'),
('verbal_reasoning', 'Logic', 'Five friends sit in a row. Eva is to the left of Finn. Finn is to the left of Gail. Who is in the middle?', '["Eva", "Finn", "Gail", "Cannot tell from this information alone"]', 3, 'We only know the order of three of the five friends relative to each other, not their exact positions in the row of five, so the middle person cannot be determined', 3, '10-11'),
('verbal_reasoning', 'Logic', 'If all members of the chess club play strategically, and Leo plays strategically, is Leo definitely in the chess club?', '["Yes, definitely", "No, not necessarily", "Only if Leo wins", "Only on Tuesdays"]', 1, 'Playing strategically does not prove someone is in the chess club — other people may also play strategically without being members', 3, '10-11'),
('verbal_reasoning', 'Logic', 'A box contains only red and blue balls. If a ball is not red, what must it be?', '["Green", "Blue", "Yellow", "Cannot tell"]', 1, 'Since the box only contains red and blue balls, any ball that is not red must be blue', 3, '10-11'),
('verbal_reasoning', 'Logic', 'If every triangle has 3 sides, and shape X has 3 sides, is shape X definitely a triangle?', '["Yes, definitely", "No, it could be a different shape", "Only if it is equilateral", "Cannot tell"]', 0, 'A triangle is defined as any closed shape with exactly 3 straight sides, so any shape with 3 sides is, by definition, a triangle', 3, '10-11'),

-- ═══════════════════════════════════════════════════════════════════════
-- CLASSIFICATION (15)
-- ═══════════════════════════════════════════════════════════════════════
('verbal_reasoning', 'Classification', 'Which word belongs with: Apple, Banana, Orange?', '["Carrot", "Grape", "Potato", "Onion"]', 1, 'Grape is a fruit, like Apple, Banana, and Orange. The others are vegetables', 1, '8-9'),
('verbal_reasoning', 'Classification', 'Which word does not belong: Car, Bus, Train, Tree?', '["Car", "Bus", "Train", "Tree"]', 3, 'Tree is a plant, not a form of transport like the other three', 1, '8-9'),
('verbal_reasoning', 'Classification', 'Which word belongs with: Square, Triangle, Circle?', '["Pentagon", "Cube", "Sphere", "Cylinder"]', 0, 'Pentagon is a 2D shape, like Square, Triangle, and Circle. The others are 3D shapes', 1, '8-9'),
('verbal_reasoning', 'Classification', 'Which word does not belong: Happy, Joyful, Cheerful, Tired?', '["Happy", "Joyful", "Cheerful", "Tired"]', 3, 'Happy, Joyful, and Cheerful all describe feeling good. Tired describes a different state', 1, '8-9'),
('verbal_reasoning', 'Classification', 'Which word belongs with: Salmon, Trout, Cod?', '["Whale", "Dolphin", "Tuna", "Octopus"]', 2, 'Tuna is a fish, like Salmon, Trout, and Cod. The others are not classified as fish', 1, '8-9'),
('verbal_reasoning', 'Classification', 'Which word does not belong: Violin, Guitar, Piano, Drum?', '["Violin", "Guitar", "Piano", "Drum"]', 3, 'Violin, Guitar, and Piano are all string instruments. Drum is a percussion instrument', 2, '9-10'),
('verbal_reasoning', 'Classification', 'Which word belongs with: Whisper, Murmur, Mutter?', '["Shout", "Mumble", "Sing", "Roar"]', 1, 'Mumble fits with Whisper, Murmur, and Mutter, as all describe speaking quietly or unclearly', 2, '9-10'),
('verbal_reasoning', 'Classification', 'Which word does not belong: Oak, Pine, Maple, Rose?', '["Oak", "Pine", "Maple", "Rose"]', 3, 'Oak, Pine, and Maple are all trees. Rose is a flowering shrub, not a tree', 2, '9-10'),
('verbal_reasoning', 'Classification', 'Which word belongs with: Democracy, Monarchy, Republic?', '["Dictatorship", "Election", "Vote", "Government"]', 0, 'Dictatorship fits with Democracy, Monarchy, and Republic, as all are types of governing systems', 2, '9-10'),
('verbal_reasoning', 'Classification', 'Which word does not belong: Sonnet, Haiku, Novel, Limerick?', '["Sonnet", "Haiku", "Novel", "Limerick"]', 2, 'Sonnet, Haiku, and Limerick are all forms of poetry. Novel is a long work of prose fiction', 2, '9-10'),
('verbal_reasoning', 'Classification', 'Which word belongs with: Comedy, Tragedy, Satire?', '["Genre", "Poetry", "Farce", "Author"]', 2, 'Farce fits with Comedy, Tragedy, and Satire, as all four are types (genres) of dramatic or literary work', 3, '10-11'),
('verbal_reasoning', 'Classification', 'Which word does not belong: Mammal, Reptile, Amphibian, Carnivore?', '["Mammal", "Reptile", "Amphibian", "Carnivore"]', 3, 'Mammal, Reptile, and Amphibian classify animals by biological type. Carnivore classifies animals by diet, a different category', 3, '10-11'),
('verbal_reasoning', 'Classification', 'Which word belongs with: Empathy, Sympathy, Compassion?', '["Apathy", "Kindness", "Logic", "Anger"]', 1, 'Kindness fits with Empathy, Sympathy, and Compassion, as all relate to caring about others'' feelings', 3, '10-11'),
('verbal_reasoning', 'Classification', 'Which word does not belong: Photosynthesis, Respiration, Digestion, Gravity?', '["Photosynthesis", "Respiration", "Digestion", "Gravity"]', 3, 'Photosynthesis, Respiration, and Digestion are all biological processes occurring within living things. Gravity is a physical force, not a biological process', 3, '10-11'),
('verbal_reasoning', 'Classification', 'Which word belongs with: Allegory, Metaphor, Symbolism?', '["Grammar", "Imagery", "Spelling", "Punctuation"]', 1, 'Imagery fits with Allegory, Metaphor, and Symbolism, as all are literary techniques used to convey deeper meaning', 3, '10-11'),

-- ═══════════════════════════════════════════════════════════════════════
-- WORD PATTERNS (15)
-- ═══════════════════════════════════════════════════════════════════════
('verbal_reasoning', 'Word Patterns', 'Which word can be made by rearranging the letters of "TEA"?', '["EAT", "ATE", "Both EAT and ATE", "TAE"]', 2, 'Both "EAT" and "ATE" use exactly the same letters as "TEA" rearranged', 1, '8-9'),
('verbal_reasoning', 'Word Patterns', 'Which word hides inside "CARPET"?', '["CAR", "PET", "Both CAR and PET", "ART"]', 2, '"CARPET" contains both "CAR" at the start and "PET" at the end', 1, '8-9'),
('verbal_reasoning', 'Word Patterns', 'Which word rhymes with "CAT"?', '["DOG", "HAT", "CUP", "RUN"]', 1, '"HAT" rhymes with "CAT" — both end in the same "-at" sound', 1, '8-9'),
('verbal_reasoning', 'Word Patterns', 'Which two words can be joined to make a compound word: SUN + ___?', '["FLOWER", "MOON", "STAR", "SKY"]', 0, '"SUN" + "FLOWER" makes "SUNFLOWER", a real compound word', 1, '8-9'),
('verbal_reasoning', 'Word Patterns', 'Which word hides inside "SHIPMENT"?', '["SHIP", "MEN", "Both SHIP and MEN", "TENT"]', 2, '"SHIPMENT" contains "SHIP" at the start and "MEN" within the middle/end portion', 1, '8-9'),
('verbal_reasoning', 'Word Patterns', 'Which word can be formed by rearranging the letters of "LISTEN"?', '["SILENT", "TINSEL", "Both SILENT and TINSEL", "LINTEN"]', 2, '"LISTEN" is an anagram of both "SILENT" and "TINSEL" — all three use exactly the same six letters', 2, '9-10'),
('verbal_reasoning', 'Word Patterns', 'Which word hides inside "GRANDMOTHER"?', '["GRAND", "MOTHER", "Both GRAND and MOTHER", "ROTHER"]', 2, '"GRANDMOTHER" contains both "GRAND" and "MOTHER" joined together', 2, '9-10'),
('verbal_reasoning', 'Word Patterns', 'Which word is an anagram of "STARE"?', '["RATES", "TEARS", "Both RATES and TEARS", "STERA"]', 2, '"STARE" can be rearranged into both "RATES" and "TEARS", using exactly the same five letters', 2, '9-10'),
('verbal_reasoning', 'Word Patterns', 'Which prefix means "not" when added to a word, as in "unhappy"?', '["Re-", "Un-", "Pre-", "Sub-"]', 1, 'The prefix "un-" reverses or negates meaning, as in "unhappy" meaning not happy', 2, '9-10'),
('verbal_reasoning', 'Word Patterns', 'What word is formed by adding the suffix "-less" to "care"?', '["Careful", "Caring", "Careless", "Carely"]', 2, 'Adding "-less" to "care" forms "careless", meaning without care — the suffix "-less" means "without"', 2, '9-10'),
('verbal_reasoning', 'Word Patterns', 'Which word is an anagram of "ASTRONOMER" hidden within a longer phrase pattern: rearranging gives which two-word phrase?', '["MOON STARER", "STAR MOONER", "ROOM ASTEN", "TARO ROSEMEN"]', 0, '"ASTRONOMER" rearranges exactly into "MOON STARER" — both use the identical set of letters', 3, '10-11'),
('verbal_reasoning', 'Word Patterns', 'Which two smaller words combine to form "UNDERSTAND"?', '["UNDER and STAND", "UNDO and STAND", "UNDER and STARTED", "UNDID and STAND"]', 0, '"UNDERSTAND" is a compound word formed by joining "UNDER" and "STAND"', 3, '10-11'),
('verbal_reasoning', 'Word Patterns', 'Which word is an anagram of "STREAM"?', '["MASTER", "TAMERS", "Both MASTER and TAMERS", "STEMAR"]', 2, '"STREAM" can be rearranged into both "MASTER" and "TAMERS" — all three use exactly the same six letters', 3, '10-11'),
('verbal_reasoning', 'Word Patterns', 'Which suffix correctly turns "act" into a noun meaning "the process of doing something"?', '["-ation, giving ACTATION", "-ion, giving ACTION", "-ment, giving ACTMENT", "-ure, giving ACTURE"]', 1, 'Adding "-ion" to "act" correctly forms "action", a real noun. The other suffix combinations do not form real words', 3, '10-11'),
('verbal_reasoning', 'Word Patterns', 'Which word is an anagram of "EARTH"?', '["HEART", "RATHE", "Both HEART and RATHE", "THARE"]', 0, '"EARTH" rearranges into "HEART" using exactly the same five letters. "RATHE" is not a standard English word', 3, '10-11')

ON CONFLICT DO NOTHING;
