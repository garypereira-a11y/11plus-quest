/*
# 11+ Quest: Math Question Bank Expansion

Adds 120 new math questions (15 per topic × 8 topics), with an even spread
across difficulty 1/2/3 (5 each per topic), spanning Year 3-6 ability range.

This is part of building out enough per-topic, per-difficulty depth to
support in-test difficulty stepping (drop a level after a wrong answer,
climb back up after a correct one). Existing seed questions (migration 002)
are untouched — this is purely additive.

All correct_answer values use the integer index format (0-3) into `options`,
matching the preferred format documented in isCorrectOption() / supabase.ts.
*/

INSERT INTO questions (category, topic, question_text, options, correct_answer, explanation, difficulty, age_range) VALUES

-- ═══════════════════════════════════════════════════════════════════════
-- ARITHMETIC (15: 5×difficulty1, 5×difficulty2, 5×difficulty3)
-- ═══════════════════════════════════════════════════════════════════════
('math', 'Arithmetic', 'What is 23 + 19?', '["32", "42", "52", "62"]', 1, '23 + 19 = 42. Add the ones: 3 + 9 = 12, carry 1. Add the tens: 2 + 1 + 1 = 4. Total: 42', 1, '8-9'),
('math', 'Arithmetic', 'What is 54 - 28?', '["16", "26", "36", "46"]', 1, '54 - 28 = 26. Think: 54 - 30 = 24, then add back 2 (since we subtracted 2 too many): 24 + 2 = 26', 1, '8-9'),
('math', 'Arithmetic', 'What is 6 × 9?', '["45", "54", "63", "56"]', 1, '6 × 9 = 54. Remember: 6 × 10 = 60, then subtract one 6: 60 - 6 = 54', 1, '8-9'),
('math', 'Arithmetic', 'What is 81 ÷ 9?', '["7", "8", "9", "10"]', 2, '81 ÷ 9 = 9. Think: 9 × ? = 81. Since 9 × 9 = 81, the answer is 9', 1, '8-9'),
('math', 'Arithmetic', 'What is 7 + 8 + 5?', '["18", "19", "20", "21"]', 2, '7 + 8 + 5 = 20. Add 7 + 8 = 15 first, then 15 + 5 = 20', 1, '8-9'),
('math', 'Arithmetic', 'What is 134 + 257?', '["381", "391", "401", "411"]', 1, '134 + 257 = 391. Add the ones: 4+7=11 (carry 1). Tens: 3+5+1=9. Hundreds: 1+2=3. Result: 391', 2, '9-10'),
('math', 'Arithmetic', 'What is 500 - 173?', '["317", "327", "337", "347"]', 1, '500 - 173 = 327. Think: 500 - 200 = 300, then add back 27 (since 173 is 27 less than 200): 300 + 27 = 327', 2, '9-10'),
('math', 'Arithmetic', 'What is 12 × 13?', '["146", "156", "166", "176"]', 1, '12 × 13 = 156. Break it down: 12 × 10 = 120, and 12 × 3 = 36. Total: 120 + 36 = 156', 2, '9-10'),
('math', 'Arithmetic', 'What is 144 ÷ 12?', '["10", "11", "12", "13"]', 2, '144 ÷ 12 = 12. Think: 12 × 12 = 144, so the answer is 12', 2, '9-10'),
('math', 'Arithmetic', 'A school has 8 classes of 27 pupils each. How many pupils in total?', '["206", "216", "226", "236"]', 1, '8 × 27 = 216. Break it down: 8 × 20 = 160, and 8 × 7 = 56. Total: 160 + 56 = 216', 2, '9-10'),
('math', 'Arithmetic', 'What is 4,872 + 3,956?', '["8,728", "8,818", "8,828", "8,918"]', 2, '4,872 + 3,956 = 8,828. Add column by column right to left, carrying where needed: ones 2+6=8, tens 7+5=12 (carry 1), hundreds 8+9+1=18 (carry 1), thousands 4+3+1=8', 3, '9-10'),
('math', 'Arithmetic', 'What is 23 × 47?', '["1,071", "1,081", "1,091", "1,101"]', 0, '23 × 47 = 23 × 40 + 23 × 7 = 920 + 161 = 1,081', 3, '9-10'),
('math', 'Arithmetic', 'What is 8,064 ÷ 24?', '["322", "332", "336", "342"]', 2, '8,064 ÷ 24 = 336. Check: 24 × 336 = 24 × 300 + 24 × 36 = 7,200 + 864 = 8,064', 3, '9-10'),
('math', 'Arithmetic', 'A van delivers 156 parcels each day for 19 days. How many parcels in total?', '["2,864", "2,944", "3,964", "2,964"]', 3, '156 × 19 = 156 × 20 - 156 = 3,120 - 156 = 2,964', 3, '9-10'),
('math', 'Arithmetic', 'What is the missing number? 3,500 - ? = 1,245', '["2,155", "2,255", "2,355", "1,255"]', 1, '3,500 - 1,245 = 2,255. Check by adding back: 2,255 + 1,245 = 3,500', 3, '9-10'),

-- ═══════════════════════════════════════════════════════════════════════
-- FRACTIONS (15)
-- ═══════════════════════════════════════════════════════════════════════
('math', 'Fractions', 'What is 1/2 + 1/4?', '["1/4", "2/4", "3/4", "1"]', 2, 'Convert 1/2 to quarters: 1/2 = 2/4. Then 2/4 + 1/4 = 3/4', 1, '8-9'),
('math', 'Fractions', 'Which fraction is the same as 2/4?', '["1/3", "1/2", "1/5", "3/4"]', 1, '2/4 simplifies to 1/2 because both the top and bottom can be divided by 2', 1, '8-9'),
('math', 'Fractions', 'What is 3/5 of 10?', '["4", "5", "6", "7"]', 2, '3/5 of 10 means (10 ÷ 5) × 3. 10 ÷ 5 = 2, then 2 × 3 = 6', 1, '8-9'),
('math', 'Fractions', 'Which is bigger: 1/3 or 1/4?', '["1/3", "1/4", "They are equal", "Cannot tell"]', 0, '1/3 is bigger than 1/4. The smaller the bottom number (denominator), the bigger each piece is when the top number is the same', 1, '8-9'),
('math', 'Fractions', 'What is 2/3 - 1/3?', '["1/3", "2/3", "1", "3/3"]', 0, '2/3 - 1/3 = 1/3. When denominators match, just subtract the top numbers: 2 - 1 = 1', 1, '8-9'),
('math', 'Fractions', 'What is 3/4 + 1/8?', '["4/8", "5/8", "6/8", "7/8"]', 2, 'Convert 3/4 to eighths: 3/4 = 6/8. Then 6/8 + 1/8 = 7/8', 2, '9-10'),
('math', 'Fractions', 'What is 7/10 as a decimal?', '["0.07", "0.7", "7.0", "0.17"]', 1, '7/10 means 7 divided by 10, which is 0.7', 2, '9-10'),
('math', 'Fractions', 'What is 2/5 of 35?', '["10", "12", "14", "16"]', 2, '2/5 of 35: first find 1/5 of 35, which is 7 (35 ÷ 5). Then multiply by 2: 7 × 2 = 14', 2, '9-10'),
('math', 'Fractions', 'Simplify 8/12 to its lowest terms.', '["2/3", "3/4", "4/6", "1/2"]', 0, '8/12 simplifies to 2/3. Both numbers divide exactly by 4: 8÷4=2, 12÷4=3', 2, '9-10'),
('math', 'Fractions', 'What is 1 1/2 + 2 1/4?', '["3 1/4", "3 3/4", "4 1/4", "3 1/2"]', 1, 'Add the whole numbers: 1+2=3. Add the fractions: 1/2 + 1/4 = 2/4 + 1/4 = 3/4. Total: 3 3/4', 2, '9-10'),
('math', 'Fractions', 'What is 5/6 ÷ 1/3?', '["1/2", "2 1/2", "3 1/2", "5/18"]', 1, '5/6 ÷ 1/3 = 5/6 × 3/1 = 15/6 = 2 1/2. To divide by a fraction, multiply by its reciprocal (flip it)', 3, '10-11'),
('math', 'Fractions', 'What fraction of a kilogram is 350 grams?', '["1/4", "3/10", "7/20", "2/5"]', 2, '350g out of 1000g = 350/1000, which simplifies by dividing both by 50 to give 7/20', 3, '10-11'),
('math', 'Fractions', 'A recipe needs 2/3 cup of flour. If you make 4 batches, how much flour is needed?', '["2 cups", "2 1/3 cups", "2 2/3 cups", "3 cups"]', 2, '2/3 × 4 = 8/3 = 2 2/3 cups. Multiply the fraction by the number of batches, then convert to a mixed number', 3, '10-11'),
('math', 'Fractions', 'What is 3/4 of 5/6?', '["5/8", "8/10", "15/24", "5/24"]', 0, '3/4 × 5/6 = 15/24, which simplifies (divide top and bottom by 3) to 5/8', 3, '10-11'),
('math', 'Fractions', 'Which is closest to 1 whole: 5/6, 7/8, or 9/10?', '["5/6", "7/8", "9/10", "All equal"]', 2, '9/10 is closest to 1 because it is only 1/10 away from a whole, compared to 1/6 away and 1/8 away for the others', 3, '10-11'),

-- ═══════════════════════════════════════════════════════════════════════
-- PERCENTAGES (15)
-- ═══════════════════════════════════════════════════════════════════════
('math', 'Percentages', 'What is 10% of 50?', '["5", "10", "15", "20"]', 0, '10% means 1/10. 50 ÷ 10 = 5', 1, '8-9'),
('math', 'Percentages', 'What is 50% of 30?', '["10", "15", "20", "25"]', 1, '50% means half. Half of 30 is 15', 1, '8-9'),
('math', 'Percentages', 'What is 25% of 40?', '["8", "10", "12", "20"]', 1, '25% means a quarter. 40 ÷ 4 = 10', 1, '8-9'),
('math', 'Percentages', 'Which percentage matches the fraction 1/2?', '["25%", "50%", "75%", "100%"]', 1, '1/2 means one part out of two equal parts, which is the same as 50%', 1, '8-9'),
('math', 'Percentages', 'What is 100% of 67?', '["6.7", "67", "76", "670"]', 1, '100% means the whole amount, unchanged. 100% of 67 is just 67', 1, '8-9'),
('math', 'Percentages', 'What is 20% of 65?', '["10", "13", "15", "18"]', 1, '20% means 1/5. 65 ÷ 5 = 13', 2, '9-10'),
('math', 'Percentages', 'A jumper costs £40 and is reduced by 15%. What is the discount amount?', '["£4", "£6", "£8", "£10"]', 1, '15% of £40: 10% of 40 is 4, and 5% of 40 is 2 (half of 10%). 4 + 2 = £6', 2, '9-10'),
('math', 'Percentages', 'What percentage is 18 out of 40?', '["35%", "40%", "45%", "50%"]', 2, '18 out of 40 as a fraction is 18/40, which equals 45/100, so 45%', 2, '9-10'),
('math', 'Percentages', 'A class of 30 pupils has 60% who walk to school. How many pupils walk?', '["12", "16", "18", "20"]', 2, '60% of 30: 10% of 30 is 3, so 60% is 3 × 6 = 18', 2, '9-10'),
('math', 'Percentages', 'What is 75% of 120?', '["80", "85", "90", "95"]', 2, '75% means 3/4. 120 ÷ 4 = 30, then 30 × 3 = 90', 2, '9-10'),
('math', 'Percentages', 'A coat priced at £85 is reduced by 20%, then a further 10% off the new price. What is the final price?', '["£59.20", "£61.20", "£63.20", "£65.20"]', 1, '20% of £85 is £17, so the price drops to £85 - £17 = £68. Then 10% of £68 is £6.80, so the final price is £68 - £6.80 = £61.20', 3, '10-11'),
('math', 'Percentages', 'If a number increases from 80 to 100, what is the percentage increase?', '["20%", "25%", "30%", "80%"]', 1, 'Increase = 100 - 80 = 20. Percentage increase = 20/80 × 100 = 25%', 3, '10-11'),
('math', 'Percentages', 'A shop sells an item for £56, which is 140% of the cost price. What was the cost price?', '["£35", "£40", "£42", "£45"]', 1, 'If £56 is 140%, then 1% is £56 ÷ 140 = £0.40. So 100% (the cost price) is £0.40 × 100 = £40', 3, '10-11'),
('math', 'Percentages', 'What is 12.5% of 96?', '["10", "12", "14", "16"]', 1, '12.5% is the same as 1/8. 96 ÷ 8 = 12', 3, '10-11'),
('math', 'Percentages', 'A population of 2,400 grows by 5% in one year. What is the new population?', '["2,420", "2,460", "2,520", "2,500"]', 2, '5% of 2,400 = 120. New population = 2,400 + 120 = 2,520', 3, '10-11'),

-- ═══════════════════════════════════════════════════════════════════════
-- ALGEBRA (15)
-- ═══════════════════════════════════════════════════════════════════════
('math', 'Algebra', 'If x + 3 = 8, what is x?', '["3", "4", "5", "6"]', 2, 'x + 3 = 8, so x = 8 - 3 = 5', 1, '9-10'),
('math', 'Algebra', 'If y - 4 = 10, what is y?', '["12", "13", "14", "15"]', 2, 'y - 4 = 10, so y = 10 + 4 = 14', 1, '9-10'),
('math', 'Algebra', 'What is the value of 2n when n = 5?', '["7", "8", "9", "10"]', 3, '2n means 2 × n. When n = 5, 2 × 5 = 10', 1, '9-10'),
('math', 'Algebra', 'If 3x = 18, what is x?', '["5", "6", "7", "8"]', 1, '3x = 18, so x = 18 ÷ 3 = 6', 1, '9-10'),
('math', 'Algebra', 'What is a + a + a if a = 4?', '["8", "10", "12", "16"]', 2, 'a + a + a = 3a. When a = 4, 3 × 4 = 12', 1, '9-10'),
('math', 'Algebra', 'If 2x + 5 = 17, what is x?', '["5", "6", "7", "8"]', 1, '2x + 5 = 17, so 2x = 12, so x = 6', 2, '9-10'),
('math', 'Algebra', 'If x/4 = 9, what is x?', '["32", "34", "36", "38"]', 2, 'x/4 = 9, so x = 9 × 4 = 36', 2, '9-10'),
('math', 'Algebra', 'What is 5p - 3 when p = 4?', '["15", "16", "17", "18"]', 2, '5p - 3: first 5 × 4 = 20, then 20 - 3 = 17', 2, '9-10'),
('math', 'Algebra', 'If 4(x - 2) = 20, what is x?', '["5", "6", "7", "8"]', 2, '4(x-2) = 20, so x - 2 = 5, so x = 7', 2, '10-11'),
('math', 'Algebra', 'A number, n, doubled and then increased by 7 equals 23. What is n?', '["6", "7", "8", "9"]', 2, '2n + 7 = 23, so 2n = 16, so n = 8', 2, '10-11'),
('math', 'Algebra', 'If 3x + 2y = 16 and x = 4, what is y?', '["1", "2", "3", "4"]', 1, '3(4) + 2y = 16, so 12 + 2y = 16, so 2y = 4, so y = 2', 3, '10-11'),
('math', 'Algebra', 'Simplify: 3x + 5x - 2x', '["4x", "6x", "8x", "10x"]', 1, '3x + 5x - 2x = (3+5-2)x = 6x', 3, '10-11'),
('math', 'Algebra', 'If 2(3x + 1) = 4x + 10, what is x?', '["2", "3", "4", "5"]', 2, '2(3x+1) = 6x + 2. So 6x + 2 = 4x + 10. Subtract 4x from both sides: 2x + 2 = 10. Subtract 2: 2x = 8. So x = 4', 3, '10-11'),
('math', 'Algebra', 'A box has x marbles. Three boxes together have 36 marbles. What is x?', '["10", "11", "12", "13"]', 2, '3x = 36, so x = 36 ÷ 3 = 12', 3, '10-11'),
('math', 'Algebra', 'If y = 2x + 1 and x = 5, what is y?', '["9", "10", "11", "12"]', 2, 'y = 2(5) + 1 = 10 + 1 = 11', 3, '10-11'),

-- ═══════════════════════════════════════════════════════════════════════
-- GEOMETRY (15)
-- ═══════════════════════════════════════════════════════════════════════
('math', 'Geometry', 'How many sides does a hexagon have?', '["5", "6", "7", "8"]', 1, 'A hexagon has 6 sides. "Hex" means six', 1, '8-9'),
('math', 'Geometry', 'What is the name of a 2D shape with 3 sides?', '["Square", "Triangle", "Pentagon", "Hexagon"]', 1, 'A triangle has exactly 3 sides and 3 angles', 1, '8-9'),
('math', 'Geometry', 'How many right angles does a square have?', '["1", "2", "3", "4"]', 3, 'A square has 4 right angles, one at each corner', 1, '8-9'),
('math', 'Geometry', 'What is the perimeter of a square with sides of 5cm?', '["15cm", "20cm", "25cm", "30cm"]', 1, 'Perimeter = 4 × side length = 4 × 5 = 20cm', 1, '8-9'),
('math', 'Geometry', 'How many degrees are there in a right angle?', '["45", "90", "180", "360"]', 1, 'A right angle measures exactly 90 degrees', 1, '8-9'),
('math', 'Geometry', 'A rectangle has length 9cm and width 4cm. What is its area?', '["13 sq cm", "26 sq cm", "36 sq cm", "40 sq cm"]', 2, 'Area = length × width = 9 × 4 = 36 sq cm', 2, '9-10'),
('math', 'Geometry', 'How many degrees are there in a full turn?', '["90", "180", "270", "360"]', 3, 'A full turn is 360 degrees', 2, '9-10'),
('math', 'Geometry', 'What type of triangle has all three sides equal?', '["Right-angled", "Isosceles", "Equilateral", "Scalene"]', 2, 'An equilateral triangle has all three sides (and all three angles) equal', 2, '9-10'),
('math', 'Geometry', 'A triangle has angles of 60° and 70°. What is the third angle?', '["40°", "50°", "60°", "70°"]', 1, 'Angles in a triangle add up to 180°. 180 - 60 - 70 = 50°', 2, '9-10'),
('math', 'Geometry', 'What is the perimeter of a rectangle with length 12cm and width 7cm?', '["19cm", "38cm", "84cm", "42cm"]', 1, 'Perimeter = 2 × (length + width) = 2 × (12+7) = 2 × 19 = 38cm', 2, '9-10'),
('math', 'Geometry', 'A circle has a diameter of 14cm. What is its radius?', '["6cm", "7cm", "8cm", "28cm"]', 1, 'The radius is half the diameter. 14 ÷ 2 = 7cm', 3, '10-11'),
('math', 'Geometry', 'How many lines of symmetry does a regular pentagon have?', '["3", "4", "5", "6"]', 2, 'A regular pentagon has 5 lines of symmetry — one through each vertex and the midpoint of the opposite side', 3, '10-11'),
('math', 'Geometry', 'A cuboid has length 8cm, width 5cm, and height 3cm. What is its volume?', '["16 cu cm", "40 cu cm", "120 cu cm", "160 cu cm"]', 2, 'Volume = length × width × height = 8 × 5 × 3 = 120 cu cm', 3, '10-11'),
('math', 'Geometry', 'What is the sum of interior angles in a quadrilateral?', '["180°", "270°", "360°", "450°"]', 2, 'Any quadrilateral''s interior angles sum to 360°, regardless of its shape', 3, '10-11'),
('math', 'Geometry', 'A square has an area of 64 sq cm. What is the length of one side?', '["6cm", "7cm", "8cm", "9cm"]', 2, 'If area = side², then side = √64 = 8cm', 3, '10-11'),

-- ═══════════════════════════════════════════════════════════════════════
-- WORD PROBLEMS (15)
-- ═══════════════════════════════════════════════════════════════════════
('math', 'Word Problems', 'Tom has 15 sweets. He eats 6. How many does he have left?', '["7", "8", "9", "10"]', 2, '15 - 6 = 9 sweets remaining', 1, '8-9'),
('math', 'Word Problems', 'A pencil case holds 12 pencils. If there are 4 cases, how many pencils in total?', '["36", "44", "48", "52"]', 2, '12 × 4 = 48 pencils', 1, '8-9'),
('math', 'Word Problems', 'Sara has £20. She spends £7 on a book. How much money does she have left?', '["£12", "£13", "£14", "£15"]', 1, '£20 - £7 = £13', 1, '8-9'),
('math', 'Word Problems', 'A farmer has 24 sheep and buys 9 more. How many sheep does he have now?', '["31", "32", "33", "34"]', 2, '24 + 9 = 33 sheep', 1, '8-9'),
('math', 'Word Problems', 'A pizza is cut into 12 slices. If 4 people share it equally, how many slices does each person get?', '["2", "3", "4", "5"]', 1, '12 slices shared equally among 4 people: 12 ÷ 4 = 3 slices each', 1, '8-9'),
('math', 'Word Problems', 'A train ticket costs £14.50 for an adult and £8.75 for a child. What is the total cost for one adult and one child?', '["£22.25", "£23.25", "£24.25", "£21.25"]', 1, '£14.50 + £8.75 = £23.25', 2, '9-10'),
('math', 'Word Problems', 'A bus leaves every 25 minutes. If the first bus leaves at 9:00am, when does the 4th bus leave?', '["10:00am", "10:15am", "10:25am", "10:35am"]', 1, 'The 4th bus leaves after 3 intervals of 25 minutes: 3 × 25 = 75 minutes after 9:00am, which is 10:15am', 2, '9-10'),
('math', 'Word Problems', 'A baker makes 144 buns and packs them into boxes of 6. How many boxes does he need?', '["20", "22", "24", "26"]', 2, '144 ÷ 6 = 24 boxes', 2, '9-10'),
('math', 'Word Problems', 'Emma saves £5 a week. How many weeks will it take her to save £65?', '["11", "12", "13", "14"]', 2, '65 ÷ 5 = 13 weeks', 2, '9-10'),
('math', 'Word Problems', 'A recipe for 4 people uses 200g of rice. How much rice is needed for 10 people?', '["400g", "450g", "500g", "550g"]', 2, '200g ÷ 4 = 50g per person. 50g × 10 = 500g', 2, '9-10'),
('math', 'Word Problems', 'A car travels at 60mph for 2.5 hours. How far does it travel?', '["120 miles", "130 miles", "140 miles", "150 miles"]', 3, 'Distance = speed × time = 60 × 2.5 = 150 miles', 3, '10-11'),
('math', 'Word Problems', 'Three friends split a restaurant bill of £73.50 equally. How much does each pay?', '["£23.50", "£24.00", "£24.50", "£25.00"]', 2, '£73.50 ÷ 3 = £24.50 each', 3, '10-11'),
('math', 'Word Problems', 'A tank holds 450 litres. It is currently 2/3 full. How many more litres are needed to fill it?', '["100", "125", "150", "175"]', 2, '2/3 full means 1/3 empty. 1/3 of 450 = 150 litres needed', 3, '10-11'),
('math', 'Word Problems', 'A school trip costs £18 per pupil. For a class of 28 pupils, with a 10% group discount on the total, what is the final cost?', '["£453.60", "£463.60", "£473.60", "£483.60"]', 0, 'Total before discount: 18 × 28 = £504. 10% discount = £50.40. Final cost: 504 - 50.40 = £453.60', 3, '10-11'),
('math', 'Word Problems', 'A swimming pool is filled by two pipes. Pipe A fills it in 6 hours alone; Pipe B fills it in 12 hours alone. How long do both pipes take together?', '["3 hours", "4 hours", "5 hours", "9 hours"]', 1, 'Pipe A fills 1/6 per hour, Pipe B fills 1/12 per hour. Together: 1/6 + 1/12 = 2/12 + 1/12 = 3/12 = 1/4 per hour, so it takes 4 hours', 3, '10-11'),

-- ═══════════════════════════════════════════════════════════════════════
-- SEQUENCES (15)
-- ═══════════════════════════════════════════════════════════════════════
('math', 'Sequences', 'What comes next? 2, 4, 6, 8, __?', '["9", "10", "11", "12"]', 1, 'This sequence increases by 2 each time. 8 + 2 = 10', 1, '8-9'),
('math', 'Sequences', 'What comes next? 1, 3, 5, 7, __?', '["8", "9", "10", "11"]', 1, 'This is the odd numbers sequence, increasing by 2. 7 + 2 = 9', 1, '8-9'),
('math', 'Sequences', 'What comes next? 10, 20, 30, 40, __?', '["45", "50", "55", "60"]', 1, 'This sequence increases by 10 each time. 40 + 10 = 50', 1, '8-9'),
('math', 'Sequences', 'What comes next? 100, 90, 80, 70, __?', '["50", "55", "60", "65"]', 2, 'This sequence decreases by 10 each time. 70 - 10 = 60', 1, '8-9'),
('math', 'Sequences', 'What comes next? 3, 6, 9, 12, __?', '["13", "14", "15", "16"]', 2, 'This sequence increases by 3 each time (multiples of 3). 12 + 3 = 15', 1, '8-9'),
('math', 'Sequences', 'What comes next? 1, 4, 9, 16, __?', '["20", "23", "25", "27"]', 2, 'These are square numbers: 1², 2², 3², 4², so next is 5² = 25', 2, '9-10'),
('math', 'Sequences', 'What comes next? 2, 6, 18, 54, __?', '["108", "144", "162", "216"]', 2, 'Each number is multiplied by 3. 54 × 3 = 162', 2, '9-10'),
('math', 'Sequences', 'What is the missing number? 5, 11, __, 23, 29', '["15", "16", "17", "18"]', 2, 'This sequence increases by 6 each time. 11 + 6 = 17', 2, '9-10'),
('math', 'Sequences', 'What comes next? 1, 1, 2, 3, 5, 8, __?', '["10", "11", "12", "13"]', 3, 'This is the Fibonacci sequence — each number is the sum of the two before it. 5 + 8 = 13', 2, '9-10'),
('math', 'Sequences', 'What comes next? 81, 27, 9, 3, __?', '["0", "1", "1.5", "2"]', 1, 'Each number is divided by 3. 3 ÷ 3 = 1', 2, '9-10'),
('math', 'Sequences', 'What comes next? 2, 5, 10, 17, 26, __?', '["35", "36", "37", "38"]', 2, 'The differences between terms are 3, 5, 7, 9, 11 (increasing odd numbers). 26 + 11 = 37', 3, '10-11'),
('math', 'Sequences', 'What is the 10th term of the sequence 4, 7, 10, 13, ...?', '["28", "30", "31", "34"]', 2, 'This sequence starts at 4 and increases by 3 each term. The nth term = 4 + 3(n-1). For n=10: 4 + 3(9) = 4 + 27 = 31', 3, '10-11'),
('math', 'Sequences', 'What comes next? 1, 8, 27, 64, __?', '["100", "121", "125", "144"]', 2, 'These are cube numbers: 1³, 2³, 3³, 4³, so next is 5³ = 125', 3, '10-11'),
('math', 'Sequences', 'What is the missing number? 4, __, 16, 22, 28', '["8", "9", "10", "11"]', 2, 'This sequence increases by 6 each time. 4 + 6 = 10. Check: 10 + 6 = 16, 16 + 6 = 22, 22 + 6 = 28 — all consistent', 3, '10-11'),
('math', 'Sequences', 'What comes next? 0.5, 1, 2, 4, __?', '["6", "7", "8", "9"]', 2, 'Each term doubles the previous one. 4 × 2 = 8', 3, '10-11'),

-- ═══════════════════════════════════════════════════════════════════════
-- DATA HANDLING (15)
-- ═══════════════════════════════════════════════════════════════════════
('math', 'Data Handling', 'A class voted for their favourite fruit: Apple 8, Banana 5, Orange 7. How many pupils voted in total?', '["18", "19", "20", "21"]', 2, '8 + 5 + 7 = 20 pupils voted', 1, '8-9'),
('math', 'Data Handling', 'In a bar chart, which fruit got the most votes if Apple=8, Banana=5, Orange=7?', '["Apple", "Banana", "Orange", "All equal"]', 0, 'Apple has the highest number of votes (8), so it would have the tallest bar', 1, '8-9'),
('math', 'Data Handling', 'What is the mode of this set of numbers: 3, 5, 5, 7, 9?', '["3", "5", "7", "9"]', 1, 'The mode is the number that appears most often. 5 appears twice, more than any other number', 1, '8-9'),
('math', 'Data Handling', 'What is the range of this set: 4, 9, 2, 15, 7?', '["11", "12", "13", "14"]', 2, 'Range = highest - lowest = 15 - 2 = 13', 1, '8-9'),
('math', 'Data Handling', 'A tally chart shows |||| |||| || for pupils who chose football. How many pupils chose football?', '["10", "11", "12", "13"]', 1, 'Tally marks are grouped in fives. This shows two full groups of 5, plus 2 more: 5 + 5 + 2 = 12', 1, '8-9'),
('math', 'Data Handling', 'What is the mean of 4, 6, 8, 10, 12?', '["6", "7", "8", "9"]', 2, 'Mean = sum ÷ count = (4+6+8+10+12) ÷ 5 = 40 ÷ 5 = 8', 2, '9-10'),
('math', 'Data Handling', 'A pie chart shows 50% football, 25% tennis, 25% swimming. If 80 pupils were surveyed, how many chose tennis?', '["15", "20", "25", "30"]', 1, '25% of 80 = 20 pupils chose tennis', 2, '9-10'),
('math', 'Data Handling', 'What is the median of this set: 3, 7, 9, 12, 15?', '["7", "9", "12", "15"]', 1, 'When numbers are in order, the median is the middle value. With 5 numbers, the middle (3rd) one is 9', 2, '9-10'),
('math', 'Data Handling', 'A line graph shows temperature rising from 10°C to 22°C over 6 hours. What is the average rise per hour?', '["1°C", "2°C", "3°C", "4°C"]', 1, 'Total rise = 22 - 10 = 12°C over 6 hours. 12 ÷ 6 = 2°C per hour', 2, '9-10'),
('math', 'Data Handling', 'In a survey of 50 people, 30 prefer tea and the rest prefer coffee. What percentage prefer coffee?', '["20%", "30%", "40%", "60%"]', 2, '50 - 30 = 20 prefer coffee. 20/50 = 40%', 2, '9-10'),
('math', 'Data Handling', 'Find the median of: 14, 8, 22, 19, 3, 11, 17', '["11", "14", "17", "19"]', 1, 'Order the numbers: 3, 8, 11, 14, 17, 19, 22. With 7 numbers, the middle (4th) value is 14', 3, '10-11'),
('math', 'Data Handling', 'A class of 25 has a mean test score of 68. If one pupil''s score was wrongly recorded as 0 instead of the correct 80, what is the corrected mean?', '["68.4", "69.6", "70.4", "71.2"]', 3, 'Original total = 68 × 25 = 1,700. Correcting the mistake: 1,700 - 0 + 80 = 1,780. New mean = 1,780 ÷ 25 = 71.2', 3, '10-11'),
('math', 'Data Handling', 'A scatter graph shows a strong positive correlation between hours studied and exam score. What does this mean?', '["More study means lower scores", "More study means higher scores", "No relationship exists", "Scores are random"]', 1, 'A strong positive correlation means that as one value (hours studied) increases, the other value (exam score) also tends to increase', 3, '10-11'),
('math', 'Data Handling', 'The mean of 5 numbers is 12. If 4 of the numbers are 9, 11, 14, and 16, what is the 5th number?', '["8", "9", "10", "11"]', 2, 'Total of all 5 numbers = 12 × 5 = 60. Sum of known 4: 9+11+14+16=50. Fifth number = 60-50=10', 3, '10-11'),
('math', 'Data Handling', 'A pie chart represents 360 pupils. If one sector takes up 90°, how many pupils does that sector represent?', '["60", "75", "90", "100"]', 2, '90° out of 360° is 1/4. 1/4 of 360 pupils = 90 pupils', 3, '10-11')

ON CONFLICT DO NOTHING;