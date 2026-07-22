-- ============================================================
--  PrepReady_Extras.sql
--  Schema migration for the 10 extra features (EX-1 .. EX-10).
--  IDEMPOTENT: every change is guarded, so it is safe to run
--  this script more than once.
--
--  HOW TO RUN: Server Explorer -> right-click PrepReadyDB.mdf
--  -> New Query -> paste -> Execute.  Run this AFTER the main
--  PrepReady_Schema.sql and PrepReady_Seed.sql have been applied.
--
--  KEEP IN SYNC: for a clean rebuild, run this script immediately
--  after PrepReady_Schema.sql + PrepReady_Seed.sql.
-- ============================================================

/* -----------------------------------------------------------
   1) Users: new columns
   - EX-1  PasswordResetToken / PasswordResetExpiry
   - EX-2  Bio / AvatarPath
   - EX-3  FailedLoginCount / LockoutUntil
   - EX-10 TwoFactorEnabled / OtpCode / OtpExpiry
   ----------------------------------------------------------- */
IF COL_LENGTH('dbo.Users','PasswordResetToken') IS NULL
    ALTER TABLE dbo.Users ADD PasswordResetToken NVARCHAR(100) NULL;
GO
IF COL_LENGTH('dbo.Users','PasswordResetExpiry') IS NULL
    ALTER TABLE dbo.Users ADD PasswordResetExpiry DATETIME NULL;
GO
IF COL_LENGTH('dbo.Users','Bio') IS NULL
    ALTER TABLE dbo.Users ADD Bio NVARCHAR(500) NULL;
GO
IF COL_LENGTH('dbo.Users','AvatarPath') IS NULL
    ALTER TABLE dbo.Users ADD AvatarPath NVARCHAR(260) NULL;
GO
IF COL_LENGTH('dbo.Users','FailedLoginCount') IS NULL
    ALTER TABLE dbo.Users ADD FailedLoginCount INT NOT NULL CONSTRAINT DF_Users_FailedLoginCount DEFAULT(0);
GO
IF COL_LENGTH('dbo.Users','LockoutUntil') IS NULL
    ALTER TABLE dbo.Users ADD LockoutUntil DATETIME NULL;
GO
IF COL_LENGTH('dbo.Users','TwoFactorEnabled') IS NULL
    ALTER TABLE dbo.Users ADD TwoFactorEnabled BIT NOT NULL CONSTRAINT DF_Users_TwoFactorEnabled DEFAULT(0);
GO
IF COL_LENGTH('dbo.Users','OtpCode') IS NULL
    ALTER TABLE dbo.Users ADD OtpCode NVARCHAR(10) NULL;
GO
IF COL_LENGTH('dbo.Users','OtpExpiry') IS NULL
    ALTER TABLE dbo.Users ADD OtpExpiry DATETIME NULL;
GO

/* -----------------------------------------------------------
   2) LoginAudit  (EX-3) - one row per login attempt
   ----------------------------------------------------------- */
IF OBJECT_ID('dbo.LoginAudit','U') IS NULL
CREATE TABLE dbo.LoginAudit (
    AuditId     INT IDENTITY(1,1) PRIMARY KEY,
    Email       NVARCHAR(256) NOT NULL,
    UserId      INT           NULL,
    Success     BIT           NOT NULL,
    IpAddress   NVARCHAR(45)  NULL,        -- IPv4/IPv6
    Note        NVARCHAR(200) NULL,        -- e.g. "Locked out", "Bad password"
    AttemptDate DATETIME      NOT NULL CONSTRAINT DF_LoginAudit_Date DEFAULT(GETDATE())
);
GO

/* -----------------------------------------------------------
   3) Notifications  (EX-4) - in-app bell
   ----------------------------------------------------------- */
IF OBJECT_ID('dbo.Notifications','U') IS NULL
CREATE TABLE dbo.Notifications (
    NotificationId INT IDENTITY(1,1) PRIMARY KEY,
    UserId         INT           NOT NULL,
    Title          NVARCHAR(150) NOT NULL,
    Message        NVARCHAR(500) NOT NULL,
    LinkUrl        NVARCHAR(260) NULL,
    IsRead         BIT           NOT NULL CONSTRAINT DF_Notifications_IsRead DEFAULT(0),
    CreatedDate    DATETIME      NOT NULL CONSTRAINT DF_Notifications_Date DEFAULT(GETDATE()),
    CONSTRAINT FK_Notifications_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId)
);
GO

/* -----------------------------------------------------------
   4) CourseReviews  (EX-5) - 1..5 stars + comment, one per user/course
   ----------------------------------------------------------- */
IF OBJECT_ID('dbo.CourseReviews','U') IS NULL
CREATE TABLE dbo.CourseReviews (
    ReviewId    INT IDENTITY(1,1) PRIMARY KEY,
    CourseId    INT            NOT NULL,
    UserId      INT            NOT NULL,
    Rating      INT            NOT NULL,
    Comment     NVARCHAR(1000) NULL,
    CreatedDate DATETIME       NOT NULL CONSTRAINT DF_CourseReviews_Date DEFAULT(GETDATE()),
    CONSTRAINT FK_CourseReviews_Courses FOREIGN KEY (CourseId) REFERENCES dbo.Courses(CourseId),
    CONSTRAINT FK_CourseReviews_Users   FOREIGN KEY (UserId)   REFERENCES dbo.Users(UserId),
    CONSTRAINT CK_CourseReviews_Rating  CHECK (Rating BETWEEN 1 AND 5),
    CONSTRAINT UQ_CourseReviews_User    UNIQUE (CourseId, UserId)
);
GO

/* -----------------------------------------------------------
   5) ContactMessages  (EX-8) - public "Contact us" inbox
   ----------------------------------------------------------- */
IF OBJECT_ID('dbo.ContactMessages','U') IS NULL
CREATE TABLE dbo.ContactMessages (
    MessageId   INT IDENTITY(1,1) PRIMARY KEY,
    FullName    NVARCHAR(150)  NOT NULL,
    Email       NVARCHAR(256)  NOT NULL,
    Subject     NVARCHAR(200)  NOT NULL,
    Body        NVARCHAR(2000) NOT NULL,
    IsResolved  BIT            NOT NULL CONSTRAINT DF_ContactMessages_Resolved DEFAULT(0),
    CreatedDate DATETIME       NOT NULL CONSTRAINT DF_ContactMessages_Date DEFAULT(GETDATE())
);
GO

/* -----------------------------------------------------------
   6) Bookmarks  (EX-9) - saved courses, one per user/course
   ----------------------------------------------------------- */
IF OBJECT_ID('dbo.Bookmarks','U') IS NULL
CREATE TABLE dbo.Bookmarks (
    BookmarkId  INT IDENTITY(1,1) PRIMARY KEY,
    UserId      INT      NOT NULL,
    CourseId    INT      NOT NULL,
    CreatedDate DATETIME NOT NULL CONSTRAINT DF_Bookmarks_Date DEFAULT(GETDATE()),
    CONSTRAINT FK_Bookmarks_Users   FOREIGN KEY (UserId)   REFERENCES dbo.Users(UserId),
    CONSTRAINT FK_Bookmarks_Courses FOREIGN KEY (CourseId) REFERENCES dbo.Courses(CourseId),
    CONSTRAINT UQ_Bookmarks UNIQUE (UserId, CourseId)
);
GO

PRINT 'PrepReady_Extras.sql applied successfully.';
GO

/* ===========================================================
   EX-8b — Contact conversations (threaded replies)
   Idempotent. Run against PrepReadyDB (NOT master).
   =========================================================== */

-- ContactMessages: link the registered submitter + track last activity
IF COL_LENGTH('dbo.ContactMessages','UserId') IS NULL
    ALTER TABLE dbo.ContactMessages ADD UserId INT NULL;

IF COL_LENGTH('dbo.ContactMessages','LastReplyDate') IS NULL
    ALTER TABLE dbo.ContactMessages ADD LastReplyDate DATETIME NULL;

-- Backfill LastReplyDate for any existing rows (EXEC = deferred resolution, no GO needed)
EXEC('UPDATE dbo.ContactMessages SET LastReplyDate = CreatedDate WHERE LastReplyDate IS NULL');

-- ContactReplies: the conversation timeline
IF OBJECT_ID('dbo.ContactReplies','U') IS NULL
BEGIN
    CREATE TABLE dbo.ContactReplies (
        ReplyId       INT IDENTITY(1,1) PRIMARY KEY,
        MessageId     INT NOT NULL,
        SenderRole    NVARCHAR(20)   NOT NULL,   -- 'User' / 'Admin' / 'Officer'
        SenderUserId  INT NULL,                  -- no FK (officers have no Users row)
        SenderName    NVARCHAR(150)  NOT NULL,
        Body          NVARCHAR(2000) NOT NULL,
        CreatedDate   DATETIME NOT NULL CONSTRAINT DF_ContactReplies_Created DEFAULT (GETDATE()),
        CONSTRAINT FK_ContactReplies_Message FOREIGN KEY (MessageId)
            REFERENCES dbo.ContactMessages(MessageId)
    );
END

-- ===== EX-16: trusted-device "remember me" tokens =====
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.RememberTokens') AND type = N'U')
BEGIN
    CREATE TABLE dbo.RememberTokens (
        TokenId       INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        UserId        INT           NOT NULL,
        Selector      NVARCHAR(32)  NOT NULL,   -- public lookup id (unique, indexed)
        ValidatorHash NVARCHAR(128) NOT NULL,   -- SHA-256(validator) as hex; the raw validator is never stored
        Expiry        DATETIME      NOT NULL,
        CreatedDate   DATETIME      NOT NULL CONSTRAINT DF_RememberTokens_Created DEFAULT (GETDATE()),
        CONSTRAINT FK_RememberTokens_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId)
    );
    CREATE UNIQUE INDEX UX_RememberTokens_Selector ON dbo.RememberTokens(Selector);
END
GO