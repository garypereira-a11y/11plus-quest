/*
# 11+ Quest: Vocabulary Question Bank Expansion

Adds 105 new vocabulary questions (15 per topic × 7 topics), even spread
across difficulty 1/2/3 (5 each per topic), spanning Year 3-6 ability range.

Purely additive — existing seed questions (migration 002) are untouched.
correct_answer uses the integer index format (0-3) into `options`.
Word choices for synonym/antonym questions were deliberately selected to
avoid contested or multiple-valid-answer pairings.
*/

INSERT INTO questions (category, topic, question_text, options, correct_answer, explanation, difficulty, age_range) VALUES

-- ═══════════════════════════════════════════════════════════════════════
-- DEFINITIONS (15)
-- ═══════════════════════════════════════════════════════════════════════
('vocabulary', 'Definitions', 'What does "enormous" mean?', '["Very small", "Very large", "Very fast", "Very quiet"]', 1, 'Enormous means extremely large in size', 1, '8-9'),
('vocabulary', 'Definitions', 'What does "ancient" mean?', '["Brand new", "Very old", "Very fast", "Very tall"]', 1, 'Ancient means existing from a very long time ago', 1, '8-9'),
('vocabulary', 'Definitions', 'What does "fragile" mean?', '["Very strong", "Easily broken", "Very heavy", "Very colourful"]', 1, 'Fragile describes something delicate that can break easily', 1, '8-9'),
('vocabulary', 'Definitions', 'What does "exhausted" mean?', '["Very excited", "Extremely tired", "Very hungry", "Very confused"]', 1, 'Exhausted means extremely tired or worn out', 1, '8-9'),
('vocabulary', 'Definitions', 'What does "generous" mean?', '["Selfish and mean", "Willing to give and share", "Very quiet", "Always late"]', 1, 'Generous means willing to give freely and share with others', 1, '8-9'),
('vocabulary', 'Definitions', 'What does "reluctant" mean?', '["Eager and willing", "Unwilling or hesitant", "Very confident", "Extremely happy"]', 1, 'Reluctant describes feeling unwilling or hesitant to do something', 2, '9-10'),
('vocabulary', 'Definitions', 'What does "meticulous" mean?', '["Careless and sloppy", "Very careful and precise", "Quick and rushed", "Loud and noisy"]', 1, 'Meticulous means showing great care and attention to detail', 2, '9-10'),
('vocabulary', 'Definitions', 'What does "ambiguous" mean?', '["Perfectly clear", "Having more than one possible meaning", "Very loud", "Extremely simple"]', 1, 'Ambiguous describes something unclear or open to more than one interpretation', 2, '9-10'),
('vocabulary', 'Definitions', 'What does "persistent" mean?', '["Giving up easily", "Continuing firmly despite difficulty", "Always confused", "Very forgetful"]', 1, 'Persistent means continuing to try, even when faced with difficulty or opposition', 2, '9-10'),
('vocabulary', 'Definitions', 'What does "scarce" mean?', '["Plentiful and common", "In short supply", "Very expensive only", "Brand new"]', 1, 'Scarce means in short supply or hard to find', 2, '9-10'),
('vocabulary', 'Definitions', 'What does "ephemeral" mean?', '["Lasting forever", "Lasting only a short time", "Extremely heavy", "Brightly coloured"]', 1, 'Ephemeral describes something that lasts only a brief time before disappearing', 3, '10-11'),
('vocabulary', 'Definitions', 'What does "candid" mean?', '["Dishonest and secretive", "Honest and straightforward", "Extremely shy", "Overly formal"]', 1, 'Candid means being open, honest, and direct in speech', 3, '10-11'),
('vocabulary', 'Definitions', 'What does "resilient" mean?', '["Easily defeated", "Able to recover quickly from difficulties", "Very stubborn", "Always anxious"]', 1, 'Resilient describes the ability to recover quickly from difficult situations', 3, '10-11'),
('vocabulary', 'Definitions', 'What does "futile" mean?', '["Highly effective", "Pointless or useless", "Extremely fast", "Very expensive"]', 1, 'Futile means having no useful result; pointless', 3, '10-11'),
('vocabulary', 'Definitions', 'What does "benevolent" mean?', '["Cruel and unkind", "Kind and well-meaning", "Very secretive", "Extremely lazy"]', 1, 'Benevolent describes someone who is kind, generous, and well-meaning towards others', 3, '10-11'),

-- ═══════════════════════════════════════════════════════════════════════
-- SYNONYMS (15)
-- ═══════════════════════════════════════════════════════════════════════
('vocabulary', 'Synonyms', 'Which word means the same as "happy"?', '["Sad", "Joyful", "Angry", "Tired"]', 1, 'Joyful is a synonym of happy — both describe a feeling of pleasure', 1, '8-9'),
('vocabulary', 'Synonyms', 'Which word means the same as "big"?', '["Tiny", "Huge", "Narrow", "Short"]', 1, 'Huge is a synonym of big — both describe something large in size', 1, '8-9'),
('vocabulary', 'Synonyms', 'Which word means the same as "begin"?', '["End", "Finish", "Start", "Stop"]', 2, 'Start is a synonym of begin — both mean to commence something', 1, '8-9'),
('vocabulary', 'Synonyms', 'Which word means the same as "quick"?', '["Slow", "Rapid", "Careful", "Late"]', 1, 'Rapid is a synonym of quick — both describe fast movement or speed', 1, '8-9'),
('vocabulary', 'Synonyms', 'Which word means the same as "scared"?', '["Brave", "Afraid", "Calm", "Excited"]', 1, 'Afraid is a synonym of scared — both describe feeling fear', 1, '8-9'),
('vocabulary', 'Synonyms', 'Which word means the same as "difficult"?', '["Easy", "Simple", "Challenging", "Quick"]', 2, 'Challenging is a synonym of difficult — both describe something hard to do', 2, '9-10'),
('vocabulary', 'Synonyms', 'Which word means the same as "strange"?', '["Normal", "Peculiar", "Familiar", "Boring"]', 1, 'Peculiar is a synonym of strange — both describe something unusual', 2, '9-10'),
('vocabulary', 'Synonyms', 'Which word means the same as "brave"?', '["Cowardly", "Courageous", "Nervous", "Weak"]', 1, 'Courageous is a synonym of brave — both describe facing danger without fear', 2, '9-10'),
('vocabulary', 'Synonyms', 'Which word means the same as "huge"?', '["Minuscule", "Immense", "Average", "Slight"]', 1, 'Immense is a synonym of huge — both describe something extremely large', 2, '9-10'),
('vocabulary', 'Synonyms', 'Which word means the same as "angry"?', '["Calm", "Furious", "Content", "Relaxed"]', 1, 'Furious is a synonym of angry — both describe strong feelings of displeasure', 2, '9-10'),
('vocabulary', 'Synonyms', 'Which word means the same as "obsolete"?', '["Modern", "Outdated", "Useful", "Popular"]', 1, 'Outdated is a synonym of obsolete — both describe something no longer in use', 3, '10-11'),
('vocabulary', 'Synonyms', 'Which word means the same as "concise"?', '["Lengthy", "Brief", "Confusing", "Repetitive"]', 1, 'Brief is a synonym of concise — both describe something expressed in few words', 3, '10-11'),
('vocabulary', 'Synonyms', 'Which word means the same as "diligent"?', '["Lazy", "Hardworking", "Careless", "Forgetful"]', 1, 'Hardworking is a synonym of diligent — both describe someone who puts in careful, steady effort', 3, '10-11'),
('vocabulary', 'Synonyms', 'Which word means the same as "vivid"?', '["Dull", "Vibrant", "Faint", "Plain"]', 1, 'Vibrant is a synonym of vivid — both describe something bright, intense, or striking', 3, '10-11'),
('vocabulary', 'Synonyms', 'Which word means the same as "tedious"?', '["Exciting", "Monotonous", "Brief", "Pleasant"]', 1, 'Monotonous is a synonym of tedious — both describe something boring due to being repetitive', 3, '10-11'),

-- ═══════════════════════════════════════════════════════════════════════
-- ANTONYMS (15)
-- ═══════════════════════════════════════════════════════════════════════
('vocabulary', 'Antonyms', 'Which word is the opposite of "hot"?', '["Warm", "Cold", "Mild", "Boiling"]', 1, 'Cold is the opposite (antonym) of hot', 1, '8-9'),
('vocabulary', 'Antonyms', 'Which word is the opposite of "loud"?', '["Noisy", "Quiet", "Busy", "Fast"]', 1, 'Quiet is the opposite of loud — it means making little or no sound', 1, '8-9'),
('vocabulary', 'Antonyms', 'Which word is the opposite of "full"?', '["Empty", "Heavy", "Large", "Round"]', 0, 'Empty is the opposite of full — it means containing nothing', 1, '8-9'),
('vocabulary', 'Antonyms', 'Which word is the opposite of "open"?', '["Wide", "Closed", "Visible", "Bright"]', 1, 'Closed is the opposite of open', 1, '8-9'),
('vocabulary', 'Antonyms', 'Which word is the opposite of "above"?', '["Below", "Beside", "Beyond", "Around"]', 0, 'Below is the opposite of above', 1, '8-9'),
('vocabulary', 'Antonyms', 'Which word is the opposite of "generous"?', '["Kind", "Selfish", "Helpful", "Caring"]', 1, 'Selfish is the opposite of generous — selfish people keep things for themselves rather than sharing', 2, '9-10'),
('vocabulary', 'Antonyms', 'Which word is the opposite of "expand"?', '["Grow", "Shrink", "Stretch", "Increase"]', 1, 'Shrink is the opposite of expand — to expand is to grow larger, to shrink is to become smaller', 2, '9-10'),
('vocabulary', 'Antonyms', 'Which word is the opposite of "confident"?', '["Bold", "Insecure", "Proud", "Strong"]', 1, 'Insecure is the opposite of confident — it describes feeling unsure of oneself', 2, '9-10'),
('vocabulary', 'Antonyms', 'Which word is the opposite of "permanent"?', '["Lasting", "Temporary", "Solid", "Fixed"]', 1, 'Temporary is the opposite of permanent — it describes something that does not last', 2, '9-10'),
('vocabulary', 'Antonyms', 'Which word is the opposite of "abundant"?', '["Plentiful", "Scarce", "Common", "Wealthy"]', 1, 'Scarce is the opposite of abundant — abundant means plentiful, scarce means in short supply', 2, '9-10'),
('vocabulary', 'Antonyms', 'Which word is the opposite of "transparent"?', '["Clear", "Opaque", "Visible", "Glassy"]', 1, 'Opaque is the opposite of transparent — transparent means you can see through it, opaque means you cannot', 3, '10-11'),
('vocabulary', 'Antonyms', 'Which word is the opposite of "humble"?', '["Modest", "Arrogant", "Shy", "Quiet"]', 1, 'Arrogant is the opposite of humble — humble means modest, arrogant means having an exaggerated sense of importance', 3, '10-11'),
('vocabulary', 'Antonyms', 'Which word is the opposite of "voluntary"?', '["Optional", "Compulsory", "Willing", "Free"]', 1, 'Compulsory is the opposite of voluntary — voluntary means by choice, compulsory means required', 3, '10-11'),
('vocabulary', 'Antonyms', 'Which word is the opposite of "genuine"?', '["Authentic", "Fake", "Honest", "Real"]', 1, 'Fake is the opposite of genuine — genuine means real and authentic, fake means not real', 3, '10-11'),
('vocabulary', 'Antonyms', 'Which word is the opposite of "cautious"?', '["Careful", "Reckless", "Wary", "Watchful"]', 1, 'Reckless is the opposite of cautious — cautious means careful, reckless means acting without thinking of consequences', 3, '10-11'),

-- ═══════════════════════════════════════════════════════════════════════
-- CONTEXT CLUES (15)
-- ═══════════════════════════════════════════════════════════════════════
('vocabulary', 'Context Clues', '"The puppy was so tiny it fit in my hand." What does "tiny" mean here?', '["Very large", "Very small", "Very loud", "Very fast"]', 1, 'The context (fitting in a hand) shows that "tiny" means very small', 1, '8-9'),
('vocabulary', 'Context Clues', '"After running the race, Sam was drenched in sweat." What does "drenched" mean?', '["Completely dry", "Completely soaked", "Slightly damp", "Very cold"]', 1, 'Running a race and sweating heavily suggests "drenched" means completely soaked', 1, '8-9'),
('vocabulary', 'Context Clues', '"The old bridge creaked and wobbled as I crossed it." What does "wobbled" suggest about the bridge?', '["It was very strong", "It was unstable and shaky", "It was brand new", "It was painted blue"]', 1, '"Creaked" and "wobbled" together suggest the bridge was unstable and shaky', 1, '8-9'),
('vocabulary', 'Context Clues', '"The classroom was silent except for the ticking clock." What does this tell us about the noise level?', '["It was extremely loud", "It was very quiet", "It was moderately noisy", "It was chaotic"]', 1, '"Silent except for" the clock''s ticking shows the room was very quiet', 1, '8-9'),
('vocabulary', 'Context Clues', '"The hungry lion prowled around the empty cage, searching for food." What does "prowled" suggest?', '["The lion was sleeping", "The lion was moving around restlessly", "The lion was sitting still", "The lion was eating"]', 1, '"Prowled... searching for food" suggests restless, watchful movement', 1, '8-9'),
('vocabulary', 'Context Clues', '"Despite the storm raging outside, the captain remained stoic at the helm." What does "stoic" most likely mean?', '["Panicked and frightened", "Calm and unaffected by hardship", "Loud and dramatic", "Confused and lost"]', 1, '"Despite the storm" and remaining at the helm suggests the captain stayed calm under pressure', 2, '9-10'),
('vocabulary', 'Context Clues', '"The detective scrutinised every clue, determined not to miss a single detail." What does "scrutinised" mean?', '["Ignored completely", "Examined closely and carefully", "Threw away", "Glanced at briefly"]', 1, '"Determined not to miss a single detail" suggests careful, close examination', 2, '9-10'),
('vocabulary', 'Context Clues', '"The crowd dispersed quickly once the rain began to fall." What does "dispersed" mean?', '["Gathered together", "Scattered and moved away", "Stood still", "Cheered loudly"]', 1, 'People moving away once rain began suggests the crowd scattered, or dispersed', 2, '9-10'),
('vocabulary', 'Context Clues', '"The ancient manuscript was so fragile that the librarian wore gloves to handle it." What does "fragile" suggest about the manuscript?', '["It was very valuable but indestructible", "It could easily be damaged", "It was made of metal", "It was recently printed"]', 1, 'Needing gloves to handle it suggests the manuscript could easily be damaged', 2, '9-10'),
('vocabulary', 'Context Clues', '"His relentless questioning eventually wore down her patience." What does "relentless" suggest?', '["Occasional and brief", "Continuous and persistent", "Quiet and gentle", "Confused and random"]', 1, '"Eventually wore down her patience" suggests the questioning was continuous and persistent', 2, '9-10'),
('vocabulary', 'Context Clues', '"The negotiations were fraught with tension, as neither side would compromise." What does "fraught" suggest?', '["Filled with calm agreement", "Filled with difficulty or tension", "Completely finished", "Entirely one-sided"]', 1, '"Neither side would compromise" supports that the negotiations were filled with tension', 3, '10-11'),
('vocabulary', 'Context Clues', '"Her terse reply made it clear she did not want to discuss the matter further." What does "terse" suggest?', '["Long and detailed", "Short and curt", "Friendly and warm", "Confused and rambling"]', 1, '"Made it clear she did not want to discuss" suggests a short, curt reply', 3, '10-11'),
('vocabulary', 'Context Clues', '"The committee''s decision was unanimous, with not a single dissenting voice." What does "unanimous" mean?', '["Everyone agreed", "Everyone disagreed", "Only one person voted", "No one voted"]', 0, '"Not a single dissenting voice" means everyone agreed, which is what "unanimous" means', 3, '10-11'),
('vocabulary', 'Context Clues', '"The explorer''s account of the journey was so vivid that readers felt they were there themselves." What does "vivid" suggest?', '["Dull and lifeless", "Extremely vague", "Clear and richly detailed", "Very short"]', 2, 'Readers feeling like they were there themselves suggests the writing was clear and richly detailed', 3, '10-11'),
('vocabulary', 'Context Clues', '"Despite the criticism, she remained undeterred and continued her research." What does "undeterred" mean?', '["Discouraged and gave up", "Not discouraged; continuing anyway", "Confused about what to do", "Completely unaware of the criticism"]', 1, '"Continued her research" despite criticism shows she was not discouraged — undeterred', 3, '10-11'),

-- ═══════════════════════════════════════════════════════════════════════
-- WORD FAMILIES (15)
-- ═══════════════════════════════════════════════════════════════════════
('vocabulary', 'Word Families', 'Which word belongs to the same family as "happy"?', '["Happiness", "Hopeful", "Hungry", "Healthy"]', 0, '"Happiness" shares the root "happ-" with "happy" and is its noun form', 1, '8-9'),
('vocabulary', 'Word Families', 'Which word belongs to the same family as "act"?', '["Active", "Apple", "Animal", "Window"]', 0, '"Active" shares the root "act" with "act" and describes something that does or performs actions', 1, '8-9'),
('vocabulary', 'Word Families', 'Which word belongs to the same family as "teach"?', '["Teacher", "Reach", "Beach", "Speech"]', 0, '"Teacher" shares the root "teach" with "teach" and means someone who teaches', 1, '8-9'),
('vocabulary', 'Word Families', 'Which word belongs to the same family as "play"?', '["Player", "Stay", "Clay", "Tray"]', 0, '"Player" shares the root "play" with "play" and means someone who plays', 1, '8-9'),
('vocabulary', 'Word Families', 'Which word belongs to the same family as "create"?', '["Creation", "Crate", "Great", "Plate"]', 0, '"Creation" shares the root "creat-" with "create" and is its noun form', 1, '8-9'),
('vocabulary', 'Word Families', 'Which word belongs to the same family as "decide"?', '["Decision", "Provide", "Inside", "Beside"]', 0, '"Decision" shares the root "decid-" with "decide" and is its noun form', 2, '9-10'),
('vocabulary', 'Word Families', 'Which word belongs to the same family as "able"?', '["Ability", "Table", "Cable", "Stable"]', 0, '"Ability" shares the root "abil-" with "able" and is its noun form', 2, '9-10'),
('vocabulary', 'Word Families', 'Which word belongs to the same family as "wise"?', '["Wisdom", "Rise", "Prize", "Surprise"]', 0, '"Wisdom" shares the root "wis-" with "wise" and means the quality of being wise', 2, '9-10'),
('vocabulary', 'Word Families', 'Which word belongs to the same family as "react"?', '["Reaction", "Fraction", "Traction", "Faction"]', 0, '"Reaction" shares the root "react" with "react" and is its noun form. The other words only sound similar — they come from entirely different roots', 2, '9-10'),
('vocabulary', 'Word Families', 'Which word belongs to the same family as "appear"?', '["Appearance", "Pear", "Bear", "Tear"]', 0, '"Appearance" shares the root "appear" with "appear" and is its noun form', 2, '9-10'),
('vocabulary', 'Word Families', 'Which word belongs to the same family as "courage"?', '["Courageous", "Garage", "Storage", "Voyage"]', 0, '"Courageous" shares the root "courage" with "courage" and is its adjective form', 3, '10-11'),
('vocabulary', 'Word Families', 'Which word belongs to the same family as "construct"?', '["Construction", "Instruct", "Obstruct", "Destruct"]', 0, '"Construction" shares the exact root "construct" with "construct" and is its noun form. The other words look similar but come from different root meanings', 3, '10-11'),
('vocabulary', 'Word Families', 'Which word belongs to the same family as "responsible"?', '["Responsibility", "Possible", "Sensible", "Visible"]', 0, '"Responsibility" shares the root "respons-" with "responsible" and is its noun form', 3, '10-11'),
('vocabulary', 'Word Families', 'Which word belongs to the same family as "critic"?', '["Criticism", "Magic", "Music", "Logic"]', 0, '"Criticism" shares the root "critic" with "critic" and describes the practice or act of judging', 3, '10-11'),
('vocabulary', 'Word Families', 'Which word belongs to the same family as "memory"?', '["Memorial", "Factory", "Territory", "Category"]', 0, '"Memorial" shares the root "memor-" with "memory" and relates to remembering', 3, '10-11'),

-- ═══════════════════════════════════════════════════════════════════════
-- SPELLING (15)
-- ═══════════════════════════════════════════════════════════════════════
('vocabulary', 'Spelling', 'Which word is spelled correctly?', '["Recieve", "Receive", "Receeve", "Recive"]', 1, 'Remember the rule: i before e, except after c. R-e-c-e-i-v-e', 1, '8-9'),
('vocabulary', 'Spelling', 'Which word is spelled correctly?', '["Goverment", "Government", "Govermant", "Goverenment"]', 1, '"Government" includes an "n" before "ment" — gover-n-ment', 1, '8-9'),
('vocabulary', 'Spelling', 'Which word is spelled correctly?', '["Enviroment", "Environment", "Envirnoment", "Enviornment"]', 1, '"Environment" includes an "n" before "ment" — environ-ment', 1, '8-9'),
('vocabulary', 'Spelling', 'Which word is spelled correctly?', '["Calender", "Calandar", "Calendar", "Calander"]', 2, '"Calendar" ends in "-ar", not "-er" or "-or"', 1, '8-9'),
('vocabulary', 'Spelling', 'Which word is spelled correctly?', '["Tommorow", "Tomorow", "Tommorrow", "Tomorrow"]', 3, '"Tomorrow" has one "m" and two "r"s', 1, '8-9'),
('vocabulary', 'Spelling', 'Which word is spelled correctly?', '["Independant", "Independent", "Indipendent", "Independdent"]', 1, '"Independent" ends in "-ent", not "-ant"', 2, '9-10'),
('vocabulary', 'Spelling', 'Which word is spelled correctly?', '["Particularly", "Particurly", "Particullarly", "Particulary"]', 0, '"Particularly" includes both "ar" syllables — par-ticu-lar-ly', 2, '9-10'),
('vocabulary', 'Spelling', 'Which word is spelled correctly?', '["Recommend", "Recomend", "Reccomend", "Recommand"]', 0, '"Recommend" has a double "m" but a single "c"', 2, '9-10'),
('vocabulary', 'Spelling', 'Which word is spelled correctly?', '["Occurred", "Occured", "Ocurred", "Occurrred"]', 0, '"Occurred" has a double "c" and a double "r"', 2, '9-10'),
('vocabulary', 'Spelling', 'Which word is spelled correctly?', '["Acheive", "Achieve", "Acheeve", "Acihieve"]', 1, '"Achieve" follows "i before e" — ach-i-e-ve', 2, '9-10'),
('vocabulary', 'Spelling', 'Which word is spelled correctly?', '["Questionnaire", "Questionaire", "Questionnair", "Questionaires"]', 0, '"Questionnaire" has a double "n" — questi-onn-aire', 3, '10-11'),
('vocabulary', 'Spelling', 'Which word is spelled correctly?', '["Pronunciation", "Pronounciation", "Pronunciaton", "Pronnunciation"]', 0, '"Pronunciation" drops the "o" that appears in "pronounce" — a common spelling trap', 3, '10-11'),
('vocabulary', 'Spelling', 'Which word is spelled correctly?', '["Liaison", "Liason", "Liaision", "Liasion"]', 0, '"Liaison" has the pattern "ai" then "i" — lia-i-son', 3, '10-11'),
('vocabulary', 'Spelling', 'Which word is spelled correctly?', '["Bureaucracy", "Beurocracy", "Bureacracy", "Beaurocracy"]', 0, '"Bureaucracy" follows the French-origin spelling "eau" — bur-eau-cracy', 3, '10-11'),
('vocabulary', 'Spelling', 'Which word is spelled correctly?', '["Miscellaneous", "Miscelaneous", "Miscellaneus", "Miscellanous"]', 0, '"Miscellaneous" has a double "l" and ends in "-eous"', 3, '10-11'),

-- ═══════════════════════════════════════════════════════════════════════
-- WORD USAGE (15)
-- ═══════════════════════════════════════════════════════════════════════
('vocabulary', 'Word Usage', 'Which word correctly completes: "I need to ___ my homework before dinner."', '["Effect", "Affect", "Complete", "Compose"]', 2, '"Complete" correctly fits the context of finishing homework', 1, '8-9'),
('vocabulary', 'Word Usage', 'Which word correctly completes: "She felt ___ after winning the race."', '["Disappointed", "Triumphant", "Confused", "Bored"]', 1, '"Triumphant" correctly fits the context of feeling victorious after winning', 1, '8-9'),
('vocabulary', 'Word Usage', 'Which word correctly completes: "The weather was so ___ that we cancelled the picnic."', '["Sunny", "Stormy", "Pleasant", "Mild"]', 1, '"Stormy" fits best with the context of cancelling a picnic due to bad weather', 1, '8-9'),
('vocabulary', 'Word Usage', 'Which word correctly completes: "He was too ___ to lift the heavy box alone."', '["Strong", "Weak", "Tall", "Happy"]', 1, '"Weak" fits the context of being unable to lift something heavy alone', 1, '8-9'),
('vocabulary', 'Word Usage', 'Which word correctly completes: "The library was ___, so we could concentrate on our work."', '["Noisy", "Quiet", "Crowded", "Messy"]', 1, '"Quiet" fits the context of being able to concentrate', 1, '8-9'),
('vocabulary', 'Word Usage', 'Which word correctly completes: "Her explanation was so ___ that nobody understood it."', '["Clear", "Confusing", "Simple", "Brief"]', 1, '"Confusing" fits the context of nobody understanding the explanation', 2, '9-10'),
('vocabulary', 'Word Usage', 'Which word correctly completes: "The ___ in air pressure caused the storm to weaken."', '["Increase", "Decrease", "Colour", "Sound"]', 1, '"Decrease" fits the meteorological context of a weakening storm', 2, '9-10'),
('vocabulary', 'Word Usage', 'Which word correctly completes: "His ___ remarks upset several people at the meeting."', '["Tactful", "Tactless", "Quiet", "Brief"]', 1, '"Tactless" fits the context of remarks that upset people', 2, '9-10'),
('vocabulary', 'Word Usage', 'Which word correctly completes: "The plan seemed ___ at first, but it failed completely."', '["Doomed", "Promising", "Boring", "Obvious"]', 1, '"Promising" fits the context of a plan that initially seemed good but later failed', 2, '9-10'),
('vocabulary', 'Word Usage', 'Which word correctly completes: "Their friendship grew ___ stronger over the years."', '["Increasingly", "Rarely", "Briefly", "Suddenly"]', 0, '"Increasingly" fits the context of something growing stronger over time', 2, '9-10'),
('vocabulary', 'Word Usage', 'Which word correctly completes: "The committee''s ___ approach delayed the final decision for months."', '["Decisive", "Indecisive", "Quick", "Confident"]', 1, '"Indecisive" fits the context of a decision being delayed for months', 3, '10-11'),
('vocabulary', 'Word Usage', 'Which word correctly completes: "Her ___ comments showed she had not prepared for the discussion."', '["Insightful", "Superficial", "Detailed", "Thoughtful"]', 1, '"Superficial" fits the context of comments that show a lack of preparation', 3, '10-11'),
('vocabulary', 'Word Usage', 'Which word correctly completes: "The negotiations reached an ___ after months of disagreement."', '["Impasse", "Agreement", "Celebration", "Solution"]', 0, '"Impasse" describes a situation where no agreement can be reached, fitting the context of months of unresolved disagreement', 3, '10-11'),
('vocabulary', 'Word Usage', 'Which word correctly completes: "His ___ attitude made him unpopular with his colleagues."', '["Affable", "Arrogant", "Modest", "Friendly"]', 1, '"Arrogant" fits the context of an attitude that made someone unpopular', 3, '10-11'),
('vocabulary', 'Word Usage', 'Which word correctly completes: "The scientist''s findings were ___ by further research."', '["Corroborated", "Ignored", "Forgotten", "Invented"]', 0, '"Corroborated" means confirmed or supported by additional evidence, fitting the context of findings being backed up by further research', 3, '10-11')

ON CONFLICT DO NOTHING;
