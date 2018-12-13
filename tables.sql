--users
CREATE TABLE [user] (
  id          INTEGER PRIMARY KEY          IDENTITY,
  email       VARCHAR(255) UNIQUE NOT NULL,
  [first name]  VARCHAR(255)        NOT NULL,
  [middle name] VARCHAR(255)  DEFAULT '',
  [last name]   VARCHAR(255)        NOT NULL,
  birthday  DATE                NOT NULL,
  age                                      AS (YEAR(CURRENT_TIMESTAMP) - YEAR(birthday)),
  password    VARCHAR(255)        NOT NULL,
  [last login]  DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP,
  active      BIT                 NOT NULL DEFAULT 1
);


--viewers
CREATE TABLE [viewer] (
  id                        INTEGER PRIMARY KEY REFERENCES [user] (id) ON DELETE CASCADE,
  [working place]             VARCHAR(255),
  [working place type]        VARCHAR(255),
  [working place description] VARCHAR(255)
);


--Notified Person
CREATE TABLE [notified person] (
  id INTEGER PRIMARY KEY
);


-- contributors
CREATE TABLE [contributor] (
  id                  INTEGER PRIMARY KEY REFERENCES [user] (id) ON DELETE CASCADE,
  [years of experience] INTEGER,
  [portfolio link]      VARCHAR(255),
  specialization      VARCHAR(255),
  [notified id]         INTEGER NOT NULL REFERENCES [notified person] (id),
  [average upload time] DATETIME,
  [current requests] INTEGER NOT NULL DEFAULT 0
);


--staff
CREATE TABLE [staff] (
  id            INTEGER PRIMARY KEY  REFERENCES [user] (id) ON DELETE CASCADE,
  [hire date]     DATE    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  [working hours] INT,
  [payment rate]  REAL,
  [total salary] AS ([working hours] * [payment rate]),
  [notified id]   INTEGER NOT NULL REFERENCES [notified person] (id)
);


--content type
CREATE TABLE [content type] (
  type VARCHAR(255) PRIMARY KEY NOT NULL
);


--content manager
CREATE TABLE [content manager] (
  id   INTEGER PRIMARY KEY  REFERENCES [staff] (id) ON DELETE CASCADE,
  type VARCHAR(255) REFERENCES [content type] (type)
);


--reviewer
CREATE TABLE [reviewer] (
  id INTEGER PRIMARY KEY  REFERENCES [staff] (id) ON DELETE CASCADE,
);


--messagess
CREATE TABLE [messages] (
  [sent at]        DATETIME NOT NULL,
  [contributor id] INTEGER  NOT NULL REFERENCES [contributor] (id),
  [viewer id]      INTEGER  NOT NULL REFERENCES [viewer] (id),
  [sender type]    BIT      NOT NULL,
  [read at]        DATETIME,
  text           VARCHAR(255)     NOT NULL,
  [read status]    BIT     NOT NULL DEFAULT 0,
  PRIMARY KEY ([sent at], [contributor id], [viewer id], [sender type])
);


--category
CREATE TABLE [category] (
  type        VARCHAR(255) PRIMARY KEY NOT NULL,
  description VARCHAR(255)
);


--subcategory
CREATE TABLE [subcategory] (
  [category type] VARCHAR(255) NOT NULL REFERENCES [category] (type),
  name          VARCHAR(255) NOT NULL,
  CONSTRAINT PK_subcategory PRIMARY KEY ([category type], name)
);


--notification object
CREATE TABLE [notification object] (
  id INTEGER PRIMARY KEY NOT NULL IDENTITY
);


--new request
CREATE TABLE [new request] (
  id             INTEGER PRIMARY KEY NOT NULL IDENTITY,
  [accept status]  BIT,
  [accept time]    DATETIME,
  specified      BIT                 NOT NULL,
  information    VARCHAR(255)                NOT NULL,
  [viewer id]      INTEGER             NOT NULL REFERENCES [viewer] (id) ON DELETE CASCADE,
  [notif obj id]   INTEGER             NOT NULL UNIQUE REFERENCES [notification object] (id) ON DELETE CASCADE,
  [contributor id] INTEGER REFERENCES [contributor] (id)
);


--content
CREATE TABLE [content] (
  id               INTEGER PRIMARY KEY NOT NULL IDENTITY,
  [uploaded at]      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP,
  [contributor id]   INTEGER             NOT NULL REFERENCES [contributor] (id),
  [category type]    VARCHAR(255)        NOT NULL,
  [subcategory name] VARCHAR(255)        NOT NULL,
  type             VARCHAR(255) REFERENCES [content type] (type),
  link             VARCHAR(255),
  CONSTRAINT FK FOREIGN KEY ([category type], [subcategory name]) REFERENCES [subcategory] ([category type], name)
);


--original content
CREATE TABLE [original content] (
  id                 INTEGER PRIMARY KEY NOT NULL REFERENCES [content] (id)
    ON DELETE CASCADE,
  [content manager id] INTEGER REFERENCES [content manager] (id),
  [reviewer id]        INTEGER REFERENCES [reviewer] (id),
  [review status]      BIT,
  [filter status]      BIT,
  rating             INTEGER
);


--existing request
CREATE TABLE [existing request] (
  id                  INTEGER PRIMARY KEY NOT NULL IDENTITY,
  [original content id] INTEGER             NOT NULL REFERENCES [original content] (id)
    ON DELETE CASCADE,
  [viewer id]           INTEGER             NOT NULL REFERENCES [viewer] (id)
    ON DELETE CASCADE
);


--new content
CREATE TABLE [new content] (
  id             INTEGER PRIMARY KEY NOT NULL REFERENCES [content] (id)
    ON DELETE CASCADE,
  [new request id] INTEGER             NOT NULL REFERENCES [new request] (id)
    ON DELETE CASCADE
);


--comment
CREATE TABLE [comment] (
  [viewer id]           INTEGER  NOT NULL REFERENCES [viewer] (id)
    ON DELETE CASCADE,
  [original content id] INTEGER  NOT NULL REFERENCES [original content] (id)
    ON DELETE CASCADE,
  date                DATETIME NOT NULL,
  text                VARCHAR(255)     NOT NULL,
  CONSTRAINT PK_comment PRIMARY KEY ([viewer id], [original content id], date)
);


--rate
CREATE TABLE [rate] (
  [viewer id]           INTEGER  NOT NULL REFERENCES [viewer] (id)
    ON DELETE CASCADE,
  [original content id] INTEGER  NOT NULL REFERENCES [original content] (id)
    ON DELETE CASCADE,
  date                DATETIME NOT NULL,
  rate                INTEGER,
  CONSTRAINT [PK_rate] PRIMARY KEY ([viewer id], [original content id])
);


--event
CREATE TABLE [event] (
  id                     INTEGER PRIMARY KEY NOT NULL IDENTITY,
  description            VARCHAR(255)                NOT NULL,
  location               VARCHAR(255)        NOT NULL,
  city                   VARCHAR(255)        NOT NULL,
  time                   DATETIME            NOT NULL,
  entertainer            VARCHAR(255)        NOT NULL,
  [notification object id] INTEGER             NOT NULL UNIQUE REFERENCES [notification object] (id),
  [viewer id]              INTEGER             NOT NULL REFERENCES [viewer] (id)
);


--event photos link
CREATE TABLE [event Photos Link] (
  [event id] INTEGER      NOT NULL REFERENCES [event] (id),
  link     VARCHAR(255) NOT NULL,
  CONSTRAINT PK_event_Photos_Link PRIMARY KEY ([event id], link)
);


--event videos link
CREATE TABLE [event Videos Link] (
  [event id] INTEGER      NOT NULL REFERENCES [event] (id),
  link     VARCHAR(255) NOT NULL,
  CONSTRAINT PK_event_Videos_Link PRIMARY KEY ([event id], link)
);


--advertisement
CREATE TABLE [advertisement] (
  id          INTEGER PRIMARY KEY NOT NULL IDENTITY,
  description VARCHAR(255),
  location    VARCHAR(255),
  [event id]    INTEGER REFERENCES [event] (id),
  [viewer id]   INTEGER             NOT NULL REFERENCES [viewer] (id)
    ON DELETE CASCADE
)


--Ad video link
CREATE TABLE [Ads Video Link] (
  [advertisement id] INTEGER      NOT NULL REFERENCES [advertisement] (id)
    ON DELETE CASCADE,
  link             VARCHAR(255) NOT NULL,
  CONSTRAINT PK_Ads_Video_Link PRIMARY KEY ([advertisement id], link)
);


--Ad photos link
CREATE TABLE [Ads Photos Link] (
  [advertisement id] INTEGER      NOT NULL REFERENCES [advertisement] (id)
    ON DELETE CASCADE,
  link             VARCHAR(255) NOT NULL,
  CONSTRAINT PK_Ads_Photos_Link PRIMARY KEY ([advertisement id], link)
);


--announcement
CREATE TABLE [announcement] (
  id                     INTEGER PRIMARY KEY NOT NULL IDENTITY,
  [seen at]                DATETIME,
  [sent at]                DATETIME,
  [notified person id]     INTEGER             NOT NULL REFERENCES [notified person] (id)
    ON DELETE CASCADE,
  [notification object id] INTEGER             NOT NULL REFERENCES [notification object] (id)
    ON DELETE CASCADE
);



-----------------------------------------------------------------------------------------------------------
-- Data insertion
-----------------------------------------------------------------------------------------------------------
INSERT INTO [user] (email, [first name], [middle name], [last name], birthday, password) VALUES
('viewer1@mail', 'Viewer', 'Middlename', 'Lastname', '1-1-1999', 'passwd'),
('viewer2@mail', 'Viewer', 'Middlename', 'Lastname', '1-1-1999', 'passwd'),
('viewer3@mail', 'Viewer', 'Middlename', 'Lastname', '1-1-1999', 'passwd'),
('viewer4@mail', 'Viewer', 'Middlename', 'Lastname', '1-1-1999', 'passwd'),

('contri1@mail', 'contri', 'Middlename', 'Lastname', '1-1-1999', 'passwd'),
('contri2@mail', 'contri', 'Middlename', 'Lastname', '1-1-1999', 'passwd'),
('contri3@mail', 'contri', 'Middlename', 'Lastname', '1-1-1999', 'passwd'),
('contri4@mail', 'contri', 'Middlename', 'Lastname', '1-1-1999', 'passwd'),

('review1@mail', 'review', 'Middlename', 'Lastname', '1-1-1999', 'passwd'),
('review2@mail', 'review', 'Middlename', 'Lastname', '1-1-1999', 'passwd'),
('review3@mail', 'review', 'Middlename', 'Lastname', '1-1-1999', 'passwd'),
('review4@mail', 'review', 'Middlename', 'Lastname', '1-1-1999', 'passwd'),

('manage1@mail', 'manage', 'Middlename', 'Lastname', '1-1-1999', 'passwd'),
('manage2@mail', 'manage', 'Middlename', 'Lastname', '1-1-1999', 'passwd'),
('manage3@mail', 'manage', 'Middlename', 'Lastname', '1-1-1999', 'passwd'),
('manage4@mail', 'manage', 'Middlename', 'Lastname', '1-1-1999', 'passwd');


INSERT INTO [viewer] (id, [working place], [working place type], [working place description]) VALUES
(1, 'Working place', 'Working place type', 'Working place description'),
(2, 'Working place', 'Working place type', 'Working place description'),
(3, 'Working place', 'Working place type', 'Working place description'),
(4, 'Working place', 'Working place type', 'Working place description');


INSERT INTO [notified person] (id) VALUES
(5),
(6),
(7),
(8),

(9),
(10),
(11),
(12),

(13),
(14),
(15),
(16);


INSERT INTO [contributor] (id, [years of experience], [portfolio link], specialization, [notified id]) VALUES
(5, 1, 'portfoliolink.com', 'art', 5),
(6, 2, 'portfoliolink.com', 'art', 6),
(7, 3, 'portfoliolink.com', 'art', 7),
(8, 3, 'portfoliolink.com', 'art', 8);


INSERT INTO [staff] (id, [hire date], [working hours], [payment rate], [notified id]) VALUES
(9, '8/12/2018', 8, 10, 9),
(10, '12/12/2018', 8, 11, 10),
(11, '12/12/2018', 8, 15, 11),
(12, '10/12/2018', 8, 10, 12),

(13, '9/12/2018', 8, 10, 13),
(14, '8/12/2018', 8, 20, 14),
(15, '7/12/2018', 8, 10, 15),
(16, '6/12/2018', 8, 100, 16);


INSERT INTO [reviewer] (id) VALUES
(9),
(10),
(11),
(12);


INSERT INTO [content manager] (id) VALUES
(13),
(14),
(15),
(16);

INSERT INTO [content type] (type) VALUES ('Recreational');
INSERT INTO [category] (type) VALUES ('Music');
INSERT INTO [subcategory] ([category type], name) VALUES ('Music', 'Blues');

INSERT INTO [content] ([contributor id], [category type], [subcategory name], type, link) VALUES
(5, 'Music', 'Blues', 'Recreational', 'content.com'),
(5, 'Music', 'Blues', 'Recreational', 'content.com'),

(6, 'Music', 'Blues', 'Recreational', 'content.com'),
(6, 'Music', 'Blues', 'Recreational', 'content.com'),

(7, 'Music', 'Blues', 'Recreational', 'content.com'),
(7, 'Music', 'Blues', 'Recreational', 'content.com'),

(8, 'Music', 'Blues', 'Recreational', 'content.com'),
(8, 'Music', 'Blues', 'Recreational', 'content.com');


INSERT INTO [original content] (id, [content manager id], [reviewer id], [review status], [filter status], rating) VALUES
(1, 13, 9, 1, 1, 4),
(2, 13, 9, 1, 1, 4),

(3, 13, 9, 1, 1, 4),
(4, 13, 9, 1, 1, 4),

(5, 13, 9, 1, 1, 4),
(6, 13, 9, 1, 1, 4),

(7, 13, 9, 1, 1, 4),
(8, 13, 9, 1, 1, 4);
