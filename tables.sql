
-----------------------------------------------------------------------------------------------------------------------
--Creating tables

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
GO

--viewers
CREATE TABLE [viewer] (
  id                        INTEGER PRIMARY KEY REFERENCES [user] (id) ON DELETE CASCADE,
  [working place]             VARCHAR(255),
  [working place type]        VARCHAR(255),
  [working place description] VARCHAR(255)
);
GO

--Notified Person
CREATE TABLE [notified person] (
  id INTEGER PRIMARY KEY
);
GO

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
GO

--staff
CREATE TABLE [staff] (
  id            INTEGER PRIMARY KEY  REFERENCES [user] (id) ON DELETE CASCADE,
  [hire date]     DATE    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  [working hours] INT,
  [payment rate]  REAL,
  [total salary] AS ([working hours] * [payment rate]),
  [notified id]   INTEGER NOT NULL REFERENCES [notified person] (id)
);
GO

--content type
CREATE TABLE [content type] (
  type VARCHAR(255) PRIMARY KEY NOT NULL
);
GO

--content manager
CREATE TABLE [content manager] (
  id   INTEGER PRIMARY KEY  REFERENCES [staff] (id) ON DELETE CASCADE,
  type VARCHAR(255) REFERENCES [content type] (type)
);
GO

--reviewer
CREATE TABLE [reviewer] (
  id INTEGER PRIMARY KEY  REFERENCES [staff] (id) ON DELETE CASCADE,
);
GO

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
GO

--category
CREATE TABLE [category] (
  type        VARCHAR(255) PRIMARY KEY NOT NULL,
  description VARCHAR(255)
);
GO

--subcategory
CREATE TABLE [subcategory] (
  [category type] VARCHAR(255) NOT NULL REFERENCES [category] (type),
  name          VARCHAR(255) NOT NULL,
  CONSTRAINT PK_subcategory PRIMARY KEY ([category type], name)
);
GO

--notification object
CREATE TABLE [notification object] (
  id INTEGER PRIMARY KEY NOT NULL IDENTITY
);
GO

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
GO

--content
CREATE TABLE [content] (
  id               INTEGER PRIMARY KEY NOT NULL IDENTITY,
  [uploaded at]      DATETIME            NOT NULL,
  [contributor id]   INTEGER             NOT NULL REFERENCES [contributor] (id),
  [category type]    VARCHAR(255)        NOT NULL,
  [subcategory name] VARCHAR(255)        NOT NULL,
  type             VARCHAR(255) REFERENCES [content type] (type),
  link             VARCHAR(255),
  CONSTRAINT FK FOREIGN KEY ([category type], [subcategory name]) REFERENCES [subcategory] ([category type], name)
);
GO

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
GO

--existing request
CREATE TABLE [existing request] (
  id                  INTEGER PRIMARY KEY NOT NULL IDENTITY,
  [original content id] INTEGER             NOT NULL REFERENCES [original content] (id)
    ON DELETE CASCADE,
  [viewer id]           INTEGER             NOT NULL REFERENCES [viewer] (id)
    ON DELETE CASCADE
);
GO

--new content
CREATE TABLE [new content] (
  id             INTEGER PRIMARY KEY NOT NULL REFERENCES [content] (id)
    ON DELETE CASCADE,
  [new request id] INTEGER             NOT NULL REFERENCES [new request] (id)
    ON DELETE CASCADE
);
GO

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
GO

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
GO

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
GO

--event photos link
CREATE TABLE [event Photos Link] (
  [event id] INTEGER      NOT NULL REFERENCES [event] (id),
  link     VARCHAR(255) NOT NULL,
  CONSTRAINT PK_event_Photos_Link PRIMARY KEY ([event id], link)
);
GO

--event videos link
CREATE TABLE [event Videos Link] (
  [event id] INTEGER      NOT NULL REFERENCES [event] (id),
  link     VARCHAR(255) NOT NULL,
  CONSTRAINT PK_event_Videos_Link PRIMARY KEY ([event id], link)
);
GO

--advertisement
CREATE TABLE [advertisement] (
  id          INTEGER PRIMARY KEY NOT NULL IDENTITY,
  description VARCHAR(255),
  location    VARCHAR(255),
  [event id]    INTEGER REFERENCES [event] (id),
  [viewer id]   INTEGER             NOT NULL REFERENCES [viewer] (id)
    ON DELETE CASCADE
)
GO

--Ad video link
CREATE TABLE [Ads Video Link] (
  [advertisement id] INTEGER      NOT NULL REFERENCES [advertisement] (id)
    ON DELETE CASCADE,
  link             VARCHAR(255) NOT NULL,
  CONSTRAINT PK_Ads_Video_Link PRIMARY KEY ([advertisement id], link)
);
GO

--Ad photos link
CREATE TABLE [Ads Photos Link] (
  [advertisement id] INTEGER      NOT NULL REFERENCES [advertisement] (id)
    ON DELETE CASCADE,
  link             VARCHAR(255) NOT NULL,
  CONSTRAINT PK_Ads_Photos_Link PRIMARY KEY ([advertisement id], link)
);
GO

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
GO
