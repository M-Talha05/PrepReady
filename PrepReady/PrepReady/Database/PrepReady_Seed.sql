/* ============================================================
   PrepReady — SEED DATA
   8 categories x 1 course x 3 lessons x quizzes (+final exam),
   5 redemption partners, 1 admin, 1 officer.

   RUN ONCE, immediately AFTER PrepReady_Schema.sql (which drops
   and recreates every table, so the seed lands in empty tables).
   This script only INSERTs — it is NOT idempotent. Re-running it
   on a populated database duplicates rows and fails on the unique
   email index (UX_Users_Email). To re-seed, re-run the schema first.
   ============================================================ */
SET NOCOUNT ON;

/* ============================================================
   ACCOUNTS  (passwords are placeholders — Phase 3 sets real
   BCrypt hashes via EnsureSeedAccounts() on first app run)
   ============================================================ */
INSERT INTO Users (FullName, Email, PasswordHash, IsEmailVerified, PointBalance, IsActive, Role)
VALUES (N'PrepReady Admin', N'admin@prepready.local', N'PENDING_PHASE3_SETUP', 1, 0, 1, N'Admin');

INSERT INTO Officers (FullName, Email, PasswordHash, Agency, IsActive)
VALUES (N'Officer Sarah Lee', N'officer@prepready.local', N'PENDING_PHASE3_SETUP', N'Civil Defence (APM)', 1);

/* ============================================================
   COURSES + LESSONS + QUIZZES
   @cid is reused per course (single batch, so SET each time)
   ============================================================ */
DECLARE @cid INT;

/* ---------- 1. First Aid & Emergency Medicine ---------- */
INSERT INTO Courses (CategoryName, Title, Description, GovPartner, PassingMark, IsPublished)
VALUES (N'First Aid & Emergency Medicine', N'CPR & AED Essentials',
        N'Learn to recognise cardiac arrest and deliver effective hands-only CPR with an AED.',
        N'Ministry of Health', 60, 1);
SET @cid = SCOPE_IDENTITY();
INSERT INTO Lessons (CourseId, Title, BodyHtml, MediaUrl, SortOrder) VALUES
 (@cid, N'Recognising Cardiac Arrest', N'<p>Check responsiveness and normal breathing. No response + no breathing = call for help and start CPR.</p>', NULL, 1),
 (@cid, N'Hands-Only CPR Technique',  N'<p>Push hard and fast in the centre of the chest at 100–120 compressions per minute.</p>', NULL, 2),
 (@cid, N'Using an AED Safely',       N'<p>Turn it on, attach pads, and follow the spoken prompts. Ensure no one touches the patient during analysis/shock.</p>', NULL, 3);
INSERT INTO Quizzes (LessonId, Question, OptionA, OptionB, OptionC, OptionD, CorrectOption, IsFinalExam) VALUES
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=1), N'What confirms you should start CPR?', N'Person is asleep', N'Unresponsive and not breathing normally', N'Person is coughing', N'Person is talking', 'B', 0),
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=2), N'What is the correct compression rate?', N'40–60 per minute', N'60–80 per minute', N'100–120 per minute', N'150–180 per minute', 'C', 0),
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=3), N'Before the AED delivers a shock you must:', N'Pour water on the chest', N'Ensure nobody is touching the patient', N'Remove the pads', N'Start mouth-to-mouth', 'B', 0),
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=1), N'A bystander collapses clutching their chest, then stops responding and isn’t breathing. Your FIRST action is to:', N'Wait 5 minutes', N'Call emergency services and begin CPR', N'Give them water', N'Leave to find a doctor', 'B', 1),
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=1), N'Where do you place your hands for chest compressions?', N'Lower abdomen', N'Centre of the chest', N'Left shoulder', N'Neck', 'B', 1);

/* ---------- 2. Fire Safety & Rescue ---------- */
INSERT INTO Courses (CategoryName, Title, Description, GovPartner, PassingMark, IsPublished)
VALUES (N'Fire Safety & Rescue', N'Home Fire Safety & Escape',
        N'Choose the right extinguisher, build an escape plan, and maintain smoke detectors.',
        N'BOMBA (Fire & Rescue)', 60, 1);
SET @cid = SCOPE_IDENTITY();
INSERT INTO Lessons (CourseId, Title, BodyHtml, MediaUrl, SortOrder) VALUES
 (@cid, N'Extinguisher Types & PASS', N'<p>Match the extinguisher to the fire class and remember PASS: Pull, Aim, Squeeze, Sweep.</p>', NULL, 1),
 (@cid, N'Building a Home Escape Plan', N'<p>Know two ways out of every room and agree a meeting point outside.</p>', NULL, 2),
 (@cid, N'Smoke Detectors & Maintenance', N'<p>Test alarms monthly and replace batteries yearly.</p>', NULL, 3);
INSERT INTO Quizzes (LessonId, Question, OptionA, OptionB, OptionC, OptionD, CorrectOption, IsFinalExam) VALUES
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=1), N'What does PASS stand for?', N'Push, Aim, Spray, Stop', N'Pull, Aim, Squeeze, Sweep', N'Point, Alert, Spray, Stop', N'Pull, Alert, Shake, Sweep', 'B', 0),
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=2), N'A good escape plan includes:', N'One exit only', N'Two ways out and a meeting point', N'Hiding in a closet', N'Using the lift', 'B', 0),
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=3), N'How often should you test smoke alarms?', N'Yearly', N'Monthly', N'Every 5 years', N'Never', 'B', 0),
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=1), N'A small pan of cooking oil catches fire. You should:', N'Throw water on it', N'Smother it / use a wet cloth or Class F extinguisher', N'Carry it outside', N'Fan the flames', 'B', 1),
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=1), N'During a house fire you should move:', N'Standing upright', N'Low under the smoke', N'Back to collect valuables', N'Toward the fire', 'B', 1);

/* ---------- 3. Disaster Preparedness ---------- */
INSERT INTO Courses (CategoryName, Title, Description, GovPartner, PassingMark, IsPublished)
VALUES (N'Disaster Preparedness', N'Disaster Readiness Basics',
        N'Assemble an emergency kit and respond correctly to floods and earthquakes.',
        N'Civil Defence (APM)', 60, 1);
SET @cid = SCOPE_IDENTITY();
INSERT INTO Lessons (CourseId, Title, BodyHtml, MediaUrl, SortOrder) VALUES
 (@cid, N'Building an Emergency Kit', N'<p>Stock water, food, torch, first-aid, documents and a radio for at least 72 hours.</p>', NULL, 1),
 (@cid, N'Flood Evacuation Steps', N'<p>Move to higher ground early and never walk or drive through floodwater.</p>', NULL, 2),
 (@cid, N'Earthquake: Drop, Cover, Hold On', N'<p>Drop down, take cover under sturdy furniture, and hold on until shaking stops.</p>', NULL, 3);
INSERT INTO Quizzes (LessonId, Question, OptionA, OptionB, OptionC, OptionD, CorrectOption, IsFinalExam) VALUES
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=1), N'How many hours should a basic kit sustain you?', N'6 hours', N'24 hours', N'At least 72 hours', N'No minimum', 'C', 0),
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=2), N'During a flood you should:', N'Drive through fast water', N'Move to higher ground early', N'Wait in the basement', N'Swim across', 'B', 0),
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=3), N'The correct earthquake action is:', N'Run outside immediately', N'Drop, Cover, Hold On', N'Stand in a doorway frame', N'Use the lift', 'B', 0),
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=1), N'Floodwater is rising fast at home. The safest choice is:', N'Wait to see how high it gets', N'Evacuate early to higher ground', N'Drive through the flooded road', N'Store sandbags only', 'B', 1),
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=1), N'Which item is essential in an emergency kit?', N'A games console', N'Clean drinking water', N'Houseplants', N'A wall clock', 'B', 1);

/* ---------- 4. Mental Health & Crisis Response ---------- */
INSERT INTO Courses (CategoryName, Title, Description, GovPartner, PassingMark, IsPublished)
VALUES (N'Mental Health & Crisis Response', N'Crisis First Response',
        N'Recognise a crisis, hold a supportive conversation, and help during panic attacks.',
        N'Ministry of Health', 60, 1);
SET @cid = SCOPE_IDENTITY();
INSERT INTO Lessons (CourseId, Title, BodyHtml, MediaUrl, SortOrder) VALUES
 (@cid, N'Recognising a Mental Health Crisis', N'<p>Watch for sudden withdrawal, hopelessness, or talk of self-harm.</p>', NULL, 1),
 (@cid, N'The Suicide-Prevention Conversation', N'<p>Ask directly, listen without judgement, and connect them to help.</p>', NULL, 2),
 (@cid, N'Helping During a Panic Attack', N'<p>Stay calm, speak gently, and guide slow breathing.</p>', NULL, 3);
INSERT INTO Quizzes (LessonId, Question, OptionA, OptionB, OptionC, OptionD, CorrectOption, IsFinalExam) VALUES
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=1), N'A warning sign of crisis is:', N'Enjoying hobbies', N'Talk of hopelessness or self-harm', N'Making future plans', N'Eating well', 'B', 0),
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=2), N'When you suspect someone is suicidal you should:', N'Avoid the topic', N'Ask directly and listen', N'Change the subject', N'Tell them to cheer up', 'B', 0),
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=3), N'To help during a panic attack:', N'Shout at them', N'Guide slow, calm breathing', N'Leave them alone', N'Give caffeine', 'B', 0),
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=1), N'A friend says "everyone would be better off without me." You should:', N'Ignore it', N'Take it seriously, ask directly, and seek help', N'Laugh it off', N'Tell them to relax', 'B', 1),
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=1), N'The best listening approach in a crisis is:', N'Judging their choices', N'Calm, non-judgemental listening', N'Interrupting often', N'Giving quick advice', 'B', 1);

/* ---------- 5. Road & Transport Safety ---------- */
INSERT INTO Courses (CategoryName, Title, Description, GovPartner, PassingMark, IsPublished)
VALUES (N'Road & Transport Safety', N'Road Accident Response',
        N'Secure an accident scene, help victims safely, and survive a tyre blowout.',
        N'Royal Malaysia Police', 60, 1);
SET @cid = SCOPE_IDENTITY();
INSERT INTO Lessons (CourseId, Title, BodyHtml, MediaUrl, SortOrder) VALUES
 (@cid, N'Securing the Accident Scene', N'<p>Switch on hazards, set up a warning triangle, and keep clear of traffic.</p>', NULL, 1),
 (@cid, N'Helping Victims Safely', N'<p>Do not move casualties unless in immediate danger; call for help first.</p>', NULL, 2),
 (@cid, N'Surviving a Tyre Blowout', N'<p>Grip the wheel, ease off the accelerator, and slow gradually.</p>', NULL, 3);
INSERT INTO Quizzes (LessonId, Question, OptionA, OptionB, OptionC, OptionD, CorrectOption, IsFinalExam) VALUES
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=1), N'First step at an accident scene:', N'Take photos for fun', N'Switch on hazards and warn traffic', N'Move all cars away', N'Drive off', 'B', 0),
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=2), N'You should move an injured person only if:', N'They ask politely', N'They are in immediate danger', N'You are bored', N'Always', 'B', 0),
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=3), N'During a tyre blowout you should:', N'Brake hard immediately', N'Grip the wheel and slow gradually', N'Accelerate', N'Let go of the wheel', 'B', 0),
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=1), N'You arrive first at a crash on a busy road. You should:', N'Stand in the lane', N'Switch on hazards, set a warning triangle, call help', N'Push the cars aside', N'Drive past', 'B', 1),
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=1), N'Why avoid moving a casualty unnecessarily?', N'It wastes time', N'It can worsen spinal/other injuries', N'It is illegal everywhere', N'No reason', 'B', 1);

/* ---------- 6. Outdoor & Wilderness Survival ---------- */
INSERT INTO Courses (CategoryName, Title, Description, GovPartner, PassingMark, IsPublished)
VALUES (N'Outdoor & Wilderness Survival', N'Wilderness Survival Skills',
        N'Build shelter, purify water, and signal effectively for rescue.',
        N'Civil Defence (APM)', 60, 1);
SET @cid = SCOPE_IDENTITY();
INSERT INTO Lessons (CourseId, Title, BodyHtml, MediaUrl, SortOrder) VALUES
 (@cid, N'Building Emergency Shelter', N'<p>Insulate from the ground and shield from wind and rain.</p>', NULL, 1),
 (@cid, N'Purifying Water in the Wild', N'<p>Boiling for at least one minute kills most pathogens.</p>', NULL, 2),
 (@cid, N'Signalling for Rescue', N'<p>Use three of anything (whistles, fires) as a distress signal.</p>', NULL, 3);
INSERT INTO Quizzes (LessonId, Question, OptionA, OptionB, OptionC, OptionD, CorrectOption, IsFinalExam) VALUES
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=1), N'A shelter priority is to:', N'Look attractive', N'Insulate from the ground and block wind', N'Be very large', N'Face the wind', 'B', 0),
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=2), N'Boiling water to purify it should last at least:', N'5 seconds', N'1 minute', N'Just warm it', N'No need', 'B', 0),
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=3), N'A recognised distress signal is:', N'Two whistle blasts', N'Groups of three', N'A single shout', N'Silence', 'B', 0),
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=1), N'Lost overnight in cold hills, your first survival priority is:', N'Finding wifi', N'Shelter and staying warm/dry', N'Walking all night', N'Eating berries', 'B', 1),
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=1), N'Safest way to make stream water drinkable:', N'Drink as-is', N'Boil it thoroughly', N'Add sugar', N'Freeze it', 'B', 1);

/* ---------- 7. Digital & Personal Safety ---------- */
INSERT INTO Courses (CategoryName, Title, Description, GovPartner, PassingMark, IsPublished)
VALUES (N'Digital & Personal Safety', N'Staying Safe Online',
        N'Spot phishing, protect personal data, and respond to cyberbullying.',
        N'CyberSecurity Malaysia', 60, 1);
SET @cid = SCOPE_IDENTITY();
INSERT INTO Lessons (CourseId, Title, BodyHtml, MediaUrl, SortOrder) VALUES
 (@cid, N'Spotting Phishing & Scams', N'<p>Beware urgent messages, odd links, and requests for passwords or OTPs.</p>', NULL, 1),
 (@cid, N'Protecting Your Personal Data', N'<p>Use strong, unique passwords and enable two-factor authentication.</p>', NULL, 2),
 (@cid, N'Responding to Cyberbullying', N'<p>Do not retaliate; save evidence, block, and report.</p>', NULL, 3);
INSERT INTO Quizzes (LessonId, Question, OptionA, OptionB, OptionC, OptionD, CorrectOption, IsFinalExam) VALUES
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=1), N'A common phishing sign is:', N'A polite greeting', N'Urgent threats and a strange link', N'Correct spelling', N'No links at all', 'B', 0),
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=2), N'Best password practice is:', N'Reuse one everywhere', N'Strong, unique passwords + 2FA', N'Use "123456"', N'Share with friends', 'B', 0),
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=3), N'When cyberbullied you should:', N'Retaliate online', N'Save evidence, block, and report', N'Delete your account silently', N'Ignore forever', 'B', 0),
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=1), N'A "bank" texts asking for your OTP to "verify". You should:', N'Send it quickly', N'Never share it — banks never ask for OTPs', N'Call them back on the SMS number', N'Post it online', 'B', 1),
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=1), N'Two-factor authentication mainly:', N'Slows your phone', N'Adds a second layer of account security', N'Shares your data', N'Removes passwords', 'B', 1);

/* ---------- 8. Home & Everyday Safety ---------- */
INSERT INTO Courses (CategoryName, Title, Description, GovPartner, PassingMark, IsPublished)
VALUES (N'Home & Everyday Safety', N'Everyday Home Safety',
        N'Prevent electrical, carbon-monoxide, and food-safety hazards at home.',
        N'BOMBA (Fire & Rescue)', 60, 1);
SET @cid = SCOPE_IDENTITY();
INSERT INTO Lessons (CourseId, Title, BodyHtml, MediaUrl, SortOrder) VALUES
 (@cid, N'Electrical Safety at Home', N'<p>Avoid overloaded sockets and replace damaged cables.</p>', NULL, 1),
 (@cid, N'Carbon Monoxide Awareness', N'<p>Install a CO alarm and never run engines or burners indoors.</p>', NULL, 2),
 (@cid, N'Safe Food Handling', N'<p>Keep raw and cooked foods separate and cook to safe temperatures.</p>', NULL, 3);
INSERT INTO Quizzes (LessonId, Question, OptionA, OptionB, OptionC, OptionD, CorrectOption, IsFinalExam) VALUES
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=1), N'An electrical hazard is:', N'A grounded plug', N'Overloaded power sockets', N'A switched-off lamp', N'A new cable', 'B', 0),
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=2), N'Carbon monoxide is dangerous because it is:', N'Bright red', N'Colourless and odourless', N'Loud', N'Heavy and visible', 'B', 0),
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=3), N'To prevent food poisoning you should:', N'Mix raw and cooked food', N'Separate raw/cooked and cook thoroughly', N'Leave food out all day', N'Skip washing hands', 'B', 0),
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=1), N'Your CO alarm sounds. You should:', N'Ignore it', N'Get fresh air and leave the house, then call help', N'Open the oven', N'Light a candle', 'B', 1),
 ((SELECT LessonId FROM Lessons WHERE CourseId=@cid AND SortOrder=1), N'Best way to avoid overloading a socket:', N'Stack many adaptors', N'Use one high-power appliance per socket', N'Cover it with cloth', N'Use damaged cables', 'B', 1);

/* ============================================================
   REDEMPTION PARTNERS (mock)
   ============================================================ */
INSERT INTO RedemptionPartners (Name, PartnerType, VoucherTitle, PointCost, IsActive) VALUES
 (N'Brew & Bean Cafe',        N'Cafe',       N'Free Regular Coffee',            150, 1),
 (N'Spice Garden Restaurant', N'Restaurant', N'RM20 Dining Voucher',            400, 1),
 (N'CareFirst Pharmacy',      N'Pharmacy',   N'15% Off First-Aid Supplies',     250, 1),
 (N'UrbanMart Retail',        N'Retailer',   N'RM15 Shopping Voucher',          300, 1),
 (N'FitLife Gym',             N'Fitness',    N'1 Free Day Pass',                200, 1);

PRINT 'PrepReady seed data inserted successfully.';