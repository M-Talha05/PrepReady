/* ============================================================
   PrepReady — SCHEMA  (APU CT050-3-2-WAPP)
   Authoritative table definitions (spec Section 5) PLUS the
   tables added during the build (LessonProgress, QuizAttempts,
   Deployments) and the two extra Users columns (LastLoginDate,
   LoginStreak).
   Run this FIRST against the connected PrepReadyDB.mdf, then
   PrepReady_Seed.sql, then PrepReady_Extras.sql.
   Note: no GO batches — Server Explorer runs one T-SQL batch.
   ============================================================ */
SET NOCOUNT ON;

/* ---- Drop child -> parent so FKs don't block a rebuild ----
   The EX-track tables (created by PrepReady_Extras.sql) are
   dropped here too, because they hold FKs to Users/Courses/
   ContactMessages; without dropping them first, DROP TABLE
   Users/Courses would fail on a re-run. After running this
   file, re-run PrepReady_Extras.sql to recreate them.        */

-- EX-track + build-added children first
DROP TABLE IF EXISTS ContactReplies;
DROP TABLE IF EXISTS ContactMessages;
DROP TABLE IF EXISTS Bookmarks;
DROP TABLE IF EXISTS CourseReviews;
DROP TABLE IF EXISTS Notifications;
DROP TABLE IF EXISTS LoginAudit;
DROP TABLE IF EXISTS LessonProgress;
DROP TABLE IF EXISTS QuizAttempts;
DROP TABLE IF EXISTS Deployments;
DROP TABLE IF EXISTS dbo.RememberTokens;

-- Section 5 core, child -> parent
DROP TABLE IF EXISTS Redemptions;
DROP TABLE IF EXISTS RedemptionPartners;
DROP TABLE IF EXISTS PointTransactions;
DROP TABLE IF EXISTS Registry;
DROP TABLE IF EXISTS CommunityWork;
DROP TABLE IF EXISTS Badges;
DROP TABLE IF EXISTS Certificates;
DROP TABLE IF EXISTS Enrollments;
DROP TABLE IF EXISTS Quizzes;
DROP TABLE IF EXISTS Lessons;
DROP TABLE IF EXISTS Courses;
DROP TABLE IF EXISTS Officers;
DROP TABLE IF EXISTS Users;

/* ---------------- Users (Members + Admins) ----------------
   LastLoginDate / LoginStreak drive the Phase-7 login-streak
   feature. EX-track columns (Bio, AvatarPath, 2FA, lockout,
   reset token) are added later by PrepReady_Extras.sql.       */
CREATE TABLE Users (
    UserId            INT IDENTITY(1,1) PRIMARY KEY,
    FullName          NVARCHAR(150)  NOT NULL,
    Email             NVARCHAR(256)  NOT NULL,
    PasswordHash      NVARCHAR(255)  NOT NULL,
    IsEmailVerified   BIT            NOT NULL CONSTRAINT DF_Users_Verified DEFAULT (0),
    EmailVerifyToken  NVARCHAR(100)  NULL,
    PointBalance      INT            NOT NULL CONSTRAINT DF_Users_Points   DEFAULT (0),
    RegistrationDate  DATETIME       NOT NULL CONSTRAINT DF_Users_RegDate  DEFAULT (GETDATE()),
    LastLoginDate     DATETIME       NULL,
    LoginStreak       INT            NOT NULL CONSTRAINT DF_Users_Streak    DEFAULT (0),
    IsActive          BIT            NOT NULL CONSTRAINT DF_Users_Active    DEFAULT (1),
    Role              NVARCHAR(20)   NOT NULL CONSTRAINT DF_Users_Role      DEFAULT ('Member'),
    CONSTRAINT CK_Users_EmailNotEmpty CHECK (Email <> ''),
    CONSTRAINT CK_Users_Role          CHECK (Role IN ('Member','Admin'))
);
CREATE UNIQUE INDEX UX_Users_Email ON Users(Email);

/* ---------------- Officers / Partners --------------------- */
CREATE TABLE Officers (
    OfficerId     INT IDENTITY(1,1) PRIMARY KEY,
    FullName      NVARCHAR(150) NOT NULL,
    Email         NVARCHAR(256) NOT NULL,
    PasswordHash  NVARCHAR(255) NOT NULL,
    Agency        NVARCHAR(150) NOT NULL,   -- "Department/Agency" in spec
    IsActive      BIT NOT NULL CONSTRAINT DF_Officers_Active DEFAULT (1)
);
CREATE UNIQUE INDEX UX_Officers_Email ON Officers(Email);

/* ---------------- Courses ---------------------------------
   Category is a denormalised column (no separate Categories
   table). List categories via SELECT DISTINCT CategoryName.   */
CREATE TABLE Courses (
    CourseId      INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName  NVARCHAR(100) NOT NULL,
    Title         NVARCHAR(200) NOT NULL,
    Description   NVARCHAR(MAX) NULL,
    GovPartner    NVARCHAR(150) NULL,
    PassingMark   INT NOT NULL CONSTRAINT DF_Courses_Pass    DEFAULT (60),
    IsPublished   BIT NOT NULL CONSTRAINT DF_Courses_Pub     DEFAULT (1)
);

/* ---------------- Lessons --------------------------------- */
CREATE TABLE Lessons (
    LessonId   INT IDENTITY(1,1) PRIMARY KEY,
    CourseId   INT NOT NULL,
    Title      NVARCHAR(200) NOT NULL,
    BodyHtml   NVARCHAR(MAX) NULL,
    MediaUrl   NVARCHAR(500) NULL,
    SortOrder  INT NOT NULL CONSTRAINT DF_Lessons_Sort DEFAULT (1),
    CONSTRAINT FK_Lessons_Courses FOREIGN KEY (CourseId) REFERENCES Courses(CourseId)
);

/* ---------------- Quizzes (one question per row) ---------- */
CREATE TABLE Quizzes (
    QuizId        INT IDENTITY(1,1) PRIMARY KEY,
    LessonId      INT NOT NULL,
    Question      NVARCHAR(MAX) NOT NULL,
    OptionA       NVARCHAR(300) NOT NULL,
    OptionB       NVARCHAR(300) NOT NULL,
    OptionC       NVARCHAR(300) NULL,
    OptionD       NVARCHAR(300) NULL,
    CorrectOption CHAR(1) NOT NULL,
    IsFinalExam   BIT NOT NULL CONSTRAINT DF_Quizzes_Final DEFAULT (0),
    CONSTRAINT FK_Quizzes_Lessons FOREIGN KEY (LessonId) REFERENCES Lessons(LessonId),
    CONSTRAINT CK_Quizzes_Correct CHECK (CorrectOption IN ('A','B','C','D'))
);

/* ---------------- Enrollments ----------------------------- */
CREATE TABLE Enrollments (
    EnrollmentId  INT IDENTITY(1,1) PRIMARY KEY,
    UserId        INT NOT NULL,
    CourseId      INT NOT NULL,
    AttemptNumber INT NOT NULL CONSTRAINT DF_Enroll_Attempt DEFAULT (1),
    Status        NVARCHAR(30) NOT NULL CONSTRAINT DF_Enroll_Status DEFAULT ('Enrolled'),
    Score         INT NULL,
    EnrolledDate  DATETIME NOT NULL CONSTRAINT DF_Enroll_Date DEFAULT (GETDATE()),
    CompletedDate DATETIME NULL,
    CONSTRAINT FK_Enroll_Users   FOREIGN KEY (UserId)   REFERENCES Users(UserId),
    CONSTRAINT FK_Enroll_Courses FOREIGN KEY (CourseId) REFERENCES Courses(CourseId)
);

/* ---------------- LessonProgress (build-added) ------------
   One row per lesson a user has completed (read).            */
CREATE TABLE LessonProgress (
    ProgressId    INT IDENTITY(1,1) PRIMARY KEY,
    UserId        INT NOT NULL,
    CourseId      INT NOT NULL,
    LessonId      INT NOT NULL,
    CompletedDate DATETIME NOT NULL CONSTRAINT DF_LP_Date DEFAULT (GETDATE()),
    CONSTRAINT FK_LP_Users      FOREIGN KEY (UserId)   REFERENCES Users(UserId),
    CONSTRAINT FK_LP_Courses    FOREIGN KEY (CourseId) REFERENCES Courses(CourseId),
    CONSTRAINT FK_LP_Lessons    FOREIGN KEY (LessonId) REFERENCES Lessons(LessonId),
    CONSTRAINT UQ_LP_UserLesson UNIQUE (UserId, LessonId)
);

/* ---------------- QuizAttempts (build-added) --------------
   One row per lesson-quiz or final-exam submission.          */
CREATE TABLE QuizAttempts (
    AttemptId      INT IDENTITY(1,1) PRIMARY KEY,
    UserId         INT NOT NULL,
    CourseId       INT NOT NULL,
    LessonId       INT NULL,                 -- NULL for the final exam
    IsFinalExam    BIT NOT NULL CONSTRAINT DF_QA_Final DEFAULT (0),
    Score          INT NOT NULL,
    TotalQuestions INT NOT NULL,
    Percentage     INT NOT NULL,
    Passed         BIT NOT NULL,
    AttemptDate    DATETIME NOT NULL CONSTRAINT DF_QA_Date DEFAULT (GETDATE()),
    CONSTRAINT FK_QA_Users   FOREIGN KEY (UserId)   REFERENCES Users(UserId),
    CONSTRAINT FK_QA_Courses FOREIGN KEY (CourseId) REFERENCES Courses(CourseId),
    CONSTRAINT FK_QA_Lessons FOREIGN KEY (LessonId) REFERENCES Lessons(LessonId)
);

/* ---------------- Certificates ---------------------------- */
CREATE TABLE Certificates (
    CertificateId INT IDENTITY(1,1) PRIMARY KEY,
    CertCode      NVARCHAR(50) NOT NULL,
    UserId        INT NOT NULL,
    CourseId      INT NOT NULL,
    Tier          INT NOT NULL CONSTRAINT DF_Cert_Tier DEFAULT (1),
    IssueDate     DATETIME NOT NULL CONSTRAINT DF_Cert_Issue DEFAULT (GETDATE()),
    ExpiryDate    DATETIME NOT NULL,
    QrData        NVARCHAR(500) NULL,
    CONSTRAINT FK_Cert_Users   FOREIGN KEY (UserId)   REFERENCES Users(UserId),
    CONSTRAINT FK_Cert_Courses FOREIGN KEY (CourseId) REFERENCES Courses(CourseId),
    CONSTRAINT CK_Cert_Tier    CHECK (Tier IN (1,2,3))
);
CREATE UNIQUE INDEX UX_Cert_Code ON Certificates(CertCode);

/* ---------------- Badges ---------------------------------- */
CREATE TABLE Badges (
    BadgeId         INT IDENTITY(1,1) PRIMARY KEY,
    CertificateId   INT NOT NULL,
    EndorsingAgency NVARCHAR(150) NOT NULL,
    IssueDate       DATETIME NOT NULL CONSTRAINT DF_Badge_Issue DEFAULT (GETDATE()),
    ExpiryDate      DATETIME NOT NULL,
    CONSTRAINT FK_Badges_Cert FOREIGN KEY (CertificateId) REFERENCES Certificates(CertificateId)
);

/* ---------------- CommunityWork --------------------------- */
CREATE TABLE CommunityWork (
    WorkId         INT IDENTITY(1,1) PRIMARY KEY,
    UserId         INT NOT NULL,
    OfficerId      INT NULL,                 -- null until an officer accepts
    DeploymentCode NVARCHAR(50) NOT NULL,
    ServiceDate    DATETIME NULL,
    DurationHours  DECIMAL(5,2) NULL,
    ActivityNote   NVARCHAR(500) NULL,
    IsSignedOff    BIT NOT NULL CONSTRAINT DF_CW_Signed DEFAULT (0),
    SignedOffDate  DATETIME NULL,
    CONSTRAINT FK_CW_Users    FOREIGN KEY (UserId)    REFERENCES Users(UserId),
    CONSTRAINT FK_CW_Officers FOREIGN KEY (OfficerId) REFERENCES Officers(OfficerId)
);

/* ---------------- Deployments (build-added) ---------------
   The Officer-Portal deployment workflow (apply -> accept/
   decline -> complete -> Tier-3 badge). Status text values:
   Pending / Accepted / Declined / Completed.                 */
CREATE TABLE Deployments (
    DeploymentId    INT IDENTITY(1,1) PRIMARY KEY,
    UserId          INT NOT NULL,
    CourseId        INT NOT NULL,
    OfficerId       INT NULL,
    DeploymentCode  NVARCHAR(50) NOT NULL,
    RecognisedField NVARCHAR(150) NOT NULL,
    EndorsingAgency NVARCHAR(150) NOT NULL,
    Status          NVARCHAR(20) NOT NULL CONSTRAINT DF_Dep_Status DEFAULT ('Pending'),
    AppliedDate     DATETIME NOT NULL CONSTRAINT DF_Dep_Applied DEFAULT (GETDATE()),
    BadgeIssued     BIT NOT NULL CONSTRAINT DF_Dep_Badge DEFAULT (0),
    CONSTRAINT FK_Dep_Users    FOREIGN KEY (UserId)    REFERENCES Users(UserId),
    CONSTRAINT FK_Dep_Courses  FOREIGN KEY (CourseId)  REFERENCES Courses(CourseId),
    CONSTRAINT FK_Dep_Officers FOREIGN KEY (OfficerId) REFERENCES Officers(OfficerId)
);

/* ---------------- Registry (public) ----------------------- */
CREATE TABLE Registry (
    RegistryId      INT IDENTITY(1,1) PRIMARY KEY,
    UserId          INT NOT NULL,
    BadgeId         INT NOT NULL,
    RecognisedField NVARCHAR(150) NOT NULL,
    IssueDate       DATETIME NOT NULL,
    ExpiryDate      DATETIME NOT NULL,
    EndorsingAgency NVARCHAR(150) NOT NULL,
    QrData          NVARCHAR(500) NULL,
    CONSTRAINT FK_Reg_Users  FOREIGN KEY (UserId)  REFERENCES Users(UserId),
    CONSTRAINT FK_Reg_Badges FOREIGN KEY (BadgeId) REFERENCES Badges(BadgeId)
);

/* ---------------- PointTransactions (ledger) -------------- */
CREATE TABLE PointTransactions (
    TxnId    INT IDENTITY(1,1) PRIMARY KEY,
    UserId   INT NOT NULL,
    Points   INT NOT NULL,                   -- positive or negative
    Reason   NVARCHAR(200) NOT NULL,
    TxnDate  DATETIME NOT NULL CONSTRAINT DF_Txn_Date DEFAULT (GETDATE()),
    CONSTRAINT FK_Txn_Users FOREIGN KEY (UserId) REFERENCES Users(UserId)
);

/* ---------------- RedemptionPartners ---------------------- */
CREATE TABLE RedemptionPartners (
    PartnerId    INT IDENTITY(1,1) PRIMARY KEY,
    Name         NVARCHAR(150) NOT NULL,
    PartnerType  NVARCHAR(50)  NOT NULL,
    VoucherTitle NVARCHAR(200) NOT NULL,
    PointCost    INT NOT NULL,
    IsActive     BIT NOT NULL CONSTRAINT DF_Partner_Active DEFAULT (1)
);

/* ---------------- Redemptions ----------------------------- */
CREATE TABLE Redemptions (
    RedemptionId INT IDENTITY(1,1) PRIMARY KEY,
    UserId       INT NOT NULL,
    PartnerId    INT NOT NULL,
    PointsSpent  INT NOT NULL,
    VoucherCode  NVARCHAR(50) NOT NULL,
    RedeemedDate DATETIME NOT NULL CONSTRAINT DF_Redeem_Date DEFAULT (GETDATE()),
    CONSTRAINT FK_Redeem_Users    FOREIGN KEY (UserId)    REFERENCES Users(UserId),
    CONSTRAINT FK_Redeem_Partners FOREIGN KEY (PartnerId) REFERENCES RedemptionPartners(PartnerId)
);

PRINT 'PrepReady schema created successfully.';