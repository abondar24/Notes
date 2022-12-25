const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idCol = "id";
const emailCol = "email";
const userIdCol = "user_id";
const textCol = "text";

const createUserTable = ''' 
           CREATE TABLE IF NOT EXISTS "user"(
            "id" INTEGER NOT NULL,
            "email" TEXT NOT NULL UNIQUE,
            PRIMARY KEY("id" AUTOINCREMENT)
           );
      ''';

const createNoteTable = ''' 
           CREATE TABLE IF NOT EXISTS "note"(
            "id" INTEGER NOT NULL,
            "user_id" INTEGER NOT NULL,
            "text" TEXT ,
            PRIMARY KEY("id" AUTOINCREMENT)
            FOREIGN KEY ("user_id") REFERENCES "user"("id")
           );
      ''';

const int allNotesOffset = 0;
const int allNotesLimit =
    10000000000; //ultra-big limit to get all notes for sure