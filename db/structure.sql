CREATE TABLE "daily_words" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "word_id" integer NOT NULL, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "inflections" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255) NOT NULL, "word_id" integer);
CREATE TABLE "pointers" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "target_id" integer NOT NULL, "target_type" varchar(255) NOT NULL, "source_id" integer NOT NULL, "ptype" varchar(255) NOT NULL, "source_type" varchar(255) DEFAULT 'Sense' NOT NULL);
CREATE TABLE "senses" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "synset_id" integer, "word_id" integer, "freq_cnt" integer DEFAULT 0 NOT NULL, "synset_index" integer DEFAULT 0 NOT NULL, "marker" varchar(255));
CREATE TABLE "senses_verb_frames" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "sense_id" integer, "verb_frame_id" integer);
CREATE TABLE "synsets" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "definition" text NOT NULL, "offset" integer, "part_of_speech" varchar(255), "lexname" varchar(255) NOT NULL);
CREATE TABLE "verb_frames" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "frame" varchar(255), "number" integer);
CREATE TABLE "words" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255) NOT NULL, "part_of_speech" varchar(255) NOT NULL, "freq_cnt" integer DEFAULT 0 NOT NULL);
CREATE TABLE "schema_migrations" ("version" varchar(255) NOT NULL);
CREATE TABLE "users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "email" varchar(255) DEFAULT '' NOT NULL, "encrypted_password" varchar(128) DEFAULT '' NOT NULL, "reset_password_token" varchar(255), "reset_password_sent_at" datetime, "remember_created_at" datetime, "sign_in_count" integer DEFAULT 0, "current_sign_in_at" datetime, "last_sign_in_at" datetime, "current_sign_in_ip" varchar(255), "last_sign_in_ip" varchar(255), "authentication_token" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "device_tokens" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "token" varchar(255), "production" boolean, "created_at" datetime, "updated_at" datetime, "client_version" varchar(255));
CREATE INDEX "index_daily_words_on_created_at" ON "daily_words" ("created_at");
CREATE INDEX "index_inflections_on_name" ON "inflections" ("name");
CREATE INDEX "index_inflections_on_word_id" ON "inflections" ("word_id");
CREATE INDEX "index_pointers_on_source_id" ON "pointers" ("source_id");
CREATE INDEX "index_senses_on_synset_id" ON "senses" ("synset_id");
CREATE INDEX "index_senses_on_word_id_and_synset_id" ON "senses" ("word_id", "synset_id");
CREATE INDEX "index_senses_on_word_id" ON "senses" ("word_id");
CREATE INDEX "index_senses_verb_frames_on_sense_id" ON "senses_verb_frames" ("sense_id");
CREATE INDEX "index_synsets_on_offset_and_part_of_speech" ON "synsets" ("offset", "part_of_speech");
CREATE INDEX "index_verb_frames_on_number" ON "verb_frames" ("number");
CREATE INDEX "index_words_on_freq_cnt_and_name" ON "words" ("freq_cnt", "name");
CREATE INDEX "index_words_on_name_and_part_of_speech" ON "words" ("name", "part_of_speech");
CREATE INDEX "index_words_on_name" ON "words" ("name");
CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");
CREATE UNIQUE INDEX "index_users_on_email" ON "users" ("email");
CREATE UNIQUE INDEX "index_users_on_reset_password_token" ON "users" ("reset_password_token");
CREATE UNIQUE INDEX "index_device_tokens_on_token_and_production" ON "device_tokens" ("token", "production");
CREATE VIRTUAL TABLE inflections_fts USING fts4(id, name, word_id);
CREATE TABLE 'inflections_fts_content'(docid INTEGER PRIMARY KEY, 'c0id', 'c1name', 'c2word_id');
CREATE TABLE 'inflections_fts_segments'(blockid INTEGER PRIMARY KEY, block BLOB);
CREATE TABLE 'inflections_fts_segdir'(level INTEGER,idx INTEGER,start_block INTEGER,leaves_end_block INTEGER,end_block INTEGER,root BLOB,PRIMARY KEY(level, idx));
CREATE TABLE 'inflections_fts_docsize'(docid INTEGER PRIMARY KEY, size BLOB);
CREATE TABLE 'inflections_fts_stat'(id INTEGER PRIMARY KEY, value BLOB);
CREATE VIRTUAL TABLE synsets_fts USING fts4(id, definition);
CREATE TABLE 'synsets_fts_content'(docid INTEGER PRIMARY KEY, 'c0id', 'c1definition');
CREATE TABLE 'synsets_fts_segments'(blockid INTEGER PRIMARY KEY, block BLOB);
CREATE TABLE 'synsets_fts_segdir'(level INTEGER,idx INTEGER,start_block INTEGER,leaves_end_block INTEGER,end_block INTEGER,root BLOB,PRIMARY KEY(level, idx));
CREATE TABLE 'synsets_fts_docsize'(docid INTEGER PRIMARY KEY, size BLOB);
CREATE TABLE 'synsets_fts_stat'(id INTEGER PRIMARY KEY, value BLOB);
CREATE VIRTUAL TABLE synset_suggestions USING fts4(synset_id, suggestion);
CREATE TABLE 'synset_suggestions_content'(docid INTEGER PRIMARY KEY, 'c0synset_id', 'c1suggestion');
CREATE TABLE 'synset_suggestions_segments'(blockid INTEGER PRIMARY KEY, block BLOB);
CREATE TABLE 'synset_suggestions_segdir'(level INTEGER,idx INTEGER,start_block INTEGER,leaves_end_block INTEGER,end_block INTEGER,root BLOB,PRIMARY KEY(level, idx));
CREATE TABLE 'synset_suggestions_docsize'(docid INTEGER PRIMARY KEY, size BLOB);
CREATE TABLE 'synset_suggestions_stat'(id INTEGER PRIMARY KEY, value BLOB);
INSERT INTO schema_migrations (version) VALUES ('20101017043609');

INSERT INTO schema_migrations (version) VALUES ('20101017043706');

INSERT INTO schema_migrations (version) VALUES ('20101017043743');

INSERT INTO schema_migrations (version) VALUES ('20101028010805');

INSERT INTO schema_migrations (version) VALUES ('20101030000545');

INSERT INTO schema_migrations (version) VALUES ('20101031024347');

INSERT INTO schema_migrations (version) VALUES ('20101031050938');

INSERT INTO schema_migrations (version) VALUES ('20101031162542');

INSERT INTO schema_migrations (version) VALUES ('20101031170413');

INSERT INTO schema_migrations (version) VALUES ('20101104214054');

INSERT INTO schema_migrations (version) VALUES ('20101105231754');

INSERT INTO schema_migrations (version) VALUES ('20101106181722');

INSERT INTO schema_migrations (version) VALUES ('20101107135403');

INSERT INTO schema_migrations (version) VALUES ('20101109025101');

INSERT INTO schema_migrations (version) VALUES ('20101109033819');

INSERT INTO schema_migrations (version) VALUES ('20101109043654');

INSERT INTO schema_migrations (version) VALUES ('20101113185359');

INSERT INTO schema_migrations (version) VALUES ('20101123171834');

INSERT INTO schema_migrations (version) VALUES ('20101206002039');

INSERT INTO schema_migrations (version) VALUES ('20110123231632');

INSERT INTO schema_migrations (version) VALUES ('20110629194559');

INSERT INTO schema_migrations (version) VALUES ('20110724155208');

INSERT INTO schema_migrations (version) VALUES ('20110724160943');

INSERT INTO schema_migrations (version) VALUES ('20110805131815');

INSERT INTO schema_migrations (version) VALUES ('20130102181347');

INSERT INTO schema_migrations (version) VALUES ('20130107234336');

INSERT INTO schema_migrations (version) VALUES ('20130806180052');

INSERT INTO schema_migrations (version) VALUES ('20140810202705');

INSERT INTO schema_migrations (version) VALUES ('20140811190025');

INSERT INTO schema_migrations (version) VALUES ('20140814152215');

INSERT INTO schema_migrations (version) VALUES ('20150927032006');

