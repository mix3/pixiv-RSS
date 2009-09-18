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
