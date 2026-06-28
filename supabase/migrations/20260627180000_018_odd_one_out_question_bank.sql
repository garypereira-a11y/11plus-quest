/*
# 11+ Quest: Odd One Out Question Bank Expansion

Adds 105 new odd_one_out questions (15 per topic × 7 topics), even spread
across difficulty 1/2/3 (5 each per topic), spanning Year 3-6 ability range.

Number Patterns groupings were pre-verified programmatically (each group of
4 numbers checked to share exactly one mathematical property among exactly
3 of the 4, leaving exactly one unambiguous odd one out).

"Visual Patterns" and "Shape Sequences" topics are written as text-describable
category/property puzzles (matching the existing seed data's approach),
since the schema has no image field to support true visual diagrams.

Purely additive — existing seed questions (migration 002) are untouched.
correct_answer uses the integer index format (0-3) into `options`.
*/

INSERT INTO questions (category, topic, question_text, options, correct_answer, explanation, difficulty, age_range) VALUES

-- ═══════════════════════════════════════════════════════════════════════
-- WORD CATEGORIES (15)
-- ═══════════════════════════════════════════════════════════════════════
('odd_one_out', 'Word Categories', 'Find the odd one out: Lion, Tiger, Bear, Sparrow', '["Lion", "Tiger", "Bear", "Sparrow"]', 3, 'Sparrow is a bird. Lion, Tiger, and Bear are all mammals', 1, '8-9'),
('odd_one_out', 'Word Categories', 'Find the odd one out: Hammer, Saw, Screwdriver, Apple', '["Hammer", "Saw", "Screwdriver", "Apple"]', 3, 'Apple is a fruit. Hammer, Saw, and Screwdriver are all tools', 1, '8-9'),
('odd_one_out', 'Word Categories', 'Find the odd one out: Trumpet, Flute, Clarinet, Football', '["Trumpet", "Flute", "Clarinet", "Football"]', 3, 'Football is a sport/ball. Trumpet, Flute, and Clarinet are all musical instruments', 1, '8-9'),
('odd_one_out', 'Word Categories', 'Find the odd one out: Spain, France, Italy, Paris', '["Spain", "France", "Italy", "Paris"]', 3, 'Paris is a city. Spain, France, and Italy are all countries', 1, '8-9'),
('odd_one_out', 'Word Categories', 'Find the odd one out: Shirt, Trousers, Hat, Plate', '["Shirt", "Trousers", "Hat", "Plate"]', 3, 'Plate is tableware. Shirt, Trousers, and Hat are all clothing items', 1, '8-9'),
('odd_one_out', 'Word Categories', 'Find the odd one out: Doctor, Nurse, Teacher, Hospital', '["Doctor", "Nurse", "Teacher", "Hospital"]', 3, 'Hospital is a place. Doctor, Nurse, and Teacher are all jobs (professions)', 2, '9-10'),
('odd_one_out', 'Word Categories', 'Find the odd one out: Oxygen, Hydrogen, Nitrogen, Water', '["Oxygen", "Hydrogen", "Nitrogen", "Water"]', 3, 'Water is a compound made of two elements joined together. Oxygen, Hydrogen, and Nitrogen are all single elements', 2, '9-10'),
('odd_one_out', 'Word Categories', 'Find the odd one out: Novel, Poem, Play, Author', '["Novel", "Poem", "Play", "Author"]', 3, 'Author is a person who writes. Novel, Poem, and Play are all types of written work', 2, '9-10'),
('odd_one_out', 'Word Categories', 'Find the odd one out: Democracy, Monarchy, Dictatorship, Election', '["Democracy", "Monarchy", "Dictatorship", "Election"]', 3, 'Election is an event/process. Democracy, Monarchy, and Dictatorship are all systems of government', 2, '9-10'),
('odd_one_out', 'Word Categories', 'Find the odd one out: Mammal, Reptile, Amphibian, Forest', '["Mammal", "Reptile", "Amphibian", "Forest"]', 3, 'Forest is a habitat/place. Mammal, Reptile, and Amphibian are all classes of animal', 2, '9-10'),
('odd_one_out', 'Word Categories', 'Find the odd one out: Sonnet, Haiku, Limerick, Novelist', '["Sonnet", "Haiku", "Limerick", "Novelist"]', 3, 'Novelist is a person who writes novels. Sonnet, Haiku, and Limerick are all forms of poetry', 3, '10-11'),
('odd_one_out', 'Word Categories', 'Find the odd one out: Igneous, Sedimentary, Metamorphic, Mineral', '["Igneous", "Sedimentary", "Metamorphic", "Mineral"]', 3, 'Mineral is a substance found within rock. Igneous, Sedimentary, and Metamorphic are the three categories used to classify how rock forms', 3, '10-11'),
('odd_one_out', 'Word Categories', 'Find the odd one out: Empathy, Sympathy, Compassion, Apathy', '["Empathy", "Sympathy", "Compassion", "Apathy"]', 3, 'Apathy means a lack of feeling or interest. Empathy, Sympathy, and Compassion all involve caring about others'' feelings', 3, '10-11'),
('odd_one_out', 'Word Categories', 'Find the odd one out: Photosynthesis, Respiration, Digestion, Erosion', '["Photosynthesis", "Respiration", "Digestion", "Erosion"]', 3, 'Erosion is a geological process affecting rock and soil. Photosynthesis, Respiration, and Digestion are all biological processes occurring within living things', 3, '10-11'),
('odd_one_out', 'Word Categories', 'Find the odd one out: Tyranny, Oppression, Persecution, Liberty', '["Tyranny", "Oppression", "Persecution", "Liberty"]', 3, 'Liberty means freedom. Tyranny, Oppression, and Persecution all describe the unjust use of power or control over others', 3, '10-11'),

-- ═══════════════════════════════════════════════════════════════════════
-- NUMBER PATTERNS (15) — all groupings pre-verified programmatically
-- ═══════════════════════════════════════════════════════════════════════
('odd_one_out', 'Number Patterns', 'Find the odd one out: 4, 8, 12, 15', '["4", "8", "12", "15"]', 3, '4, 8, and 12 are all multiples of 4. 15 is not a multiple of 4', 1, '8-9'),
('odd_one_out', 'Number Patterns', 'Find the odd one out: 2, 4, 6, 9', '["2", "4", "6", "9"]', 3, '2, 4, and 6 are all even numbers. 9 is an odd number', 1, '8-9'),
('odd_one_out', 'Number Patterns', 'Find the odd one out: 5, 10, 20, 21', '["5", "10", "20", "21"]', 3, '5, 10, and 20 are all multiples of 5. 21 is not a multiple of 5', 1, '8-9'),
('odd_one_out', 'Number Patterns', 'Find the odd one out: 3, 6, 9, 10', '["3", "6", "9", "10"]', 3, '3, 6, and 9 are all multiples of 3. 10 is not a multiple of 3', 1, '8-9'),
('odd_one_out', 'Number Patterns', 'Find the odd one out: 10, 20, 30, 35', '["10", "20", "30", "35"]', 3, '10, 20, and 30 are all multiples of 10. 35 is not a multiple of 10', 1, '8-9'),
('odd_one_out', 'Number Patterns', 'Find the odd one out: 4, 9, 16, 18', '["4", "9", "16", "18"]', 3, '4, 9, and 16 are all perfect squares (2², 3², 4²). 18 is not a perfect square', 2, '9-10'),
('odd_one_out', 'Number Patterns', 'Find the odd one out: 2, 3, 5, 8', '["2", "3", "5", "8"]', 3, '2, 3, and 5 are all prime numbers. 8 is not prime, since it can be divided by 2 and 4', 2, '9-10'),
('odd_one_out', 'Number Patterns', 'Find the odd one out: 6, 12, 18, 21', '["6", "12", "18", "21"]', 3, '6, 12, and 18 are all multiples of 6. 21 is not a multiple of 6', 2, '9-10'),
('odd_one_out', 'Number Patterns', 'Find the odd one out: 7, 14, 21, 25', '["7", "14", "21", "25"]', 3, '7, 14, and 21 are all multiples of 7. 25 is not a multiple of 7', 2, '9-10'),
('odd_one_out', 'Number Patterns', 'Find the odd one out: 1, 4, 8, 9', '["1", "4", "8", "9"]', 2, '1, 4, and 9 are all perfect squares (1², 2², 3²). 8 is not a perfect square', 2, '9-10'),
('odd_one_out', 'Number Patterns', 'Find the odd one out: 1, 8, 27, 30', '["1", "8", "27", "30"]', 3, '1, 8, and 27 are all perfect cubes (1³, 2³, 3³). 30 is not a perfect cube', 3, '10-11'),
('odd_one_out', 'Number Patterns', 'Find the odd one out: 16, 25, 36, 40', '["16", "25", "36", "40"]', 3, '16, 25, and 36 are all perfect squares (4², 5², 6²). 40 is not a perfect square', 3, '10-11'),
('odd_one_out', 'Number Patterns', 'Find the odd one out: 12, 24, 36, 40', '["12", "24", "36", "40"]', 3, '12, 24, and 36 are all multiples of 12. 40 is not a multiple of 12', 3, '10-11'),
('odd_one_out', 'Number Patterns', 'Find the odd one out: 11, 13, 17, 18', '["11", "13", "17", "18"]', 3, '11, 13, and 17 are all prime numbers. 18 is not prime', 3, '10-11'),
('odd_one_out', 'Number Patterns', 'Find the odd one out: 9, 16, 25, 30', '["9", "16", "25", "30"]', 3, '9, 16, and 25 are all perfect squares (3², 4², 5²). 30 is not a perfect square', 3, '10-11'),

-- ═══════════════════════════════════════════════════════════════════════
-- VISUAL PATTERNS (15) — written as text-describable property puzzles
-- ═══════════════════════════════════════════════════════════════════════
('odd_one_out', 'Visual Patterns', 'Find the odd one out by number of sides: Triangle, Square, Pentagon, Circle', '["Triangle", "Square", "Pentagon", "Circle"]', 3, 'A circle has no straight sides at all. Triangle, Square, and Pentagon all have a fixed number of straight sides', 1, '8-9'),
('odd_one_out', 'Visual Patterns', 'Find the odd one out by colour group: Red, Orange, Yellow, Blue', '["Red", "Orange", "Yellow", "Blue"]', 3, 'Red, Orange, and Yellow are all considered warm colours. Blue is a cool colour', 1, '8-9'),
('odd_one_out', 'Visual Patterns', 'Find the odd one out by number of corners: Square, Rectangle, Triangle, Hexagon', '["Square", "Rectangle", "Triangle", "Hexagon"]', 2, 'Square, Rectangle, and Hexagon all have an even number of corners (4, 4, and 6). Triangle has 3 corners, an odd number', 1, '8-9'),
('odd_one_out', 'Visual Patterns', 'Find the odd one out by symmetry: Square, Circle, Equilateral Triangle, Scalene Triangle', '["Square", "Circle", "Equilateral Triangle", "Scalene Triangle"]', 3, 'Square, Circle, and Equilateral Triangle all have multiple lines of symmetry. A Scalene Triangle has no lines of symmetry at all', 2, '9-10'),
('odd_one_out', 'Visual Patterns', 'Find the odd one out by number of faces: Cube, Cuboid, Sphere, Triangular Prism', '["Cube", "Cuboid", "Sphere", "Triangular Prism"]', 2, 'Cube, Cuboid, and Triangular Prism are all 3D shapes made up of flat faces. A Sphere has one continuously curved surface and no flat faces', 2, '9-10'),
('odd_one_out', 'Visual Patterns', 'Find the odd one out by type of angle: Right angle, Acute angle, Obtuse angle, Equilateral angle', '["Right angle", "Acute angle", "Obtuse angle", "Equilateral angle"]', 3, '"Equilateral" describes equal sides on a shape, not a type of angle. Right, Acute, and Obtuse are all genuine angle types', 2, '9-10'),
('odd_one_out', 'Visual Patterns', 'Find the odd one out by number of vertices: Cube, Square Pyramid, Cone, Cuboid', '["Cube", "Square Pyramid", "Cone", "Cuboid"]', 2, 'Cube, Square Pyramid, and Cuboid all have a fixed, countable number of sharp corners (vertices). A Cone has only one vertex at its point and a curved, continuous edge at its base', 2, '9-10'),
('odd_one_out', 'Visual Patterns', 'Find the odd one out by rotational symmetry: Square, Equilateral Triangle, Regular Hexagon, Isosceles Trapezium', '["Square", "Equilateral Triangle", "Regular Hexagon", "Isosceles Trapezium"]', 3, 'Square, Equilateral Triangle, and Regular Hexagon all have rotational symmetry (they look the same after a partial turn). An Isosceles Trapezium does not have rotational symmetry', 3, '10-11'),
('odd_one_out', 'Visual Patterns', 'Find the odd one out by parallel sides: Square, Rectangle, Parallelogram, Right-angled Triangle', '["Square", "Rectangle", "Parallelogram", "Right-angled Triangle"]', 3, 'Square, Rectangle, and Parallelogram all have at least one pair of parallel sides. A Right-angled Triangle has no parallel sides', 3, '10-11'),
('odd_one_out', 'Visual Patterns', 'Find the odd one out by curved edges: Sphere, Cylinder, Cone, Cube', '["Sphere", "Cylinder", "Cone", "Cube"]', 3, 'Sphere, Cylinder, and Cone all include at least one curved surface. A Cube is made entirely of flat faces with no curves at all', 3, '10-11'),
('odd_one_out', 'Visual Patterns', 'Find the odd one out by diagonals: Square, Rectangle, Rhombus, Equilateral Triangle', '["Square", "Rectangle", "Rhombus", "Equilateral Triangle"]', 3, 'Square, Rectangle, and Rhombus are all four-sided shapes with diagonals connecting opposite corners. An Equilateral Triangle has only 3 corners and no diagonals at all', 3, '10-11'),
('odd_one_out', 'Visual Patterns', 'Find the odd one out by tessellation (tiling without gaps): Square, Equilateral Triangle, Regular Hexagon, Regular Pentagon', '["Square", "Equilateral Triangle", "Regular Hexagon", "Regular Pentagon"]', 3, 'Square, Equilateral Triangle, and Regular Hexagon can each tile a flat surface perfectly with no gaps. A Regular Pentagon cannot tessellate on its own', 3, '10-11'),
('odd_one_out', 'Visual Patterns', 'Find the odd one out by number of edges: Cube, Square Pyramid, Tetrahedron, Sphere', '["Cube", "Square Pyramid", "Tetrahedron", "Sphere"]', 3, 'Cube, Square Pyramid, and Tetrahedron all have a fixed, countable number of straight edges. A Sphere has no edges at all, since its surface is entirely curved', 2, '9-10'),
('odd_one_out', 'Visual Patterns', 'Find the odd one out by reflective symmetry: Letter A, Letter B, Letter F, Letter T', '["Letter A", "Letter B", "Letter F", "Letter T"]', 2, 'The letters A, B, and T each have at least one line of symmetry when drawn in a standard block style. The letter F has no lines of symmetry', 1, '8-9'),
('odd_one_out', 'Visual Patterns', 'Find the odd one out by number of right angles: Square, Rectangle, Rhombus, Right-angled Triangle', '["Square", "Rectangle", "Rhombus", "Right-angled Triangle"]', 2, 'Square, Rectangle, and Right-angled Triangle all contain at least one (or more) right angles. A Rhombus, unless it happens to be a square, has no right angles at all', 1, '8-9'),

-- ═══════════════════════════════════════════════════════════════════════
-- MIXED PATTERNS (15)
-- ═══════════════════════════════════════════════════════════════════════
('odd_one_out', 'Mixed Patterns', 'Find the odd one out: Apple, Banana, Carrot, Orange', '["Apple", "Banana", "Carrot", "Orange"]', 2, 'Carrot is a vegetable. Apple, Banana, and Orange are all fruits', 1, '8-9'),
('odd_one_out', 'Mixed Patterns', 'Find the odd one out: 5, Ten, 15, 20', '["5", "Ten", "15", "20"]', 1, '"Ten" is written as a word. 5, 15, and 20 are all written as numerals (digits)', 1, '8-9'),
('odd_one_out', 'Mixed Patterns', 'Find the odd one out: Monday, Blue, Friday, Sunday', '["Monday", "Blue", "Friday", "Sunday"]', 1, 'Blue is a colour. Monday, Friday, and Sunday are all days of the week', 1, '8-9'),
('odd_one_out', 'Mixed Patterns', 'Find the odd one out: Red, Green, Heavy, Yellow', '["Red", "Green", "Heavy", "Yellow"]', 2, 'Heavy describes weight. Red, Green, and Yellow are all colours', 1, '8-9'),
('odd_one_out', 'Mixed Patterns', 'Find the odd one out: January, February, Tuesday, March', '["January", "February", "Tuesday", "March"]', 2, 'Tuesday is a day of the week. January, February, and March are all months', 1, '8-9'),
('odd_one_out', 'Mixed Patterns', 'Find the odd one out: 12, Square, 16, 20', '["12", "Square", "16", "20"]', 1, '"Square" is a shape, not a number. 12, 16, and 20 are all numbers, and in fact all multiples of 4', 2, '9-10'),
('odd_one_out', 'Mixed Patterns', 'Find the odd one out: Quickly, Slowly, Happy, Carefully', '["Quickly", "Slowly", "Happy", "Carefully"]', 2, '"Happy" is an adjective. Quickly, Slowly, and Carefully are all adverbs, ending in "-ly"', 2, '9-10'),
('odd_one_out', 'Mixed Patterns', 'Find the odd one out: Triangle, 7, Square, Hexagon', '["Triangle", "7", "Square", "Hexagon"]', 1, '"7" is a number, while the others are all shapes', 2, '9-10'),
('odd_one_out', 'Mixed Patterns', 'Find the odd one out: Whale, Dolphin, Shark, Penguin', '["Whale", "Dolphin", "Shark", "Penguin"]', 3, 'A penguin is a bird, even though it cannot fly and swims well. Whale, Dolphin, and Shark all live permanently underwater', 2, '9-10'),
('odd_one_out', 'Mixed Patterns', 'Find the odd one out: Run, Jump, Quickly, Swim', '["Run", "Jump", "Quickly", "Swim"]', 2, '"Quickly" is an adverb describing how an action is done. Run, Jump, and Swim are all verbs (actions)', 2, '9-10'),
('odd_one_out', 'Mixed Patterns', 'Find the odd one out: Democracy, 1945, Monarchy, Dictatorship', '["Democracy", "1945", "Monarchy", "Dictatorship"]', 1, '"1945" is a year (a number). Democracy, Monarchy, and Dictatorship are all systems of government', 3, '10-11'),
('odd_one_out', 'Mixed Patterns', 'Find the odd one out: Photosynthesis, Oxygen, Respiration, Digestion', '["Photosynthesis", "Oxygen", "Respiration", "Digestion"]', 1, 'Oxygen is a gas (a substance), while Photosynthesis, Respiration, and Digestion are all biological processes', 3, '10-11'),
('odd_one_out', 'Mixed Patterns', 'Find the odd one out: Courageous, Bravery, Cowardly, Fearless', '["Courageous", "Bravery", "Cowardly", "Fearless"]', 2, 'Cowardly means lacking courage. Courageous, Bravery, and Fearless are all associated with having courage', 3, '10-11'),
('odd_one_out', 'Mixed Patterns', 'Find the odd one out: Igneous rock, Volcano, Sedimentary rock, Metamorphic rock', '["Igneous rock", "Volcano", "Sedimentary rock", "Metamorphic rock"]', 1, 'Volcano is a landform, not a category of rock. Igneous, Sedimentary, and Metamorphic are the three categories used to classify rock', 3, '10-11'),
('odd_one_out', 'Mixed Patterns', 'Find the odd one out: Equilateral, Isosceles, Symmetrical, Scalene', '["Equilateral", "Isosceles", "Symmetrical", "Scalene"]', 2, '"Symmetrical" is a general description, not a specific type of triangle. Equilateral, Isosceles, and Scalene are all specific triangle classifications based on side length', 3, '10-11'),

-- ═══════════════════════════════════════════════════════════════════════
-- SHAPE SEQUENCES (15) — written as text-describable numeric/property sequences
-- ═══════════════════════════════════════════════════════════════════════
('odd_one_out', 'Shape Sequences', 'A sequence of shapes has 3, 4, 5, 6 sides in order. Which group breaks this pattern: Triangle(3), Square(4), Circle(0), Hexagon(6)?', '["Triangle", "Square", "Circle", "Hexagon"]', 2, 'The pattern increases sides by 1 each time (3,4,5,6). A circle has 0 straight sides, breaking the pattern where a 5-sided pentagon was expected', 1, '8-9'),
('odd_one_out', 'Shape Sequences', 'In a sequence where shapes gain one side each time (Triangle, Square, Pentagon, ...), which shape correctly continues the pattern?', '["Hexagon (6 sides)", "Heptagon (7 sides)", "Circle (0 sides)", "Octagon (8 sides)"]', 0, 'Triangle (3), Square (4), Pentagon (5) increase by one side each time, so the next shape should have 6 sides: a Hexagon', 1, '8-9'),
('odd_one_out', 'Shape Sequences', 'A sequence of shapes alternates between 4-sided and 3-sided: Square, Triangle, Square, ___. Which shape comes next?', '["Square", "Triangle", "Pentagon", "Circle"]', 1, 'The pattern alternates 4 sides, 3 sides, 4 sides, so the next shape should have 3 sides: a Triangle', 1, '8-9'),
('odd_one_out', 'Shape Sequences', 'A growing sequence of shapes doubles its sides each time: Triangle(3), Hexagon(6), ___(12). Which shape has 12 sides?', '["Pentagon", "Octagon", "Dodecagon", "Heptagon"]', 2, 'A shape with 12 sides is called a Dodecagon. The pattern doubles the side count each time: 3, 6, 12', 2, '9-10'),
('odd_one_out', 'Shape Sequences', 'In a sequence of shapes with side counts 5, 10, 15, 20, which shape correctly matches 15 sides?', '["Pentagon", "Decagon", "Pentadecagon", "Icosagon"]', 2, 'A shape with 15 sides is called a Pentadecagon. The pattern increases side count by 5 each time: 5, 10, 15, 20', 2, '9-10'),
('odd_one_out', 'Shape Sequences', 'Find the odd one out in this sequence of shapes by vertex count: Triangle(3), Square(4), Pentagon(5), Circle(0)', '["Triangle", "Square", "Pentagon", "Circle"]', 3, 'Triangle, Square, and Pentagon form a clear increasing sequence of vertices (3,4,5). Circle has 0 vertices, breaking the established sequence', 2, '9-10'),
('odd_one_out', 'Shape Sequences', 'A sequence of regular polygons has interior angles of 60°, 90°, 108°, ___. Which angle correctly continues for a regular hexagon?', '["100°", "120°", "140°", "150°"]', 1, 'A regular hexagon has an interior angle of 120°. The sequence shows the interior angles of equilateral triangle (60°), square (90°), and pentagon (108°), increasing toward a hexagon', 3, '10-11'),
('odd_one_out', 'Shape Sequences', 'A sequence of shapes has 3, 4, 5, 9 sides in order. Which number breaks the pattern of increasing by 1 each time?', '["3", "4", "5", "9"]', 3, '3, 4, and 5 increase by 1 each time. 9 breaks this pattern, since 5+1 should be 6, not 9', 1, '8-9'),
('odd_one_out', 'Shape Sequences', 'A sequence shows shapes with 4, 8, 16, 24 total edges (for cube-like 3D solids). Which number breaks a clean doubling pattern?', '["4", "8", "16", "24"]', 3, '4, 8, and 16 double each time (×2). 24 does not fit the doubling pattern, since 16×2 would be 32', 3, '10-11'),
('odd_one_out', 'Shape Sequences', 'A sequence of polygons has 3, 6, 9, 13 sides. Which number breaks the pattern of increasing by 3 each time?', '["3", "6", "9", "13"]', 3, '3, 6, and 9 increase by 3 each time. 13 breaks this pattern, since 9+3 should be 12, not 13', 2, '9-10'),
('odd_one_out', 'Shape Sequences', 'A sequence of shapes has rotational symmetry orders 3, 4, 5, 7 for triangle, square, pentagon, and a 6-sided hexagon. Which number is incorrect for a regular hexagon?', '["3", "4", "5", "7"]', 3, 'A regular hexagon has rotational symmetry of order 6, not 7. The pattern for regular polygons is that the order of rotational symmetry equals the number of sides', 3, '10-11'),
('odd_one_out', 'Shape Sequences', 'A sequence of shapes has 4, 5, 6, 8 sides in order. Which number breaks the pattern of increasing by 1 each time?', '["4", "5", "6", "8"]', 3, '4, 5, and 6 increase by 1 each time. 8 breaks this pattern, since 6+1 should be 7, not 8', 1, '8-9'),
('odd_one_out', 'Shape Sequences', 'A sequence of shapes has perimeter values 12, 16, 20, 25 for a series of squares with increasing side length. Which value breaks the pattern of increasing by 4 each time?', '["12", "16", "20", "25"]', 3, '12, 16, and 20 increase by 4 each time. 25 breaks this pattern, since 20+4 should be 24, not 25', 2, '9-10'),
('odd_one_out', 'Shape Sequences', 'A sequence of regular polygons has exterior angles of 120°, 90°, 72°, 50° for triangle, square, pentagon, and hexagon. Which value is incorrect for a regular hexagon?', '["120°", "90°", "72°", "50°"]', 3, 'A regular hexagon has an exterior angle of 60°, not 50°. Exterior angles of regular polygons always total 360° divided by the number of sides', 3, '10-11'),
('odd_one_out', 'Shape Sequences', 'A sequence shows area values for squares with side lengths 2, 3, 4, 6, giving areas 4, 9, 16, 30. Which area value is incorrect?', '["4", "9", "16", "30"]', 3, 'A square with side length 6 should have an area of 36 (6×6), not 30. The other three values (4, 9, 16) correctly match their side lengths squared', 3, '10-11'),

-- ═══════════════════════════════════════════════════════════════════════
-- CONCEPT GROUPS (15)
-- ═══════════════════════════════════════════════════════════════════════
('odd_one_out', 'Concept Groups', 'Find the odd one out: Joy, Happiness, Delight, Sorrow', '["Joy", "Happiness", "Delight", "Sorrow"]', 3, 'Sorrow means sadness. Joy, Happiness, and Delight are all positive feelings', 1, '8-9'),
('odd_one_out', 'Concept Groups', 'Find the odd one out: Summer, Winter, Spring, Wednesday', '["Summer", "Winter", "Spring", "Wednesday"]', 3, 'Wednesday is a day of the week. Summer, Winter, and Spring are all seasons', 1, '8-9'),
('odd_one_out', 'Concept Groups', 'Find the odd one out: Whisper, Shout, Mumble, Jump', '["Whisper", "Shout", "Mumble", "Jump"]', 3, 'Jump is a physical movement. Whisper, Shout, and Mumble are all ways of speaking', 1, '8-9'),
('odd_one_out', 'Concept Groups', 'Find the odd one out: North, South, East, Centre', '["North", "South", "East", "Centre"]', 3, 'Centre is a position, not a direction. North, South, and East are all compass directions', 1, '8-9'),
('odd_one_out', 'Concept Groups', 'Find the odd one out: Inch, Foot, Mile, Pound', '["Inch", "Foot", "Mile", "Pound"]', 3, 'Pound is a unit of weight. Inch, Foot, and Mile are all units of length', 1, '8-9'),
('odd_one_out', 'Concept Groups', 'Find the odd one out: Liberty, Freedom, Independence, Captivity', '["Liberty", "Freedom", "Independence", "Captivity"]', 3, 'Captivity means being held against one''s will. Liberty, Freedom, and Independence all relate to being free', 2, '9-10'),
('odd_one_out', 'Concept Groups', 'Find the odd one out: Cause, Reason, Origin, Result', '["Cause", "Reason", "Origin", "Result"]', 3, 'Result describes an outcome or effect. Cause, Reason, and Origin all describe something that comes before and leads to an outcome', 2, '9-10'),
('odd_one_out', 'Concept Groups', 'Find the odd one out: Abundance, Plenty, Surplus, Scarcity', '["Abundance", "Plenty", "Surplus", "Scarcity"]', 3, 'Scarcity means a shortage. Abundance, Plenty, and Surplus all describe having more than enough', 2, '9-10'),
('odd_one_out', 'Concept Groups', 'Find the odd one out: Construct, Build, Assemble, Demolish', '["Construct", "Build", "Assemble", "Demolish"]', 3, 'Demolish means to tear down. Construct, Build, and Assemble all mean to put something together', 2, '9-10'),
('odd_one_out', 'Concept Groups', 'Find the odd one out: Ascend, Climb, Rise, Descend', '["Ascend", "Climb", "Rise", "Descend"]', 3, 'Descend means to go down. Ascend, Climb, and Rise all mean to go up', 2, '9-10'),
('odd_one_out', 'Concept Groups', 'Find the odd one out: Conceal, Hide, Disguise, Reveal', '["Conceal", "Hide", "Disguise", "Reveal"]', 3, 'Reveal means to show or uncover. Conceal, Hide, and Disguise all mean to keep something out of sight', 3, '10-11'),
('odd_one_out', 'Concept Groups', 'Find the odd one out: Tranquil, Peaceful, Serene, Turbulent', '["Tranquil", "Peaceful", "Serene", "Turbulent"]', 3, 'Turbulent means chaotic or stormy. Tranquil, Peaceful, and Serene all describe a state of calm', 3, '10-11'),
('odd_one_out', 'Concept Groups', 'Find the odd one out: Genuine, Authentic, Sincere, Fraudulent', '["Genuine", "Authentic", "Sincere", "Fraudulent"]', 3, 'Fraudulent means deceptive or fake. Genuine, Authentic, and Sincere all describe being honest and real', 3, '10-11'),
('odd_one_out', 'Concept Groups', 'Find the odd one out: Diligent, Industrious, Hardworking, Indolent', '["Diligent", "Industrious", "Hardworking", "Indolent"]', 3, 'Indolent means lazy. Diligent, Industrious, and Hardworking all describe putting in steady, careful effort', 3, '10-11'),
('odd_one_out', 'Concept Groups', 'Find the odd one out: Frugal, Thrifty, Economical, Extravagant', '["Frugal", "Thrifty", "Economical", "Extravagant"]', 3, 'Extravagant means spending lavishly or wastefully. Frugal, Thrifty, and Economical all describe being careful with money', 3, '10-11')

-- ═══════════════════════════════════════════════════════════════════════
-- LETTER PATTERNS (15) — alphabet position logic pre-verified programmatically
-- ═══════════════════════════════════════════════════════════════════════
('odd_one_out', 'Letter Patterns', 'Find the odd one out: B, D, F, G', '["B", "D", "F", "G"]', 3, 'B, D, and F skip one letter each time (every other letter). G breaks this pattern, since after F the next letter in the pattern should be H', 1, '8-9'),
('odd_one_out', 'Letter Patterns', 'Find the odd one out: A, C, E, F', '["A", "C", "E", "F"]', 3, 'A, C, and E skip one letter each time. F breaks this pattern, since after E the next letter in the pattern should be G', 1, '8-9'),
('odd_one_out', 'Letter Patterns', 'Find the odd one out: M, N, O, Q', '["M", "N", "O", "Q"]', 3, 'M, N, and O are consecutive letters. Q breaks this pattern, since after O the next consecutive letter should be P', 1, '8-9'),
('odd_one_out', 'Letter Patterns', 'Find the odd one out: J, K, L, N', '["J", "K", "L", "N"]', 3, 'J, K, and L are consecutive letters. N breaks this pattern, since after L the next consecutive letter should be M', 1, '8-9'),
('odd_one_out', 'Letter Patterns', 'Find the odd one out: T, U, V, X', '["T", "U", "V", "X"]', 3, 'T, U, and V are consecutive letters. X breaks this pattern, since after V the next consecutive letter should be W', 1, '8-9'),
('odd_one_out', 'Letter Patterns', 'Find the odd one out: C, F, I, K', '["C", "F", "I", "K"]', 3, 'C, F, and I skip two letters each time. K breaks this pattern, since after I the next letter in the pattern should be L', 2, '9-10'),
('odd_one_out', 'Letter Patterns', 'Find the odd one out: B, E, H, J', '["B", "E", "H", "J"]', 3, 'B, E, and H skip two letters each time. J breaks this pattern, since after H the next letter in the pattern should be K', 2, '9-10'),
('odd_one_out', 'Letter Patterns', 'Find the odd one out: D, G, J, L', '["D", "G", "J", "L"]', 3, 'D, G, and J skip two letters each time. L breaks this pattern, since after J the next letter in the pattern should be M', 2, '9-10'),
('odd_one_out', 'Letter Patterns', 'Find the odd one out: A, D, G, I', '["A", "D", "G", "I"]', 3, 'A, D, and G skip two letters each time. I breaks this pattern, since after G the next letter in the pattern should be J', 2, '9-10'),
('odd_one_out', 'Letter Patterns', 'Find the odd one out: Z, X, V, S', '["Z", "X", "V", "S"]', 3, 'Z, X, and V move backwards skipping one letter each time. S breaks this pattern, since after V the next letter going backwards should be T', 2, '9-10'),
('odd_one_out', 'Letter Patterns', 'Find the odd one out: AB, CD, EF, GI', '["AB", "CD", "EF", "GI"]', 3, 'AB, CD, and EF are consecutive letter pairs. GI breaks this pattern, since after EF the next pair should be GH', 3, '10-11'),
('odd_one_out', 'Letter Patterns', 'Find the odd one out: BC, EF, HI, JL', '["BC", "EF", "HI", "JL"]', 3, 'BC, EF, and HI each skip two letters before the next pair starts. JL breaks this pattern, since after HI the next pair should be KL', 3, '10-11'),
('odd_one_out', 'Letter Patterns', 'Find the odd one out: AZ, BY, CX, DV', '["AZ", "BY", "CX", "DV"]', 3, 'In AZ, BY, and CX, the first letter moves forward while the second moves backward by one each time. DV breaks this pattern, since the second letter should be W, not V', 3, '10-11'),
('odd_one_out', 'Letter Patterns', 'Find the odd one out: ACE, DFH, GIK, KMO', '["ACE", "DFH", "GIK", "KMO"]', 3, 'In ACE, DFH, and GIK, each group skips one letter internally, and each new group starts 3 letters after the previous one started (A, D, G). KMO breaks this pattern, since the next group should start with J, giving JLN', 3, '10-11'),
('odd_one_out', 'Letter Patterns', 'Find the odd one out: AC, EG, IK, MP', '["AC", "EG", "IK", "MP"]', 3, 'AC, EG, and IK each skip one letter internally and each pair starts 4 letters after the previous one. MP breaks this pattern, since it should be MO to keep the same internal one-letter skip', 3, '10-11')

ON CONFLICT DO NOTHING;

