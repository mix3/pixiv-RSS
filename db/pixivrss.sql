CREATE TABLE User (
   id    TEXT NOT NULL PRIMARY KEY,
   user  TEXT NOT NULL UNIQUE,
   pass  TEXT NOT NULL
);

CREATE TABLE Image (
   name     TEXT NOT NULL PRIMARY KEY,
   title    TEXT,
   comment  TEXT,
   perma    TEXT
);

CREATE TABLE UserToImage (
   user_id     TEXT NOT NULL,
   image_name  TEXT NOT NULL,
   PRIMARY KEY (user_id, image_name)
);
