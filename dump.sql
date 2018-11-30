CREATE DATABASE IEgypt_78;
GO
USE IEgypt_78;
GO
-----------------------------------------------------------------------------------------------------------------------
--Creating tables

--Users
CREATE TABLE [User] (
  ID          INTEGER PRIMARY KEY          IDENTITY,
  email       VARCHAR(255) UNIQUE NOT NULL,
  first_name  VARCHAR(255)        NOT NULL,
  middle_name VARCHAR(255),
  last_name   VARCHAR(255)        NOT NULL,
  birth_date  DATE                NOT NULL,
  age                                      AS (YEAR(CURRENT_TIMESTAMP) - YEAR(birth_date)),
  password    VARCHAR(255)        NOT NULL,
  last_login  DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP,
  active      BIT                 NOT NULL DEFAULT 1
);
GO

--Viewers
CREATE TABLE [Viewer] (
  ID                        INTEGER PRIMARY KEY REFERENCES [User] (ID),
  working_place             VARCHAR(255),
  working_place_type        VARCHAR(255),
  working_place_description TEXT
);
GO

--Notified Person
CREATE TABLE [Notified_Person] (
  ID INTEGER PRIMARY KEY
);
GO

--Contributors
CREATE TABLE [Contributor] (
  ID                  INTEGER PRIMARY KEY REFERENCES [User] (ID),
  years_of_experience INTEGER,
  portfolio_link      TEXT,
  specialization      TEXT,
  notified_id         INTEGER NOT NULL REFERENCES [Notified_Person] (ID),
  average_upload_time DATETIME,
  current_requests INTEGER NOT NULL DEFAULT 0
);
GO

--Staff
CREATE TABLE [Staff] (
  ID            INTEGER PRIMARY KEY  REFERENCES [User] (ID),
  hire_date     DATE    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  working_hours INT     NOT NULL,
  payment_rate  REAL    NOT NULL,
  total_salary AS (working_hours * payment_rate),
  notified_id   INTEGER NOT NULL REFERENCES [Notified_Person] (ID)
);
GO

--Content type
CREATE TABLE [Content_type] (
  type VARCHAR(255) PRIMARY KEY NOT NULL
);
GO

--Content Manager
CREATE TABLE [Content_Manager] (
  ID   INTEGER PRIMARY KEY  REFERENCES [Staff] (ID),
  type VARCHAR(255) REFERENCES [Content_type] (type)
);
GO

--Reviewer
CREATE TABLE [Reviewer] (
  ID INTEGER PRIMARY KEY  REFERENCES [Staff] (ID),
);
GO

--Messages
CREATE TABLE [Message] (
  sent_at        DATETIME NOT NULL,
  contributer_id INTEGER  NOT NULL REFERENCES [Contributor] (ID),
  viewer_id      INTEGER  NOT NULL REFERENCES [Viewer] (ID),
  sender_type    BIT      NOT NULL,
  read_at        DATETIME,
  text           TEXT     NOT NULL,
  read_status    BIT     NOT NULL DEFAULT 0,
  PRIMARY KEY (sent_at, contributer_id, viewer_id, sender_type)
);
GO

--Category
CREATE TABLE [Category] (
  type        VARCHAR(255) PRIMARY KEY NOT NULL,
  description TEXT
);
GO

--Subcategory
CREATE TABLE [Sub_Category] (
  category_type VARCHAR(255) NOT NULL REFERENCES [Category] (type),
  name          VARCHAR(255) NOT NULL,
  CONSTRAINT PK_Subcategory PRIMARY KEY (category_type, name)
);
GO

--Notification object
CREATE TABLE [Notification_Object] (
  ID INTEGER PRIMARY KEY NOT NULL IDENTITY
);
GO

--New request
CREATE TABLE [New_Request] (
  ID             INTEGER PRIMARY KEY NOT NULL IDENTITY,
  accept_status  BIT,
  accept_time    DATETIME,
  specified      BIT                 NOT NULL,
  information    TEXT                NOT NULL,
  viewer_id      INTEGER             NOT NULL REFERENCES [Viewer] (ID) ON DELETE CASCADE,
  notif_obj_id   INTEGER             NOT NULL UNIQUE REFERENCES [Notification_Object] (ID) ON DELETE CASCADE,
  contributer_id INTEGER REFERENCES [Contributor] (ID)
);
GO

--Content
CREATE TABLE [Content] (
  ID               INTEGER PRIMARY KEY NOT NULL IDENTITY,
  uploaded_at      DATETIME            NOT NULL,
  contributer_id   INTEGER             NOT NULL REFERENCES [Contributor] (ID),
  category_type    VARCHAR(255)        NOT NULL,
  subcategory_name VARCHAR(255)        NOT NULL,
  type             VARCHAR(255) REFERENCES [Content_type] (type),
  link             VARCHAR(255),
  CONSTRAINT FK FOREIGN KEY (category_type, subcategory_name) REFERENCES [Sub_Category] (category_type, name)
);
GO

--Original content
CREATE TABLE [Original_Content] (
  ID                 INTEGER PRIMARY KEY NOT NULL REFERENCES [Content] (ID)
    ON DELETE CASCADE,
  content_manager_id INTEGER REFERENCES [Content_Manager] (ID),
  reviewer_id        INTEGER REFERENCES [Reviewer] (ID),
  review_status      BIT,
  filter_status      BIT,
  rating             INTEGER
);
GO

--Existing request
CREATE TABLE [Existing_Request] (
  ID                  INTEGER PRIMARY KEY NOT NULL IDENTITY,
  original_content_id INTEGER             NOT NULL REFERENCES [Original_Content] (ID)
    ON DELETE CASCADE,
  viewer_id           INTEGER             NOT NULL REFERENCES [Viewer] (ID)
    ON DELETE CASCADE
);
GO

--New content
CREATE TABLE [New_Content] (
  ID             INTEGER PRIMARY KEY NOT NULL REFERENCES [Content] (ID)
    ON DELETE CASCADE,
  new_request_id INTEGER             NOT NULL REFERENCES [New_Request] (ID)
    ON DELETE CASCADE
);
GO

--Comment
CREATE TABLE [Comment] (
  viewer_id           INTEGER  NOT NULL REFERENCES [Viewer] (ID)
    ON DELETE CASCADE,
  original_content_id INTEGER  NOT NULL REFERENCES [Original_Content] (ID)
    ON DELETE CASCADE,
  date                DATETIME NOT NULL,
  text                TEXT     NOT NULL,
  CONSTRAINT PK_Comment PRIMARY KEY (viewer_id, original_content_id, date)
);
GO

--Rate
CREATE TABLE [Rate] (
  viewer_id           INTEGER  NOT NULL REFERENCES [Viewer] (ID)
    ON DELETE CASCADE,
  original_content_id INTEGER  NOT NULL REFERENCES [Original_Content] (ID)
    ON DELETE CASCADE,
  date                DATETIME NOT NULL,
  rate                INTEGER,
  CONSTRAINT PK_Rate PRIMARY KEY (viewer_id, original_content_id)
);
GO

--Event
CREATE TABLE [Event] (
  ID                     INTEGER PRIMARY KEY NOT NULL IDENTITY,
  description            TEXT                NOT NULL,
  location               VARCHAR(255)        NOT NULL,
  city                   VARCHAR(255)        NOT NULL,
  time                   DATETIME            NOT NULL,
  entertainer            VARCHAR(255)        NOT NULL,
  notification_object_id INTEGER             NOT NULL UNIQUE REFERENCES [Notification_Object] (ID),
  viewer_id              INTEGER             NOT NULL REFERENCES [Viewer] (ID)
);
GO

--Event photos link
CREATE TABLE [Event_Photos_Link] (
  event_id INTEGER      NOT NULL REFERENCES [Event] (ID),
  link     VARCHAR(255) NOT NULL,
  CONSTRAINT PK_Event_Photos_Link PRIMARY KEY (event_id, link)
);
GO

--Event videos link
CREATE TABLE [Event_Videos_Link] (
  event_id INTEGER      NOT NULL REFERENCES [Event] (ID),
  link     VARCHAR(255) NOT NULL,
  CONSTRAINT PK_Event_Videos_Link PRIMARY KEY (event_id, link)
);
GO

--Advertisement
CREATE TABLE [Advertisement] (
  ID          INTEGER PRIMARY KEY NOT NULL IDENTITY,
  description TEXT,
  location    VARCHAR(255),
  event_id    INTEGER REFERENCES [Event] (ID),
  viewer_id   INTEGER             NOT NULL REFERENCES [Viewer] (ID)
    ON DELETE CASCADE
)
GO

--Ad video link
CREATE TABLE [Ads_Video_Link] (
  advertisement_id INTEGER      NOT NULL REFERENCES [Advertisement] (ID)
    ON DELETE CASCADE,
  link             VARCHAR(255) NOT NULL,
  CONSTRAINT PK_Ads_Video_Link PRIMARY KEY (advertisement_id, link)
);
GO

--Ad photos link
CREATE TABLE [Ads_Photos_Link] (
  advertisement_id INTEGER      NOT NULL REFERENCES [Advertisement] (ID)
    ON DELETE CASCADE,
  link             VARCHAR(255) NOT NULL,
  CONSTRAINT PK_Ads_Photos_Link PRIMARY KEY (advertisement_id, link)
);
GO

--Announcement
CREATE TABLE [Announcement] (
  ID                     INTEGER PRIMARY KEY NOT NULL IDENTITY,
  seen_at                DATETIME,
  sent_at                DATETIME,
  notified_person_id     INTEGER             NOT NULL REFERENCES [Notified_Person] (ID)
    ON DELETE CASCADE,
  notification_object_id INTEGER             NOT NULL REFERENCES [Notification_Object] (ID)
    ON DELETE CASCADE
);
GO


USE IEgypt_78;
GO

CREATE OR ALTER PROC Original_Content_Search @typename VARCHAR(255) = NULL, @categoryname VARCHAR(255) = NULL AS
  BEGIN
    IF @typename IS NULL AND @categoryname IS NOT NULL
    SELECT c.*, oc.rating
    FROM [Original_Content] oc JOIN
         [Content] c ON oc.ID = c.ID
    WHERE (c.category_type LIKE '%' + @categoryname + '%' AND c.ID = oc.ID AND oc.filter_status = 1);
    ELSE IF @typename IS NOT NULL AND @categoryname IS NULL
    SELECT oc.*
    FROM [Original_Content] oc JOIN
         [Content] c ON oc.ID = c.ID
    WHERE (c.type LIKE '%' + @typename + '%' AND c.ID = oc.ID AND oc.filter_status = 1);
    ELSE IF @typename IS NOT NULL AND @categoryname IS NOT NULL
    SELECT oc.*
    FROM [Original_Content] oc JOIN
         [Content] c ON c.ID = oc.ID
    WHERE (c.category_type LIKE '%' + @categoryname + '%' AND
           c.type LIKE '%' + @typename + '%' AND c.ID = oc.ID AND oc.filter_status = 1);
  END
GO

CREATE OR ALTER PROC Contributor_Search(@fullname VARCHAR(255)) AS
  BEGIN
    SELECT [u](ID, first_name, middle_name, last_name, age), [c](years_of_experience, portfolio_link, specilization)
    FROM [User] u JOIN
         [Contributor] c ON u.ID = c.ID
    WHERE (u.ID = c.ID AND (u.first_name + ' ' + u.middle_name +' ' + u.last_name) LIKE '%' + @fullname + '%');
  END
GO

CREATE OR ALTER PROC Register_User @usertype                  VARCHAR(255), @email VARCHAR(255), @password VARCHAR(255),
                                   @firstname                 VARCHAR(255), @middlename VARCHAR(255),
                                   @lastname                  VARCHAR(255), @birth_date DATETIME,
                                   @working_place_name        VARCHAR(255) = NULL,
                                   @working_place_type        VARCHAR(255) = NULL,
                                   @wokring_place_description VARCHAR(255) = NULL,
                                   @specilization             VARCHAR(255) = NULl, @portofolio_link VARCHAR(255) = NULl,
                                   @years_experience          INTEGER = NULl, @hire_date DATETIME = NULl,
                                   @working_hours             INTEGER = NULl, @payment_rate REAL = NULl,
                                   @user_id                   INTEGER OUTPUT
AS
  BEGIN
    IF (@usertype = 'Viewer' OR @usertype = 'Contributor' OR @usertype = 'Authorized Reviewer' OR
        @usertype = 'Content Manager') AND NOT EXISTS(SELECT * FROM [User] WHERE email = @email)
       AND @email IS NOT NULL AND @password IS NOT NULL AND @firstname IS NOT NULL AND @middlename IS NOT NULL AND
                                                                   @lastname IS NOT NULL AND @birth_date IS NOT NULL
      BEGIN
        DECLARE @temp INTEGER;
        --ADD USER
        INSERT INTO [User] (email, first_name, middle_name, last_name, birth_date, password)
        VALUES (@email, @firstname, @middlename, @lastname, @birth_date, @password);
        --GETTING ID
        SELECT @user_id = u.ID FROM [User] u WHERE u.email = @email;
        --Add USER type
        IF @usertype = 'Viewer'
          BEGIN
            INSERT INTO [Viewer] (ID, working_place, working_place_type, working_place_description)
            VALUES (@user_id, @working_place_name, @working_place_type, @wokring_place_description);
          END
        ELSE IF @usertype = 'Contributor'
          BEGIN
            --Creating new notified person entry
            SELECT @temp = max(ID) + 1 FROM [Notified_Person];
            INSERT INTO [Notified_Person] (ID) VALUES (@temp);
            --Creating the contributor entry
            INSERT INTO [Contributor] (ID, years_of_experience, portfolio_link, specialization, notified_id)
            VALUES (@user_id, @years_experience, @portofolio_link, @specilization, @temp);
          END
        ELSE IF @usertype = 'Authorized Reviewer' AND
        @working_hours IS NOT NULL AND @payment_rate IS NOT NULL AND @hire_date IS NOT NULL
          BEGIN
            --Creating new notified person entry
            SELECT @temp = max(ID) + 1 FROM [Notified_Person];

            INSERT INTO [Notified_Person] (ID) VALUES (@temp);

            --Creating a new staff entry
            INSERT INTO [Staff] (ID, hire_date, working_hours, payment_rate, notified_id)
            VALUES (@user_id, @hire_date, @working_hours, @payment_rate, @temp);
            --Creating the reviewer entry
            INSERT INTO [Reviewer] (ID) VALUES (@user_id);
          END
        ELSE IF @usertype = 'Content Manager' AND
        @working_hours IS NOT NULL AND @payment_rate IS NOT NULL AND @hire_date IS NOT NULL
          BEGIN
            --Creating new notified person entry
            SELECT @temp = max(ID) + 1 FROM [Notified_Person];

            INSERT INTO [Notified_Person] (ID) VALUES (@temp);

            --Creating a new staff entry
            INSERT INTO [Staff] (ID, hire_date, working_hours, payment_rate, notified_id)
            VALUES (@user_id, @hire_date, @working_hours, @payment_rate, @temp);
            --Creating the Content Manager entry
            INSERT INTO [Content_Manager] (ID) VALUES (@user_id);
          END
      END
  END;
GO

CREATE OR ALTER PROC Check_Type @typename VARCHAR(255), @user_id INTEGER
AS
  BEGIN
    IF EXISTS(SELECT * FROM [Content_Manager] WHERE ID = @user_id AND type IS NULL) AND
    EXISTS (SELECT * FROM [Content_Type] WHERE type = @typename)
      BEGIN
        UPDATE [Content_Manager] SET type = @typename WHERE ID = @user_id;
      END
  END;
GO

CREATE OR ALTER PROC Order_Contributor
AS
  BEGIN
    SELECT ID, years_of_experience
    FROM [Contributor]
    ORDER BY years_of_experience DESC;
  END
GO

CREATE OR ALTER PROC Show_Original_Content @contributor_id INTEGER = NULL
AS
  BEGIN
    IF @contributor_id IS NULL
      BEGIN
        SELECT cr.ID,
               u.first_name,
               u.middle_name,
               u.last_name,
               u.email,
               u.birth_date,
               u.age,
               cr.years_of_experience,
               cr.portfolio_link,
               cr.specialization,
               ct.ID,
               ct.category_type,
               ct.subcategory_name,
               ct.uploaded_at,
               oc.rating
        FROM [User] u
               JOIN [Contributor] cr ON u.ID = cr.ID
               JOIN [Content] ct ON ct.contributer_id = cr.ID
               JOIN [Original_Content] oc ON oc.ID = ct.ID
        WHERE oc.filter_status = 1;
      END
    ELSE IF EXISTS (SELECT * FROM [Contributor] WHERE ID=@contributor_id)
      BEGIN
        SELECT cr.ID,
               u.first_name,
               u.middle_name,
               u.last_name,
               u.email,
               u.birth_date,
               u.age,
               cr.years_of_experience,
               cr.portfolio_link,
               cr.specialization,
               ct.ID,
               ct.category_type,
               ct.subcategory_name,
               ct.uploaded_at,
               oc.rating
        FROM [User] u
               JOIN [Contributor] cr ON u.ID = cr.ID
               JOIN [Content] ct ON ct.contributer_id = cr.ID
               JOIN [Original_Content] oc ON oc.ID = ct.ID
        WHERE @contributor_id = cr.ID AND oc.filter_status = 1;
      END
  END
GO

CREATE OR ALTER PROC User_login @email VARCHAR(255), @password VARCHAR(255), @user_id INTEGER OUT
AS
  BEGIN
    --Check if the user exists
    SET @user_id = -1;
    SELECT @user_id=ID FROM [User] WHERE email=@email AND password=@password
    IF NOT @user_id = -1
    BEGIN
      IF EXISTS (SELECT * FROM [User] WHERE ID=@user_id AND (active = 1 OR (active = 0 AND datediff(WEEK, CURRENT_TIMESTAMP, last_login) <= 2)))
        UPDATE [User] SET last_login = CURRENT_TIMESTAMP, active=1 WHERE ID = @user_id;
      ELSE
        SET @user_id = -1;
    END
  END
GO

CREATE OR ALTER PROC Show_Profile @user_id                   INTEGER,
                         @email                     VARCHAR(255) OUTPUT,
                         @password                  VARCHAR(255) OUTPUT,
                         @firstname                 VARCHAR(255) OUTPUT, @middlename VARCHAR(255) OUTPUT,
                         @lastname                  VARCHAR(255) OUTPUT, @birth_date DATETIME OUTPUT,
                         @working_place_name        VARCHAR(255) = NULL OUTPUT,
                         @working_place_type        VARCHAR(255) = NULL OUTPUT,
                         @wokring_place_description TEXT = NULL OUTPUT,
                         @specilization             VARCHAR(255) = NULL OUTPUT,
                         @portofolio_link           VARCHAR(255) = NULL OUTPUT,
                         @years_experience          INTEGER = NULL OUTPUT,
                         @hire_date                 DATETIME = NULL OUTPUT,
                         @working_hours             INTEGER = NULL OUTPUT,
                         @payment_rate              REAL = NULL OUTPUT
AS
  BEGIN
    --Check if the account is deleted
    SET @email = NULL;
    SET @password = NULL;
    SET @firstname = NULL;
    SET @middlename = NULL;
    SET @lastname = NULL;
    SET @birth_date = NULL;
    SET @working_place_name = NULL; --Viewer
    SET @working_place_type = NULL; --Viewer
    SET @wokring_place_description = NULL; --Viewer
    SET @specilization = NULL; --Cont
    SET @portofolio_link = NULL; --Cont
    SET @years_experience = NULL; --Cont
    SET @hire_date = NULL; --staff
    SET @working_hours = NULL; --staff
    SET @payment_rate = NULL; --staff
    IF EXISTS(SELECT * FROM [User] WHERE [User].ID = @user_id) --This query might be different
    --Check if the account is active
      BEGIN
        -- Values from users table
        SELECT @email = email,
               @password = password,
               @firstname = first_name,
               @middlename = middle_name,
               @lastname = last_name,
               @birth_date = birth_date
        FROM [User]
        WHERE ID = @user_id;
        -- Values from other tables
        IF EXISTS(SELECT ID FROM [Viewer] WHERE @user_id = ID) --User is a viewer
          SELECT @working_place_name = working_place,
                 @working_place_type = working_place_type,
                 @wokring_place_description = working_place_description
          FROM [Viewer]
          WHERE ID = @user_id;
        ELSE IF EXISTS(SELECT ID FROM [Contributor] WHERE @user_id = ID) --User is a Contributor
          SELECT @specilization = specialization,
                 @portofolio_link = portfolio_link,
                 @years_experience = years_of_experience
          FROM [Contributor]
          WHERE ID = @user_id;
        ELSE IF EXISTS(SELECT ID FROM [Staff] WHERE @user_id = ID) --User is a Staff member
          SELECT @hire_date = hire_date, @working_hours = working_hours, @payment_rate = payment_rate
          FROM [Staff]
          WHERE @user_id = ID;
      END
  END
GO

CREATE OR ALTER PROC Deactivate_Profile @user_id INTEGER
AS
  BEGIN
    UPDATE [User] SET active = 0 WHERE ID = @user_id;
  END
GO

CREATE OR ALTER PROC Edit_Profile @user_id                   VARCHAR(255), @email VARCHAR(255) = NULL,
                         @password                  VARCHAR(255) = NULL, @firstname VARCHAR(255) = NULL,
                         @middlename                VARCHAR(255) = NULL, @lastname VARCHAR(255) = NULL,
                         @birth_date                DATETIME = NULL,
                         @working_place_name        VARCHAR(255) = NULL, @working_place_type VARCHAR(255) = NULL,
                         @working_place_description TEXT = NULL, @specilization VARCHAR(255) = NULL,
                         @portfolio_link            VARCHAR(255) = NULL, @years_experience INTEGER = NULL,
                         @hire_date                 DATETIME = NULL, @working_hours INTEGER = NULL,
                         @payment_rate              REAL = NULL
AS
  BEGIN
    IF EXISTS(SELECT ID FROM [User] WHERE ID = @user_id) --This query might be different
      BEGIN
        -- Values from users table
        IF @password IS NOT NULL --Edit password
          UPDATE [User] SET password = @password WHERE ID = @user_id;
        IF @email IS NOT NULL --Edit email
          UPDATE [User] SET email = @email WHERE ID = @user_id;
        IF @firstname IS NOT NULL --Edit firstname
          UPDATE [User] SET first_name = @firstname WHERE ID = @user_id;
        IF @middlename IS NOT NULL --Edit middlename
          UPDATE [User] SET middle_name = @middlename WHERE ID = @user_id;
        IF @lastname IS NOT NULL --Edit lastname
          UPDATE [User] SET last_name = @lastname WHERE ID = @user_id;
        IF @birth_date IS NOT NULL --Edit birthdate
          UPDATE [User] SET birth_date = @birth_date WHERE ID = @user_id;
        -- Values from other tables
        IF EXISTS(SELECT ID FROM [Viewer] WHERE @user_id = ID) --User is a viewer
          BEGIN
            IF @working_place_name IS NOT NULL --Edit working place name
              UPDATE [Viewer] SET working_place = @working_place_name WHERE ID = @user_id;
            IF @working_place_type IS NOT NULL --Edit working place type
              UPDATE [Viewer] SET working_place_type = @working_place_type WHERE ID = @user_id;
            IF @working_place_description IS NOT NULL --Edit working place description
              UPDATE [Viewer] SET working_place_description = @working_place_description WHERE ID = @user_id;
          END
        ELSE IF EXISTS(SELECT ID FROM [Contributor] WHERE @user_id = ID) --User is a Contributor
          BEGIN
            IF @years_experience IS NOT NULL --Edit years of experience
              UPDATE [Contributor] SET years_of_experience = @years_experience WHERE ID = @user_id;
            IF @portfolio_link IS NOT NULL --Edit portfolio link
              UPDATE [Contributor] SET portfolio_link = @portfolio_link WHERE ID = @user_id;
            IF @specilization IS NOT NULL --Edit specialization
              UPDATE [Contributor] SET specialization = @specilization WHERE ID = @user_id;
          END
        ELSE IF EXISTS(SELECT ID FROM [Staff] WHERE @user_id = ID) --User is a Staff member
          BEGIN
            IF @hire_date IS NOT NULL --Edit hire date
              UPDATE [Staff] SET hire_date = @hire_date WHERE ID = @user_id;
            IF @working_hours IS NOT NULL --Edit working hours
              UPDATE [Staff] SET working_hours = @working_hours WHERE ID = @user_id;
            IF @payment_rate IS NOT NULL --Edit payment rate
              UPDATE [Staff] SET payment_rate = @payment_rate WHERE ID = @user_id;
          END
      END
  END
GO

CREATE OR ALTER PROC Show_Event @event_id INTEGER = NULL
AS
  BEGIN
    IF @event_id IS NOT NULL
      BEGIN
        SELECT u.first_name,
               u.middle_name,
               u.last_name,
               e.ID,
               e.description,
               e.location,
               e.city,
               e.time,
               e.entertainer,
               e.notification_object_id

        FROM [Event] e
               JOIN [User] u ON e.viewer_id = u.ID
        WHERE e.ID = @event_id
          AND e.time > CURRENT_TIMESTAMP;
      END
    ELSE
      BEGIN
        SELECT u.first_name,
               u.middle_name,
               u.last_name,
               e.ID,
               e.description,
               e.location,
               e.city,
               e.time,
               e.entertainer,
               e.notification_object_id
        FROM [Event] e
               JOIN [User] u ON e.viewer_id = u.ID
        WHERE e.time > CURRENT_TIMESTAMP
      END
  END
GO

CREATE OR ALTER PROC Show_Notification @user_id INTEGER
AS
  BEGIN
    DECLARE @notified_person_id INTEGER = NULL;
    IF EXISTS(SELECT ID FROM [Contributor] WHERE ID = @user_id) --User is a contributor
      BEGIN
        --Getting the notified person id
        SELECT @notified_person_id = notified_id from [Contributor] WHERE ID = @user_id;
        --Getting new requests
        SELECT r.ID, r.accept_status, r.specified, r.information
        FROM (SELECT notification_object_id FROM [Announcement] WHERE notified_person_id = @notified_person_id) a
               INNER JOIN [New_Request] r ON a.notification_object_id = r.notif_obj_id;
        --Getting events
        SELECT u.first_name,
               u.middle_name,
               u.last_name,
               e.ID,
               e.description,
               e.location,
               e.city,
               e.time,
               e.entertainer,
               e.notification_object_id
        FROM (SELECT notification_object_id FROM [Announcement] WHERE notified_person_id = @notified_person_id) a
               JOIN [Event] e ON a.notification_object_id = e.notification_object_id
               JOIN [User] u ON e.viewer_id = u.ID;
      END
    ELSE IF EXISTS(SELECT ID FROM [Staff] WHERE ID = @user_id) --User is a staff member
      BEGIN
        --Getting the notified person id
        SELECT @notified_person_id = notified_id from [Staff] WHERE ID = @user_id;
        --Getting events
        SELECT u.first_name,
               u.middle_name,
               u.last_name,
               e.ID,
               e.description,
               e.location,
               e.city,
               e.time,
               e.entertainer,
               e.notification_object_id
        FROM (SELECT notification_object_id FROM [Announcement] WHERE notified_person_id = @notified_person_id) a
               JOIN [Event] e ON a.notification_object_id = e.notification_object_id
               JOIN [User] u ON e.viewer_id = u.ID;
      END
  END
GO

CREATE OR ALTER PROC Show_New_Content @viewer_id INTEGER, @content_id INTEGER = NULL
AS
  BEGIN
    IF @content_id IS NULL
      BEGIN
        SELECT u.ID,
               u.first_name,
               u.middle_name,
               u.last_name,
               ct.ID,
               ct.uploaded_at,
               ct.contributer_id,
               ct.category_type,
               ct.subcategory_name,
               ct.type
        FROM (SELECT ID, first_name, middle_name, last_name FROM [User] WHERE ID = @viewer_id) u
               JOIN (SELECT ID, viewer_id FROM [New_Request]) r ON r.viewer_id = u.ID
               JOIN [New_Content] nc ON nc.new_request_id = r.ID
               JOIN [Content] ct ON nc.ID = ct.ID;
      END
    ELSE
      BEGIN
        SELECT u.ID,
               u.first_name,
               u.middle_name,
               u.last_name,
               ct.ID,
               ct.uploaded_at,
               ct.contributer_id,
               ct.category_type,
               ct.subcategory_name,
               ct.type
        FROM (SELECT ID, first_name, middle_name, last_name FROM [User] WHERE ID = @viewer_id) u
               JOIN (SELECT ID, viewer_id FROM [New_Request]) r ON r.viewer_id = u.ID
               JOIN (SELECT * FROM [New_Content] WHERE ID = @content_id) nc ON nc.new_request_id = r.ID
               JOIN [Content] ct ON nc.ID = ct.ID;
      END
  END
GO

CREATE OR ALTER PROC Receive_New_Requests @request_id INTEGER, @contributor_id INTEGER
AS
  BEGIN
    IF @request_id IS NULL
      SELECT * FROM
      [New_Request]
      WHERE accept_Status IS NULL AND ((specified = 1 AND contributer_id = @contributor_id) OR (specified = 0));
    ELSE
    SELECT * FROM
    [New_Request]
    WHERE ID = @request_id AND accept_Status IS NULL AND ((specified = 1 AND contributer_id = @contributor_id) OR (specified = 0));
  END
GO

CREATE OR ALTER PROC Receive_New_Request @contributor_id INTEGER, @can_receive INTEGER OUT
AS
  BEGIN
    SELECT @can_receive = COUNT(*)
    FROM [New_Request] r
    WHERE r.contributer_id = @contributor_id
      AND r.accept_status = 1
      AND NOT EXISTS(
                SELECT * FROM [Content] c
                                JOIN [New_Content] nc on c.ID = nc.ID AND nc.new_request_id = r.ID
        );
    IF @can_receive < 3
      SET @can_receive = 1;
    ELSE
      SET @can_receive = 0;
  END
GO

CREATE OR ALTER PROC Respond_New_Request @contributor_id INTEGER, @accept_status BIT, @request_id INTEGER
AS
  BEGIN
    IF EXISTS (SELECT * FROM [Contributor] WHERE ID = @contributor_id)
    BEGIN
    DECLARE @current_open INTEGER;
    SELECT @current_open = current_requests FROM [Contributor] WHERE ID = @contributor_id;
    IF EXISTS (SELECT * FROM [New_Request] WHERE ID = @request_id AND accept_status=NULL)
    BEGIN
      IF EXISTS (SELECT * FROM [New_Request] WHERE ID = @request_id AND specified = 1 AND contributer_id = @contributor_id)
      AND @accept_status = 0 OR (@accept_status = 1 AND @current_open < 3)
      BEGIN
        UPDATE [New_Request] SET accept_status = @accept_status, contributer_id = @contributor_id WHERE ID = @request_id;
        IF @accept_status = 1
        BEGIN
          UPDATE [New_Request] SET accept_time = CURRENT_TIMESTAMP;
          UPDATE [Contributor] SET current_requests = current_requests + 1 WHERE ID = @contributor_id;
        END
      END
      ELSE IF EXISTS (SELECT * FROM [New_Request] WHERE ID = @request_id AND specified = 0)
      AND (@accept_status = 1 AND @current_open < 3)
      BEGIN
        UPDATE [New_Request] SET accept_status = @accept_status, contributer_id = @contributor_id, accept_time = CURRENT_TIMESTAMP WHERE ID = @request_id;
        UPDATE [Contributor] SET current_requests = current_requests + 1 WHERE ID = @contributor_id;
      END
      END
    END
  END
GO

CREATE OR ALTER PROC Upload_Original_Content @type_id        VARCHAR(255), @subcategory_name VARCHAR(255),
                                    @category_id    VARCHAR(255),
                                    @contributor_id INTEGER, @link VARCHAR(255)
AS
  BEGIN
    -- Create new entry for content
    IF EXISTS (SELECT * FROM [Sub_Category] WHERE category_type = @category_id AND name = @subcategory_name) AND
      EXISTS (SELECT * FROM [Content_type] WHERE type = @type_id) AND
      EXISTS (SELECT * FROM [Contributor] WHERE ID = @contributor_id)
    BEGIN
      INSERT INTO [Content] (uploaded_at, contributer_id, category_type, subcategory_name, type, link)
      VALUES (CURRENT_TIMESTAMP, @contributor_id, @category_id, @subcategory_name, @type_id, @link);
      -- Get the id of the new content
      DECLARE @content_id INTEGER = (SELECT max(ID) FROM [Content])
      -- Create new entry for original content
      INSERT INTO [Original_Content] (ID) VALUES (@content_id);
    END
  END
GO

CREATE OR ALTER PROC Update_average_update_time @contributor_id INTEGER
AS
  BEGIN
    DECLARE @AVERAGE INTEGER;
    SELECT @AVERAGE = AVG(DATEDIFF(hh, [Content].uploaded_at, [New_Request].accept_time))
    FROM [New_Request]
           JOIN [New_Content] ON New_Request.ID = [New_Content].new_request_id
           JOIN [Content] ON [New_Content].ID = [Content].ID
    WHERE [New_Request].contributer_id = @contributor_id
      AND [Content].contributer_id = @contributor_id;
    UPDATE [Contributor] SET average_upload_time = @AVERAGE WHERE ID = @contributor_id;
  END
GO

CREATE OR ALTER PROC Upload_New_Content @new_request_id   INTEGER, @contributor_id INTEGER,
                               @subcategory_name VARCHAR(255), @category_id VARCHAR(255), @link VARCHAR(255)
AS
  BEGIN
    IF EXISTS (SELECT * FROM [Contributor] WHERE ID = @contributor_id) AND
      EXISTS (SELECT * FROM [New_Request] WHERE ID = @new_request_id AND contributer_id = @contributor_id AND accept_status = 1) AND
      EXISTS (SELECT * FROM [Sub_Category] WHERE category_type = @category_id AND name = @subcategory_name)
    BEGIN
      -- Create entry in content
      INSERT INTO [Content] (uploaded_at, contributer_id, category_type, subcategory_name, link)
      VALUES (CURRENT_TIMESTAMP, @contributor_id, @category_id, @subcategory_name, @link);
      -- Get the id of the new content
      DECLARE @content_id INTEGER = (SELECT max(ID) FROM [Content])
      -- Create entry in new content
      INSERT INTO [New_Content] (ID, new_request_id) VALUES (@content_id, @new_request_id);
      -- Update the average time taken for the contributor to upload new content
      EXEC Update_average_update_time @contributor_id
      UPDATE [Contributor] SET current_requests = current_requests - 1;
    END
  END
GO

CREATE OR ALTER PROC reviewer_filter_content @reviewer_id INTEGER, @original_content INTEGER, @status BIT
AS
  BEGIN
    IF EXISTS (SELECT * FROM [Original_Content] WHERE ID = @original_content AND review_status IS NULL)
      UPDATE [Original_Content]
      SET reviewer_id   = @reviewer_id,
          review_status = @status
          WHERE ID = @original_content;
  END
GO

CREATE OR ALTER PROC content_manager_filter_content @content_manager_id INTEGER, @original_content INTEGER, @status BIT
AS
  BEGIN
    IF EXISTS(SELECT * FROM [Original_Content] WHERE ID = @original_content AND review_status = 1 AND filter_status IS NULL) AND
      EXISTS (SELECT * FROM [Content_Manager] CM JOIN [Content_type] CT ON CM.type = CT.type JOIN [Content] C ON C.type = CT.type WHERE CM.ID = @content_manager_id)
      UPDATE [Original_Content]
      SET content_manager_id = @content_manager_id,
        filter_status = @status
      WHERE ID = @original_content;
  END
GO

CREATE OR ALTER PROC Staff_Create_Category @category_name VARCHAR(255)
AS
  BEGIN
    IF NOT EXISTS (SELECT * FROM [Category] WHERE type = @category_name)
      INSERT INTO [Category] (type) VALUES (@category_name);
  END
GO

CREATE OR ALTER PROC Staff_Create_Subcategory @category_name VARCHAR(255), @subcategory_name VARCHAR(255)
AS
  BEGIN
    IF EXISTS (SELECT * FROM [Category] WHERE type = @category_name) AND
        NOT EXISTS (SELECT * FROM [Sub_Category] WHERE name = @subcategory_name)
      INSERT INTO [Sub_Category] (category_type, name) VALUES (@category_name, @subcategory_name);
  END
GO

CREATE OR ALTER PROC Staff_Create_Type @type_name VARCHAR(255)
AS
  BEGIN
    IF NOT EXISTS (SELECT * FROM [Content_type] WHERE type = @type_name)
      INSERT INTO [Content_type] (type) VALUES (@type_name);
  END
GO

CREATE OR ALTER PROC Most_Requested_Content
AS
  BEGIN
    SELECT c.ID, COUNT(r.ID) AS Requests
    FROM [Original_Content] c
           Join [Existing_Request] r ON r.original_content_id = c.ID
    GROUP BY c.ID
    ORDER BY Requests DESC
  END
GO

CREATE OR ALTER PROC Viewer_Create_Event @city        VARCHAR(255), @event_date_time DATETIME, @description TEXT,
                                @entertainer VARCHAR(255), @viewer_id INTEGER, @location VARCHAR(255),
                                @event_id    INTEGER OUT
AS
  BEGIN
  IF @city IS NOT NULL AND @event_date_time IS NOT NULL AND @description IS NOT NULL AND
    @entertainer IS NOT NULL AND @location IS NOT NULL AND
    EXISTS (SELECT * FROM [Viewer] WHERE ID = @viewer_id)
  BEGIN
    -- Create a new notification object entry
    DECLARE @obj_id INTEGER;
    SELECT @obj_id = MAX(ID) + 1 FROM [Notification_Object];
    SET IDENTITY_INSERT [Notification_Object] ON;
    INSERT INTO [Notification_Object] (ID) VALUES (@obj_id);
    SET IDENTITY_INSERT [Notification_Object] OFF;
    -- Create new event
    INSERT INTO [Event] (description, location, city, time, entertainer, notification_object_id, viewer_id)
    VALUES (@description, @location, @city, @event_date_time, @entertainer, @obj_id, @viewer_id);
    -- Getting the event ID
    SELECT @event_id = MAX(ID) FROM [Event];
    --Create announcements
    DECLARE notified_cursor CURSOR FOR (SELECT ID FROM [Notified_Person]);
    OPEN notified_cursor;
    DECLARE @notified_person_id INTEGER = NULL;
    FETCH NEXT FROM notified_cursor
    INTO @notified_person_id;
    IF @notified_person_id IS NOT NULL
      INSERT INTO [Announcement] (sent_at, notified_person_id, notification_object_id)
      VALUES (CURRENT_TIMESTAMP, @notified_person_id, @obj_id);
    WHILE @@FETCH_STATUS = 0
      BEGIN
        FETCH NEXT FROM notified_cursor
        INTO @notified_person_id;
        IF @notified_person_id IS NOT NULL
          INSERT INTO [Announcement] (sent_at, notified_person_id, notification_object_id)
          VALUES (CURRENT_TIMESTAMP, @notified_person_id, @obj_id);
      END
    CLOSE notified_cursor;
    DEALLOCATE notified_cursor;
  END
  END
GO

CREATE OR ALTER PROC Apply_Existing_Request @viewer_id INTEGER, @original_content_id INTEGER
AS
  BEGIN
    IF EXISTS(SELECT * FROM [Original_Content] WHERE ID = @original_content_id
                                                 AND rating >= 4) AND
       EXISTS (SELECT * FROM [Viewer] WHERE ID = @viewer_id)
      BEGIN
        -- Creating existing request
        INSERT INTO [Existing_Request] (original_content_id, viewer_id) VALUES (@original_content_id, @viewer_id);
      END
  END
GO

CREATE OR ALTER PROC Viewer_Create_Ad_From_Event @event_id INTEGER
AS
  BEGIN
    IF EXISTS (SELECT * FROM [Event] WHERE ID = @event_id)
    BEGIN
      DECLARE @viewer_id INTEGER;
      SELECT @viewer_id = viewer_id FROM [Event] WHERE ID = @event_id;
      INSERT INTO [Advertisement] (event_id, viewer_id) VALUES (@event_id, @viewer_id);
    END
  END
GO

CREATE OR ALTER PROC Apply_New_Request @information TEXT, @contributor_id INTEGER, @viewer_id INTEGER
AS
  BEGIN
    IF @information IS NOT NULL AND EXISTS (SELECT * FROM [Viewer] WHERE ID = @viewer_id)
    BEGIN
    DECLARE @obj_id INTEGER;
    IF @contributor_id IS NULL
      BEGIN
        --Create new notification object
        SELECT @obj_id = MAX(ID) + 1 FROM [Notification_Object];
        SET IDENTITY_INSERT [Notification_Object] ON;
        INSERT INTO [Notification_Object] (ID) VALUES (@obj_id);
        SET IDENTITY_INSERT [Notification_Object] OFF;
        INSERT INTO [New_Request] (specified, information, viewer_id, notif_obj_id)
        VALUES (0, @information, @viewer_id, @obj_id);
        -- Creating announcements
        DECLARE notified_cursor CURSOR FOR (SELECT P.ID FROM [Notified_person] P
                                                               JOIN [Contributor] C2 on P.ID = C2.notified_id);
        OPEN notified_cursor;
        DECLARE @notified_person_id INTEGER = NULL;
        FETCH NEXT FROM notified_cursor
        INTO @notified_person_id;
        IF @notified_person_id IS NOT NULL
          INSERT INTO [Announcement] (sent_at, notified_person_id, notification_object_id)
          VALUES (CURRENT_TIMESTAMP, @notified_person_id, @obj_id);
        WHILE @@FETCH_STATUS = 0
          BEGIN
            FETCH NEXT FROM notified_cursor
            INTO @notified_person_id;
            IF @notified_person_id IS NOT NULL
              INSERT INTO [Announcement] (sent_at, notified_person_id, notification_object_id)
              VALUES (CURRENT_TIMESTAMP, @notified_person_id, @obj_id);
          END
        CLOSE notified_cursor;
        DEALLOCATE notified_cursor;
      END
    ELSE IF EXISTS (SELECT * FROM [Contributor] WHERE ID = @contributor_id)
      --Check if the user is eligible for the request
      IF NOT EXISTS(SELECT *
                    FROM [New_Request]
                    WHERE viewer_id = @viewer_id
                      AND specified = 1
                      AND contributer_id = @contributor_id
                      AND accept_status = 0)
        BEGIN
          --Create new notification object
          SELECT @obj_id = MAX(ID) + 1 FROM [Notification_Object];
          SET IDENTITY_INSERT [Notification_Object] ON;
          INSERT INTO [Notification_Object] (ID) VALUES (@obj_id);
          SET IDENTITY_INSERT [Notification_Object] OFF;
          INSERT INTO [New_Request] (specified, information, viewer_id, notif_obj_id, contributer_id)
          VALUES (1, @information, @viewer_id, @obj_id, @contributor_id);
          --Create notification
          INSERT INTO [Announcement] (notification_object_id, notified_person_id) VALUES (@obj_id, @contributor_id);
        END
    END
  END
GO

CREATE OR ALTER PROC Delete_New_Request @request_id INTEGER
AS
  BEGIN
    IF EXISTS(SELECT * FROM [New_Request] nr WHERE nr.ID = @request_id
                                            AND accept_status IS NULL)
      BEGIN
        DELETE FROM [Notification_Object] WHERE [Notification_Object].ID = (SELECT notif_obj_id FROM [New_Request] WHERE ID = @request_id);
      END
  END
GO

CREATE OR ALTER PROC Rating_Original_Content @original_content_id INTEGER, @rating_value INTEGER, @viewer_id INTEGER
AS
  BEGIN
    IF EXISTS (SELECT * FROM [Original_Content] WHERE ID = @original_content_id AND rating > 3) AND
        EXISTS (SELECT * FROM [Viewer] WHERE ID = @viewer_id)
    BEGIN
      INSERT INTO [Rate] (viewer_id, original_content_id, date, rate)
      VALUES (@viewer_id, @original_content_id, CURRENT_TIMESTAMP, @rating_value)
      --update the rating on the content
      UPDATE [Original_Content]
      SET rating = (SELECT AVG(rate) FROM [Rate] WHERE original_content_id = @original_content_id)
      WHERE ID = @original_content_id;
    END
  END
GO

CREATE OR ALTER PROC Write_Comment @comment_text TEXT, @viewer_id INTEGER, @original_content_id INTEGER, @written_time DATETIME
AS
  BEGIN
    IF EXISTS(SELECT * FROM [Viewer] WHERE ID = @viewer_id) AND EXISTS (SELECT * FROM [Original_Content] WHERE ID = @original_content_id) AND @written_time IS NOT NULL
      INSERT INTO [Comment] (viewer_id, original_content_id, date, text)
      VALUES (@viewer_id, @original_content_id, @written_time, @comment_text);
  END
GO

CREATE OR ALTER PROC Delete_Comment @viewer_id INTEGER, @original_content_id INTEGER, @written_time DATETIME
AS
  BEGIN
    DELETE FROM [Comment]
    WHERE viewer_id = @viewer_id
      AND original_content_id = @original_content_id
      AND date = @written_time;
  END
GO

CREATE OR ALTER PROC Delete_Original_Content @content_id INTEGER
AS
  BEGIN
    IF EXISTS(SELECT * FROM [Original_Content] WHERE ID=@content_id AND (reviewer_id IS NULL OR filter_status IS NOT NULL))
      DELETE FROM [Content] WHERE ID = @content_id;
  END
GO

CREATE OR ALTER PROC Assign_Contributor_Request @contributor_id INTEGER, @new_request_id INTEGER
AS
  BEGIN
    EXEC Respond_New_Request @contributor_id, 1, @new_request_id;
  END
GO

CREATE OR ALTER PROC Delete_New_Content @content_id INTEGER
AS
  BEGIN
    DELETE FROM [New_Request] WHERE ID = (SELECT new_request_id FROM [New_Content] WHERE ID = @content_id);
    DELETE FROM [Content] WHERE ID = @content_id;
  END
GO

CREATE OR ALTER PROC Delete_Content @content_id INTEGER
AS
  BEGIN
    DELETE FROM [Content] WHERE ID = @content_id;
  END
GO

CREATE OR ALTER PROC Edit_Comment @comment_text      TEXT, @viewer_id INTEGER, @original_content_id INTEGER,
                         @last_written_time DATETIME, @updated_written_time DATETIME
AS
  BEGIN
  IF EXISTS (SELECT * FROM [Comment] WHERE viewer_id = @viewer_id AND original_content_id = @original_content_id AND
    date = @last_written_time) AND @comment_text IS NOT NULL AND @updated_written_time IS NOT NULL
  BEGIN
    UPDATE [Comment]
    SET text = @comment_text,
        date = @updated_written_time
    WHERE viewer_id = @viewer_id
      AND original_content_id = @original_content_id
      AND date = @last_written_time;
  END
  END
GO

CREATE OR ALTER PROC Edit_Ad @ad_id INTEGER, @description TEXT, @location VARCHAR(255)
AS
  BEGIN
    IF @description IS NOT NULL
      UPDATE [Advertisement] SET description = @description WHERE ID = @ad_id;
    IF @location IS NOT NULL
      UPDATE [Advertisement] SET location = @location WHERE ID = @ad_id;

  END
GO

CREATE OR ALTER PROC Create_Ads @viewer_id INTEGER, @description TEXT, @location VARCHAR(255)
AS
  BEGIN
    INSERT INTO [Advertisement] (description, location, viewer_id) VALUES (@description, @location, @viewer_id);
  END
GO

CREATE OR ALTER PROC Delete_Ads @ad_id INTEGER
AS
  BEGIN
    DELETE FROM [Advertisement] WHERE ID = @ad_id;
  END
GO

CREATE OR ALTER PROC Send_Message @msg_text TEXT, @viewer_id INTEGER, @contributor_id INTEGER, @sender_type BIT,
                         @sent_at  DATETIME
AS
  BEGIN
    IF EXISTS (
      SELECT * FROM [Viewer] v JOIN [New_Request] r ON v.ID=r.ID JOIN [Contributor] c ON r.contributer_id=c.ID
    ) AND
    @msg_text IS NOT NULL and @sender_type IS NOT NULL AND @sent_at IS NOT NULL
    INSERT INTO [Message] (sent_at, contributer_id, viewer_id, sender_type, text, read_status)
    VALUES (@sent_at, @contributor_id, @viewer_id, @sender_type, @msg_text, DEFAULT);
  END
GO

CREATE OR ALTER PROC Show_Message @contributor_id INTEGER
AS
  BEGIN
    SELECT * FROM [Message] WHERE contributer_id = @contributor_id;
    UPDATE [Message] SET read_status = 1 WHERE contributer_id=@contributor_id
  END
GO

CREATE OR ALTER PROC Highest_Rating_Original_Content
AS
  BEGIN
    SELECT * FROM [Content]c
                    JOIN [Original_Content] oc ON c.ID = oc.ID ORDER BY oc.rating DESC;
  END
GO

CREATE OR ALTER PROC Assign_New_Request @request_id INTEGER, @contributor_id INTEGER
AS
  BEGIN
    IF EXISTS(SELECT * FROM [New_Request] WHERE ID = @request_id
                                            AND accept_status IS NULL)
      UPDATE [New_Request]
      SET specified      = 1,
          contributer_id = @contributor_id
      WHERE ID = @request_id;
  END
GO

CREATE OR ALTER PROC Workingplace_Category_Relation
AS
  BEGIN
    SELECT working_place_type,
           category_type,
           COUNT(*) AS requests
    FROM (SELECT *
          FROM (SELECT V1.ID                 AS VID,
                       V1.working_place_type AS working_place_type,
                       C.category_type       AS category_type,
                       C.ID                  AS CID
                FROM ([Viewer] V1
                    LEFT JOIN [Existing_Request] R ON V1.ID = R.viewer_id
                    LEFT JOIN [Content] C ON R.original_content_id = C.ID)) T1
          UNION
          (SELECT V2.ID                 AS VID,
                  V2.working_place_type AS working_place_type,
                  C3.category_type      AS category_type,
                  C3.ID                 AS CID
           FROM ([Viewer] V2
               LEFT JOIN [New_Request] N2 ON V2.ID = N2.viewer_id
               LEFT JOIN [New_Content] C2 ON N2.ID = C2.new_request_id
               LEFT JOIN [Content] C3 ON C2.ID = C3.ID))) T2
    GROUP BY working_place_type, category_type
  END
GO

CREATE OR ALTER PROC Show_Possible_Contributors
AS
  BEGIN
    SELECT C.ID, C.average_upload_time, COUNT(*) AS "number of new requests"
    FROM [Contributor] C
          LEFT JOIN [New_Request] R ON C.ID = R.contributer_id
           LEFT JOIN [New_Content] C2 ON C2.new_request_id = R.ID
    GROUP BY C.ID, C.average_upload_time, C.current_requests
    HAVING C.current_requests < 3
    ORDER BY C.average_upload_time ASC, "number of new requests" DESC
  END
GO


--Use the database created from before
USE IEgypt_78;
GO

--Insert categories >= 3
INSERT INTO [Category] (type) VALUES
  ('Pictures'),
  ('Music'),
  ('Video Games');

--Insert subcategories >= 2
INSERT INTO [Sub_Category] (category_type, name) VALUES
  ('Music', 'Blues'),
  ('Music', 'Swing'),
  ('Video Games', 'RPG'),
  ('Video Games', 'Indie'),
  ('Pictures', 'Abstract'),
  ('Pictures', 'Nature');

--Insert Users >= 13
INSERT INTO [User] (email, first_name, last_name, birth_date, password) VALUES
  ('viewer1@mail', 'Viewer1', 'lastname', '1/1/1990', 'passwd'), --1
  ('viewer2@mail', 'Viewer2', 'lastname', '1/1/1990', 'passwd'), --2
  ('viewer3@mail', 'Viewer3', 'lastname', '1/1/1990', 'passwd'), --3

  ('cont1@mail', 'cont1', 'lastname', '1/1/1990', 'passwd'), --4
  ('cont2@mail', 'cont2', 'lastname', '1/1/1990', 'passwd'), --5
  ('cont3@mail', 'cont3', 'lastname', '1/1/1990', 'passwd'), --6
  ('cont4@mail', 'cont4', 'lastname', '1/1/1990', 'passwd'), --7
  ('cont5@mail', 'cont5', 'lastname', '1/1/1990', 'passwd'), --8

  ('authrev1@mail', 'authrev1', 'lastname', '1/1/1990', 'passwd'), --9
  ('authrev2@mail', 'authrev2', 'lastname', '1/1/1990', 'passwd'), --10

  ('cman1@mail', 'cman1', 'lastname', '1/1/1990', 'passwd'), --11
  ('cman2@mail', 'cman2', 'lastname', '1/1/1990', 'passwd'), --12
  ('cman3@mail', 'cman3', 'lastname', '1/1/1990', 'passwd'); --13

--Notified person >= 10
INSERT INTO [Notified_Person] (ID) VALUES--THIS DOESN'T MAKE MUCH SENSE
  (1),
  (2),
  (3),
  (4),
  (5),
  (6),
  (7),
  (8),
  (9),
  (10);

--Viewers >= 3
INSERT INTO [Viewer] (ID, working_place, working_place_type) VALUES
  (1, 'wp1', 'wpt1'),
  (2, 'wp2', 'wpt1'),
  (3, 'wp3', 'wpt2');

--Contributors >= 5
INSERT INTO [Contributor] (ID, notified_id, average_upload_time) VALUES
  (4, 1, 3),
  (5, 2, 2),
  (6, 3, 3),
  (7, 4, 4),
  (8, 5, 2);

--Adding staff >= 2+3
INSERT INTO [Staff] (ID, hire_date, working_hours, payment_rate, notified_id) VALUES
  (9, '1/1/2002', 8, 100, 6),
  (10, '1/1/2002', 8, 100, 7),
  (11, '1/1/2002', 8, 100, 8),
  (12, '1/1/2002', 8, 100, 9),
  (13, '1/1/2002', 8, 100, 10);

--Reviewers >= 2
INSERT INTO [Reviewer] (ID) VALUES
  (9),
  (10);

--Content managers >= 3
--Content_type needed first
INSERT INTO [Content_type] (type) VALUES
  ('Art');

INSERT INTO [Content_Manager] (ID, type) VALUES
  (11, 'Art'),
  (12, 'Art'),
  (13, 'Art');

--Content >= 3 + 3
INSERT INTO [Content] (uploaded_at, contributer_id, category_type, subcategory_name, type) VALUES
  ('2010-01-01T00:00:00', 4, 'Music', 'Blues', 'Art'),--1
  ('2010-01-01T00:00:00', 4, 'Music', 'Blues', 'Art'),--2
  ('2010-01-01T00:00:00', 5, 'Music', 'Blues', 'Art'),--3

  ('2010-01-01T00:00:00', 6, 'Music', 'Blues', 'Art'),--4
  ('2010-01-01T00:00:00', 6, 'Music', 'Blues', 'Art'),--5
  ('2010-01-01T00:00:00', 6, 'Music', 'Blues', 'Art');--6

--Original content >= 3
INSERT INTO [Original_Content] (ID, content_manager_id, reviewer_id, review_status, filter_status, rating) VALUES
  (4, 11, 9, 1, 1, 5),
  (5, 11, 9, 1, 1, 5),
  (6, 11, 9, 1, 1, 5);

--Existing requests >= 2
INSERT INTO [Existing_Request] (original_content_id, viewer_id) VALUES
  (4, 1),
  (6, 2);

--Notification objects >= 13
SET IDENTITY_INSERT [Notification_Object] ON;
INSERT INTO  [Notification_Object] (ID) VALUES
  (1),
  (2),
  (3),
  (4),
  (5),
  (6),
  (7),
  (8),
  (9),
  (10),
  (11),

  (12),
  (13);
SET IDENTITY_INSERT [Notification_Object] OFF;

--New requests >= 11
--  Two of them should have the same contributor and
--  the requests are accepted. Three of the new requests have another contributor and accepted and
--  each has a new content related to it. Three new requests have different contributors and accepted
--  but do not have content. Three new requests don't have a certain contributor and aren't accepted.
INSERT INTO [New_Request] (accept_status, specified, information, viewer_id, notif_obj_id, contributer_id) VALUES
  (1, 1, 'req1', 1, 1, 4),--1
  (1, 1, 'req2', 1, 2, 4),--2

  (1, 1, 'req3', 1, 3, 5),--3
  (1, 1, 'req4', 1, 4, 5),--4
  (1, 1, 'req5', 1, 5, 5),--5

  (1, 1, 'req6', 1, 6, 6),--6
  (1, 1, 'req7', 1, 7, 7),--7
  (1, 1, 'req8', 1, 8, 8),--8

  (0, 0, 'req9', 1, 9, NULL),--9
  (0, 0, 'req10', 1, 10, NULL),--10
  (0, 0, 'req11', 1, 11, NULL);--11

--New content >= 3
INSERT INTO [New_Content] (ID, new_request_id) VALUES
  (1, 3),
  (2, 4),
  (3, 5);

--Events >= 2
INSERT INTO [Event] (description, location, city, time, entertainer, notification_object_id, viewer_id) VALUES
  ('Event1', 'avenue', 'city', '2010-01-01T00:00:00', 'entertainer', 12, 1),--1
  ('Event2', 'avenue', 'city', '2010-01-01T00:00:00', 'entertainer', 13, 2);--2

--Announcements
INSERT INTO [Announcement] (notification_object_id, notified_person_id) VALUES
(1, 1),
(1, 1),

(3, 2),
(4, 2),
(5, 2),

(6, 3),
(7, 4),
(8, 5),

(9, 1),
(9, 2),
(9, 3),
(9, 4),
(9, 5),
(9, 6),
(9, 7),
(9, 8),
(9, 9),
(9, 10),
(10, 1),
(10, 2),
(10, 3),
(10, 4),
(10, 5),
(10, 6),
(10, 7),
(10, 8),
(10, 9),
(10, 10),
(11, 1),
(11, 2),
(11, 3),
(11, 4),
(11, 5),
(11, 6),
(11, 7),
(11, 8),
(11, 9),
(11, 10),
(12, 1),
(12, 2),
(12, 3),
(12, 4),
(12, 5),
(12, 6),
(12, 7),
(12, 8),
(12, 9),
(12, 10),
(13, 1),
(13, 2),
(13, 3),
(13, 4),
(13, 5),
(13, 6),
(13, 7),
(13, 8),
(13, 9),
(13, 10);

--Advertisements >= 2
INSERT INTO [Advertisement] (description, location, event_id, viewer_id) VALUES
  ('Ad1', 'avenue', 1, 1),
  ('Ad2', 'avenue', 2, 2);
-----------------------------------------------------------------------------------------------------------------------
