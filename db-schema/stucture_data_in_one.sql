/*
Navicat PGSQL Data Transfer

Source Server         : localhost
Source Server Version : 90203
Source Host           : localhost:5432
Source Database       : pa036
Source Schema         : public

Target Server Type    : PGSQL
Target Server Version : 90203
File Encoding         : 65001

Date: 2014-05-07 11:45:50
*/

-- ----------------------------
-- Drop views
-- ----------------------------
DROP VIEW IF EXISTS "public"."projection_seats";
DROP VIEW IF EXISTS "public"."projection_overview";
DROP VIEW IF EXISTS "public"."projection_schedule";

-- ----------------------------
-- Drop tables
-- ----------------------------
DROP TABLE IF EXISTS "public"."booking_hall_seat";
DROP TABLE IF EXISTS "public"."booking";
DROP TABLE IF EXISTS "public"."booking_status";
DROP TABLE IF EXISTS "public"."employee";
DROP TABLE IF EXISTS "public"."customer";
DROP TABLE IF EXISTS "public"."club";
DROP TABLE IF EXISTS "public"."projection";
DROP TABLE IF EXISTS "public"."movie_genre";
DROP TABLE IF EXISTS "public"."genre";
DROP TABLE IF EXISTS "public"."movie";
DROP TABLE IF EXISTS "public"."hall_seat";
DROP TABLE IF EXISTS "public"."seat_type";
DROP TABLE IF EXISTS "public"."hall_hall_property";
DROP TABLE IF EXISTS "public"."hall";
DROP TABLE IF EXISTS "public"."branch_office";
DROP TABLE IF EXISTS "public"."country";
DROP TABLE IF EXISTS "public"."hall_property";

-- ----------------------------
-- Table structure for booking
-- ----------------------------
CREATE TABLE "public"."booking" (
"booking_id" serial primary key,
"projection_id" integer,
"customer_id" integer,
"booking_status_id" integer,
"price_total" numeric(10,2) CHECK (price_total >= 0),
"time_created" timestamp with time zone,
"employee_id" integer
)
WITH (OIDS=FALSE)

;

-- ----------------------------
-- Table structure for booking_hall_seat
-- ----------------------------
CREATE TABLE "public"."booking_hall_seat" (
"booking_id" integer NOT NULL,
"seat_id" integer NOT NULL
)
WITH (OIDS=FALSE)

;

-- ----------------------------
-- Table structure for booking_status
-- ----------------------------
CREATE TABLE "public"."booking_status" (
"booking_status_id" serial primary key,
"status" varchar(255) COLLATE "default"
)
WITH (OIDS=FALSE)

;

-- ----------------------------
-- Table structure for branch_office
-- ----------------------------
CREATE TABLE "public"."branch_office" (
"branch_office_id" serial primary key,
"name" character varying(255),
"description" text,
"address_line_1" character varying(255),
"address_line_2" character varying(255),
"city" character varying(255),
"postal_code" character varying(10),
"country_id" integer
)
WITH (OIDS=FALSE)

;

-- ----------------------------
-- Table structure for club
-- ----------------------------
CREATE TABLE "public"."club" (
"club_id" serial primary key,
"name" character varying(255),
"sale_amount" integer,
"sale_percentage" numeric(3,2)
)
WITH (OIDS=FALSE)

;

-- ----------------------------
-- Table structure for country
-- ----------------------------
CREATE TABLE "public"."country" (
"country_id" serial primary key,
"name" character varying(255) NOT NULL
)
WITH (OIDS=FALSE)

;

-- ----------------------------
-- Table structure for customer
-- ----------------------------
CREATE TABLE "public"."customer" (
"customer_id" serial primary key,
"first_name" character varying(128),
"last_name" character varying(128),
"phone_number" character varying(15),
"club_id" integer,
"email" character varying(255) NOT NULL,
"username" character varying(255) NOT NULL,
"password" character varying(255) NOT NULL
)
WITH (OIDS=FALSE)

;

-- ----------------------------
-- Table structure for employee
-- ----------------------------
CREATE TABLE "public"."employee" (
"employee_id" serial primary key,
"username" character varying(255) NOT NULL,
"password" character varying(255) NOT NULL
)
WITH (OIDS=FALSE)

;

-- ----------------------------
-- Table structure for genre
-- ----------------------------
CREATE TABLE "public"."genre" (
"genre_id" serial primary key,
"genre_type" character varying(255)
)
WITH (OIDS=FALSE)

;

-- ----------------------------
-- Table structure for hall
-- ----------------------------
CREATE TABLE "public"."hall" (
"hall_id" serial primary key,
"branch_office_id" integer NOT NULL,
"label" character varying(255) NOT NULL,
"is_3D" bool DEFAULT false NOT NULL
)
WITH (OIDS=FALSE)

;

-- ----------------------------
-- Table structure for hall_hall_property
-- ----------------------------
CREATE TABLE "public"."hall_hall_property" (
"hall_property_id" integer NOT NULL,
"hall_id" integer NOT NULL
)
WITH (OIDS=FALSE)

;

-- ----------------------------
-- Table structure for hall_property
-- ----------------------------
CREATE TABLE "public"."hall_property" (
"hall_property_id" serial primary key,
"key" character varying(255) NOT NULL,
"value" character varying(255) NOT NULL
)
WITH (OIDS=FALSE)

;

-- ----------------------------
-- Table structure for hall_seat
-- ----------------------------
CREATE TABLE "public"."hall_seat" (
"seat_id" serial primary key,
"hall_id" integer,
"seat_type_id" integer,
"seat_row" integer,
"seat_number" integer
)
WITH (OIDS=FALSE)

;

-- ----------------------------
-- Table structure for movie
-- ----------------------------
CREATE TABLE "public"."movie" (
"movie_id" serial primary key,
"title" character varying(255),
"descritption" text,
"running_time" integer,
"release_date" date
)
WITH (OIDS=FALSE)

;

-- ----------------------------
-- Table structure for movie_genre
-- ----------------------------
CREATE TABLE "public"."movie_genre" (
"movie_id" integer NOT NULL,
"genre_id" integer NOT NULL
)
WITH (OIDS=FALSE)

;

-- ----------------------------
-- Table structure for projection
-- ----------------------------
CREATE TABLE "public"."projection" (
"projection_id" serial primary key,
"movie_id" integer,
"hall_id" integer,
"start" timestamp with time zone,
"price" numeric(10,2) CHECK (price >= 0),
"is_3D" bool DEFAULT false NOT NULL
)
WITH (OIDS=FALSE)

;

-- ----------------------------
-- Table structure for seat_type
-- ----------------------------
CREATE TABLE "public"."seat_type" (
"seat_type_id" serial primary key,
"seat_type" character varying(255) NOT NULL,
"seat_type_sale_amount" integer,
"seat_type_sale_percantage" numeric(3,2)
)
WITH (OIDS=FALSE)

;

-- ----------------------------
-- View structure for projection_seats
-- ----------------------------
CREATE VIEW "public"."projection_seats" AS
SELECT
	p.projection_id,
	hs.seat_id,
	hs.seat_type_id,
	hs.seat_row,
	hs.seat_number,
	CASE WHEN (MAX(bhs.seat_id) IS NULL) THEN 'free' ELSE 'booked' END AS state
FROM
	hall_seat hs
	LEFT JOIN projection p ON (hs.hall_id = p.hall_id)
	LEFT JOIN booking b ON (b.projection_id = p.projection_id AND b.booking_status_id != 1)
	LEFT JOIN booking_hall_seat bhs ON (bhs.booking_id = b.booking_id AND bhs.seat_id = hs.seat_id)
GROUP BY
	hs.seat_id,
	p.projection_id,
	hs.seat_type_id,
	hs.seat_row,
	hs.seat_number
ORDER BY
	hs.seat_row,
	hs.seat_number;

CREATE VIEW "public"."projection_overview" AS
SELECT projection.projection_id, movie.title, movie.descritption AS descritiption, movie.running_time, date_part('year'::text, movie.release_date) AS release_year, projection.start, projection.price AS projection_price, hall.hall_id, (SELECT ARRAY(SELECT genre.genre_type FROM (movie_genre LEFT JOIN genre ON ((genre.genre_id = movie_genre.genre_id))) WHERE (movie.movie_id = movie_genre.movie_id)) AS "array") AS genre_types, (SELECT count(*) AS count FROM (hall_seat LEFT JOIN projection pr ON ((pr.hall_id = hall_seat.hall_id))) WHERE (pr.projection_id = projection.projection_id)) AS seats_total, (SELECT count(booking_hall_seat.seat_id) AS count FROM (booking LEFT JOIN booking_hall_seat ON (booking.booking_id = booking_hall_seat.booking_id) LEFT JOIN projection pr ON (pr.projection_id = booking.projection_id)) WHERE (pr.projection_id = projection.projection_id  AND booking.booking_status_id != 1)) AS seats_booked, branch_office.branch_office_id FROM (((projection LEFT JOIN movie ON ((movie.movie_id = projection.movie_id))) LEFT JOIN hall ON ((hall.hall_id = projection.hall_id))) LEFT JOIN branch_office ON ((branch_office.branch_office_id = hall.branch_office_id))) ORDER BY hall.label, projection.start;;

CREATE VIEW "public"."projection_schedule" AS
SELECT DISTINCT hall.branch_office_id, date_part('year'::text, projection.start) AS projection_date_year, date_part('month'::text, projection.start) AS projection_date_month, date_part('day'::text, projection.start) AS projection_date_day FROM (((projection LEFT JOIN movie ON ((movie.movie_id = projection.movie_id))) LEFT JOIN hall ON ((hall.hall_id = projection.hall_id))) LEFT JOIN branch_office ON ((branch_office.branch_office_id = hall.branch_office_id))) ORDER BY date_part('year'::text, projection.start), date_part('month'::text, projection.start), date_part('day'::text, projection.start);;


-- ----------------------------
-- Indexes structure for table booking
-- ----------------------------
CREATE INDEX "booking_booking_status_id_idx" ON "public"."booking" USING btree (booking_status_id);
CREATE INDEX "booking_customer_id_idx" ON "public"."booking" USING btree (customer_id);
CREATE INDEX "booking_employee_id_idx" ON "public"."booking" USING btree (employee_id);
CREATE INDEX "booking_projection_id_idx" ON "public"."booking" USING btree (projection_id);

-- ----------------------------
-- Indexes structure for table booking_hall_seat
-- ----------------------------
CREATE INDEX "booking_hall_seat_booking_id_idx" ON "public"."booking_hall_seat" USING btree (booking_id);
CREATE INDEX "booking_hall_seat_seat_id_idx" ON "public"."booking_hall_seat" USING btree (seat_id);

-- ----------------------------
-- Uniques structure for table booking_status
-- ----------------------------
ALTER TABLE "public"."booking_status" ADD UNIQUE ("status");

-- ----------------------------
-- Indexes structure for table customer
-- ----------------------------
CREATE INDEX "customer_club_id_idx" ON "public"."customer" USING btree (club_id);

-- ----------------------------
-- Uniques structure for table genre
-- ----------------------------
ALTER TABLE "public"."genre" ADD UNIQUE ("genre_type");

-- ----------------------------
-- Indexes structure for table hall
-- ----------------------------
CREATE INDEX "hall_branch_office_id_idx" ON "public"."hall" USING btree (branch_office_id);

-- ----------------------------
-- Indexes structure for table hall_hall_property
-- ----------------------------
CREATE INDEX "hall_hall_property_hall_id_idx" ON "public"."hall_hall_property" USING btree (hall_id);
CREATE INDEX "hall_hall_property_hall_property_id_idx" ON "public"."hall_hall_property" USING btree (hall_property_id);

-- ----------------------------
-- Uniques structure for table hall_property
-- ----------------------------
ALTER TABLE "public"."hall_property" ADD UNIQUE ("key");

-- ----------------------------
-- Indexes structure for table hall_seat
-- ----------------------------
CREATE INDEX "hall_seat_hall_id_idx" ON "public"."hall_seat" USING btree (hall_id);
CREATE INDEX "hall_seat_seat_type_id_idx" ON "public"."hall_seat" USING btree (seat_type_id);

-- ----------------------------
-- Indexes structure for table projection
-- ----------------------------
CREATE INDEX "projection_hall_id_idx" ON "public"."projection" USING btree (hall_id);
CREATE INDEX "projection_movie_id_idx" ON "public"."projection" USING btree (movie_id);

-- ----------------------------
-- Indexes structure for table branch_office
-- ----------------------------
CREATE INDEX "branch_office_country_id_idx" ON "public"."branch_office" USING btree (country_id);

-- ----------------------------
-- Indexes structure for table movie_genre
-- ----------------------------
CREATE INDEX "movie_genre_movie_id_idx" ON "public"."movie_genre" USING btree (movie_id);
CREATE INDEX "movie_genre_genre_id_idx" ON "public"."movie_genre" USING btree (genre_id);

-- ----------------------------
-- Foreign Key structure for table "public"."booking"
-- ----------------------------
ALTER TABLE "public"."booking" ADD FOREIGN KEY ("employee_id") REFERENCES "public"."employee" ("employee_id") ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE "public"."booking" ADD FOREIGN KEY ("customer_id") REFERENCES "public"."customer" ("customer_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."booking" ADD FOREIGN KEY ("projection_id") REFERENCES "public"."projection" ("projection_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."booking" ADD FOREIGN KEY ("booking_status_id") REFERENCES "public"."booking_status" ("booking_status_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Key structure for table "public"."booking_hall_seat"
-- ----------------------------
ALTER TABLE "public"."booking_hall_seat" ADD FOREIGN KEY ("booking_id") REFERENCES "public"."booking" ("booking_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."booking_hall_seat" ADD FOREIGN KEY ("seat_id") REFERENCES "public"."hall_seat" ("seat_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Key structure for table "public"."branch_office"
-- ----------------------------
ALTER TABLE "public"."branch_office" ADD FOREIGN KEY ("country_id") REFERENCES "public"."country" ("country_id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- ----------------------------
-- Foreign Key structure for table "public"."customer"
-- ----------------------------
ALTER TABLE "public"."customer" ADD FOREIGN KEY ("club_id") REFERENCES "public"."club" ("club_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Key structure for table "public"."hall"
-- ----------------------------
ALTER TABLE "public"."hall" ADD FOREIGN KEY ("branch_office_id") REFERENCES "public"."branch_office" ("branch_office_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Key structure for table "public"."hall_hall_property"
-- ----------------------------
ALTER TABLE "public"."hall_hall_property" ADD FOREIGN KEY ("hall_id") REFERENCES "public"."hall" ("hall_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."hall_hall_property" ADD FOREIGN KEY ("hall_property_id") REFERENCES "public"."hall_property" ("hall_property_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Key structure for table "public"."hall_seat"
-- ----------------------------
ALTER TABLE "public"."hall_seat" ADD FOREIGN KEY ("hall_id") REFERENCES "public"."hall" ("hall_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."hall_seat" ADD FOREIGN KEY ("seat_type_id") REFERENCES "public"."seat_type" ("seat_type_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Key structure for table "public"."movie_genre"
-- ----------------------------
ALTER TABLE "public"."movie_genre" ADD FOREIGN KEY ("movie_id") REFERENCES "public"."movie" ("movie_id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "public"."movie_genre" ADD FOREIGN KEY ("genre_id") REFERENCES "public"."genre" ("genre_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- ----------------------------
-- Foreign Key structure for table "public"."projection"
-- ----------------------------
ALTER TABLE "public"."projection" ADD FOREIGN KEY ("hall_id") REFERENCES "public"."hall" ("hall_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."projection" ADD FOREIGN KEY ("movie_id") REFERENCES "public"."movie" ("movie_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
-- chybna definice FK
--ALTER TABLE "public"."projection" ADD FOREIGN KEY ("movie_id") REFERENCES "public"."projection_type" ("movie_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ----------------------------
-- Records of country
-- ----------------------------
INSERT INTO "public"."country" (country_id, name) VALUES (1, 'Czech Republic');
select setval('country_country_id_seq', 2, false);

-- ----------------------------
-- Records of branch_office
-- ----------------------------
INSERT INTO "public"."branch_office" (branch_office_id, name, description, address_line_1, address_line_2, city, postal_code, country_id)
  VALUES ('1', 'CINEMA Brno', null, 'Centrum 1', '', 'Brno', '600000', '1');
INSERT INTO "public"."branch_office" (branch_office_id, name, description, address_line_1, address_line_2, city, postal_code, country_id)
  VALUES ('2', 'CINEMA Praha', null, 'Václavské nám 4', '', 'Praha', '54321', '1');
select setval('branch_office_branch_office_id_seq', 3, false);

-- ----------------------------
-- Records of customer
-- ----------------------------
INSERT INTO "public"."customer" (customer_id, first_name, last_name, phone_number, club_id, email, username, password) VALUES ('1', 'jon', 'snow', '+420123456789', null, 'jon@example.com', 'username', 'pass');
select setval('customer_customer_id_seq',2, false);

-- ----------------------------
-- Records of genre
-- ----------------------------
INSERT INTO "public"."genre" (genre_id, genre_type) VALUES (1, 'akční');
INSERT INTO "public"."genre" (genre_id, genre_type) VALUES (2, 'drama');
INSERT INTO "public"."genre" (genre_id, genre_type) VALUES (3, 'komedie');
INSERT INTO "public"."genre" (genre_id, genre_type) VALUES (4, 'romantika');
INSERT INTO "public"."genre" (genre_id, genre_type) VALUES (5, 'horor');
select setval('genre_genre_id_seq',6, false);

-- ----------------------------
-- Records of hall
-- ----------------------------
INSERT INTO "public"."hall" (hall_id, branch_office_id, label) VALUES (1, 1, 'Sál 1');
INSERT INTO "public"."hall" (hall_id, branch_office_id, label) VALUES (2, 1, 'Sál 2');
INSERT INTO "public"."hall" (hall_id, branch_office_id, label) VALUES (3, 1, 'Sál 3');
INSERT INTO "public"."hall" (hall_id, branch_office_id, label) VALUES (4, 2, 'Sál Praha 1');
INSERT INTO "public"."hall" (hall_id, branch_office_id, label) VALUES (5, 2, 'Sál Praha 2');
INSERT INTO "public"."hall" (hall_id, branch_office_id, label) VALUES (6, 2, 'Sál Praha 3');
select setval('branch_office_branch_office_id_seq',7, false);

-- ----------------------------
-- Records of movie
-- ----------------------------
INSERT INTO "public"."movie" (movie_id, title, descritption, running_time, release_date) VALUES (1, 'Dr. No', 'Dr. No je v pořadí první film o Jamesi Bondovi z roku 1962. Jde o vcelku věrnou adaptaci šestého románu spisovatele Iana Fleminga o této postavě z roku 1958.', 105, '1962-01-01');
INSERT INTO "public"."movie" (movie_id, title, descritption, running_time, release_date) VALUES (2, 'Srdečné pozdravy z Ruska', 'Srdečné pozdravy z Ruska je v pořadí druhý film o Jamesi Bondovi z roku 1963, adaptací pátého románu spisovatele Iana Fleminga o této postavě z roku 1957.', 110, '1963-01-01');
INSERT INTO "public"."movie" (movie_id, title, descritption, running_time, release_date) VALUES (3, 'Goldfinger', 'Goldfinger je v pořadí třetí film o Jamesi Bondovi z roku 1964, adaptace sedmého románu spisovatele Iana Fleminga o této postavě z roku 1959.', 105 , '2014-05-07');
INSERT INTO "public"."movie" (movie_id, title, descritption, running_time, release_date) VALUES (4, 'Thunderball', 'Thunderball je v pořadí čtvrtý film o Jamesi Bondovi z roku 1965, adaptace devátého románu spisovatele Iana Fleminga o této postavě z roku 1961.', 125, '1965-01-01');
INSERT INTO "public"."movie" (movie_id, title, descritption, running_time, release_date) VALUES (5, 'Žiješ jenom dvakrát', 'Žiješ jenom dvakrát (v originále You Only Live Twice) je v pořadí pátý film o Jamesi Bondovi z roku 1967. Scénář napsal na základě dvanáctého románu spisovatele Iana Fleminga (1964) Roald Dahl. Je to první bondovka, u které se autor scénáře výrazně odpoutal od Flemingovy předlohy a vytvořil (při zachování některých jejích kulis) zcela nový příběh.', 112, '1967-01-01');
INSERT INTO "public"."movie" (movie_id, title, descritption, running_time, release_date) VALUES (6, 'V tajné službě Jejího Veličenstva', 'V tajné službě Jejího Veličenstva (také Ve službách Jejího Veličenstva) je v pořadí šestý film o Jamesi Bondovi z roku 1969, adaptace jedenáctého románu spisovatele Iana Fleminga o této postavě z roku 1963.', 140 , '1969-01-01');
INSERT INTO "public"."movie" (movie_id, title, descritption, running_time, release_date) VALUES (7, 'Diamanty jsou věčné', 'Diamanty jsou věčné je v pořadí sedmý film o Jamesi Bondovi z roku 1971, velice volná adaptace čtvrtého románu spisovatele Iana Fleminga o této postavě z roku 1956. Pro Seana Conneryho to byla šestý a poslední film v oficiální sérii, kde si zahrál Bonda, v roce 1983 si ovšem znovu 007 zahrál v neoficiální bondovce Nikdy neříkej nikdy.', 120, '1971-01-01');
select setval('movie_movie_id_seq', 8, false);

-- ----------------------------
-- Records of movie_genre
-- ----------------------------
INSERT INTO "public"."movie_genre" (movie_id, genre_id) VALUES (1, 1);
INSERT INTO "public"."movie_genre" (movie_id, genre_id) VALUES (1, 3);
INSERT INTO "public"."movie_genre" (movie_id, genre_id) VALUES (2, 1);
INSERT INTO "public"."movie_genre" (movie_id, genre_id) VALUES (2, 2);
INSERT INTO "public"."movie_genre" (movie_id, genre_id) VALUES (2, 3);
INSERT INTO "public"."movie_genre" (movie_id, genre_id) VALUES (3, 1);
INSERT INTO "public"."movie_genre" (movie_id, genre_id) VALUES (3, 2);
INSERT INTO "public"."movie_genre" (movie_id, genre_id) VALUES (3, 3);
INSERT INTO "public"."movie_genre" (movie_id, genre_id) VALUES (4, 1);
INSERT INTO "public"."movie_genre" (movie_id, genre_id) VALUES (4, 2);
INSERT INTO "public"."movie_genre" (movie_id, genre_id) VALUES (4, 3);
INSERT INTO "public"."movie_genre" (movie_id, genre_id) VALUES (5, 1);
INSERT INTO "public"."movie_genre" (movie_id, genre_id) VALUES (5, 2);
INSERT INTO "public"."movie_genre" (movie_id, genre_id) VALUES (5, 3);
INSERT INTO "public"."movie_genre" (movie_id, genre_id) VALUES (6, 1);
INSERT INTO "public"."movie_genre" (movie_id, genre_id) VALUES (6, 2);
INSERT INTO "public"."movie_genre" (movie_id, genre_id) VALUES (6, 3);
INSERT INTO "public"."movie_genre" (movie_id, genre_id) VALUES (7, 1);
INSERT INTO "public"."movie_genre" (movie_id, genre_id) VALUES (7, 2);
INSERT INTO "public"."movie_genre" (movie_id, genre_id) VALUES (7, 3);

-- ----------------------------
-- Records of booking_status
-- ----------------------------
INSERT INTO "public"."booking_status" (booking_status_id, status) VALUES (1, 'SELECTED');
INSERT INTO "public"."booking_status" (booking_status_id, status) VALUES (2, 'PAID');
INSERT INTO "public"."booking_status" (booking_status_id, status) VALUES (3, 'PICKED');
select setval('booking_status_booking_status_id_seq', 4, false);

-- ----------------------------
-- Records of projection
-- ----------------------------
INSERT INTO "public"."projection" (projection_id, movie_id, hall_id, start, price, "is_3D") VALUES (1, 1, 1, '2014-05-13 11:00:00+02', 150.00, 'f');
INSERT INTO "public"."projection" (projection_id, movie_id, hall_id, start, price, "is_3D") VALUES (2, 3, 1, '2014-05-13 13:40:00+02', 150.00, 't');
INSERT INTO "public"."projection" (projection_id, movie_id, hall_id, start, price, "is_3D") VALUES (3, 4, 1, '2014-05-13 16:20:00+02', 120.00, 'f');
INSERT INTO "public"."projection" (projection_id, movie_id, hall_id, start, price, "is_3D") VALUES (4, 2, 2, '2014-05-13 11:20:00+02', 150.00, 'f');
INSERT INTO "public"."projection" (projection_id, movie_id, hall_id, start, price, "is_3D") VALUES (5, 6, 2, '2014-05-13 14:20:00+02', 120.00, 'f');
INSERT INTO "public"."projection" (projection_id, movie_id, hall_id, start, price, "is_3D") VALUES (6, 7, 2, '2014-05-13 17:50:00+02', 150.00, 'f');
INSERT INTO "public"."projection" (projection_id, movie_id, hall_id, start, price, "is_3D") VALUES (7, 3, 3, '2014-05-13 18:50:00+02', 150.00, 't');
select setval('projection_projection_id_seq', 8, false);

-- ----------------------------
-- Records of seat_type
-- ----------------------------
INSERT INTO "public"."seat_type" (seat_type_id, seat_type, seat_type_sale_amount, seat_type_sale_percantage) VALUES ('1', 'normal', null, null);
INSERT INTO "public"."seat_type" (seat_type_id, seat_type, seat_type_sale_amount, seat_type_sale_percantage) VALUES ('2', 'love_seat', null, null);
select setval('seat_type_seat_type_id_seq', 3, false);

-- ----------------------------
-- Records of hall_seat
-- ----------------------------
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('1', '1', '1', '1', '1');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('2', '1', '1', '1', '2');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('3', '1', '1', '1', '3');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('4', '1', '1', '1', '4');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('5', '1', '1', '1', '5');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('6', '1', '1', '1', '6');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('7', '1', '1', '1', '7');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('8', '1', '1', '1', '8');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('9', '1', '1', '1', '9');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('10', '1', '1', '1', '10');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('11', '1', '1', '1', '11');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('12', '1', '1', '1', '12');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('13', '1', '1', '1', '13');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('14', '1', '1', '1', '14');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('15', '1', '1', '2', '1');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('16', '1', '1', '2', '2');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('17', '1', '1', '2', '3');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('18', '1', '1', '2', '4');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('19', '1', '1', '2', '5');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('20', '1', '1', '2', '6');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('21', '1', '1', '2', '7');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('22', '1', '1', '2', '8');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('23', '1', '1', '2', '9');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('24', '1', '1', '2', '10');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('25', '1', '1', '2', '11');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('26', '1', '1', '2', '12');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('27', '1', '1', '2', '13');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('28', '1', '1', '2', '14');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('29', '1', '1', '3', '1');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('30', '1', '1', '3', '2');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('31', '1', '1', '3', '3');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('32', '1', '1', '3', '4');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('33', '1', '1', '3', '5');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('34', '1', '1', '3', '6');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('35', '1', '1', '3', '7');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('36', '1', '1', '3', '8');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('37', '1', '1', '3', '9');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('38', '1', '1', '3', '10');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('39', '1', '1', '3', '11');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('40', '1', '1', '3', '12');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('41', '1', '1', '3', '13');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('42', '1', '1', '3', '14');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('43', '1', '1', '4', '1');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('44', '1', '1', '4', '2');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('45', '1', '1', '4', '3');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('46', '1', '1', '4', '4');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('47', '1', '1', '4', '5');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('48', '1', '1', '4', '6');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('49', '1', '1', '4', '7');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('50', '1', '1', '4', '8');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('51', '1', '1', '4', '9');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('52', '1', '1', '4', '10');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('53', '1', '1', '4', '11');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('54', '1', '1', '4', '12');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('55', '1', '1', '4', '13');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('56', '1', '1', '4', '14');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('57', '1', '1', '5', '1');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('58', '1', '1', '5', '2');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('59', '1', '1', '5', '3');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('60', '1', '1', '5', '4');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('61', '1', '1', '5', '5');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('62', '1', '1', '5', '6');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('63', '1', '1', '5', '7');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('64', '1', '1', '5', '8');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('65', '1', '1', '5', '9');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('66', '1', '1', '5', '10');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('67', '1', '1', '5', '11');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('68', '1', '1', '5', '12');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('69', '1', '1', '5', '13');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('70', '1', '1', '5', '14');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('71', '1', '1', '6', '1');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('72', '1', '1', '6', '2');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('73', '1', '1', '6', '3');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('74', '1', '1', '6', '4');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('75', '1', '1', '6', '5');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('76', '1', '1', '6', '6');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('77', '1', '1', '6', '7');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('78', '1', '1', '6', '8');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('79', '1', '1', '6', '9');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('80', '1', '1', '6', '10');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('81', '1', '1', '6', '11');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('82', '1', '1', '6', '12');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('83', '1', '1', '6', '13');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('84', '1', '1', '6', '14');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('85', '1', '1', '7', '1');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('86', '1', '1', '7', '2');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('87', '1', '1', '7', '3');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('88', '1', '1', '7', '4');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('89', '1', '1', '7', '5');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('90', '1', '1', '7', '6');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('91', '1', '1', '7', '7');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('92', '1', '1', '7', '8');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('93', '1', '1', '7', '9');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('94', '1', '1', '7', '10');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('95', '1', '1', '7', '11');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('96', '1', '1', '7', '12');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('97', '1', '1', '7', '13');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('98', '1', '1', '7', '14');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('99', '1', '1', '8', '1');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('100', '1', '1', '8', '2');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('101', '1', '1', '8', '3');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('102', '1', '1', '8', '4');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('103', '1', '1', '8', '5');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('104', '1', '1', '8', '6');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('105', '1', '1', '8', '7');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('106', '1', '1', '8', '8');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('107', '1', '1', '8', '9');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('108', '1', '1', '8', '10');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('109', '1', '1', '8', '11');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('110', '1', '1', '8', '12');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('111', '1', '1', '8', '13');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('112', '1', '1', '8', '14');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('113', '1', '1', '9', '1');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('114', '1', '1', '9', '2');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('115', '1', '1', '9', '3');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('116', '1', '1', '9', '4');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('117', '1', '1', '9', '5');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('118', '1', '1', '9', '6');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('119', '1', '1', '9', '7');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('120', '1', '1', '9', '8');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('121', '1', '1', '9', '9');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('122', '1', '1', '9', '10');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('123', '1', '1', '9', '11');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('124', '1', '1', '9', '12');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('125', '1', '1', '9', '13');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('126', '1', '1', '9', '14');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('127', '1', '1', '10', '1');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('128', '1', '1', '10', '2');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('129', '1', '1', '10', '3');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('130', '1', '1', '10', '4');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('131', '1', '1', '10', '5');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('132', '1', '1', '10', '6');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('133', '1', '1', '10', '7');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('134', '1', '1', '10', '8');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('135', '1', '1', '10', '9');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('136', '1', '1', '10', '10');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('137', '1', '1', '10', '11');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('138', '1', '1', '10', '12');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('139', '1', '1', '10', '13');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('140', '1', '1', '10', '14');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('141', '2', '1', '1', '1');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('142', '2', '1', '1', '2');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('143', '2', '1', '1', '3');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('144', '2', '1', '1', '4');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('145', '2', '1', '1', '5');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('146', '2', '1', '1', '6');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('147', '2', '1', '1', '7');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('148', '2', '1', '1', '8');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('149', '2', '1', '1', '9');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('150', '2', '1', '1', '10');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('151', '2', '1', '1', '11');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('152', '2', '1', '1', '12');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('153', '2', '1', '2', '1');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('154', '2', '1', '2', '2');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('155', '2', '1', '2', '3');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('156', '2', '1', '2', '4');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('157', '2', '1', '2', '5');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('158', '2', '1', '2', '6');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('159', '2', '1', '2', '7');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('160', '2', '1', '2', '8');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('161', '2', '1', '2', '9');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('162', '2', '1', '2', '10');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('163', '2', '1', '2', '11');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('164', '2', '1', '2', '12');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('165', '2', '1', '3', '1');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('166', '2', '1', '3', '2');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('167', '2', '1', '3', '3');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('168', '2', '1', '3', '4');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('169', '2', '1', '3', '5');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('170', '2', '1', '3', '6');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('171', '2', '1', '3', '7');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('172', '2', '1', '3', '8');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('173', '2', '1', '3', '9');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('174', '2', '1', '3', '10');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('175', '2', '1', '3', '11');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('176', '2', '1', '3', '12');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('177', '2', '1', '4', '1');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('178', '2', '1', '4', '2');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('179', '2', '1', '4', '3');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('180', '2', '1', '4', '4');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('181', '2', '1', '4', '5');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('182', '2', '1', '4', '6');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('183', '2', '1', '4', '7');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('184', '2', '1', '4', '8');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('185', '2', '1', '4', '9');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('186', '2', '1', '4', '10');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('187', '2', '1', '4', '11');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('188', '2', '1', '4', '12');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('189', '2', '1', '5', '1');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('190', '2', '1', '5', '2');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('191', '2', '1', '5', '3');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('192', '2', '1', '5', '4');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('193', '2', '1', '5', '5');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('194', '2', '1', '5', '6');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('195', '2', '1', '5', '7');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('196', '2', '1', '5', '8');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('197', '2', '1', '5', '9');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('198', '2', '1', '5', '10');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('199', '2', '1', '5', '11');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('200', '2', '1', '5', '12');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('201', '2', '1', '6', '1');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('202', '2', '1', '6', '2');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('203', '2', '1', '6', '3');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('204', '2', '1', '6', '4');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('205', '2', '1', '6', '5');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('206', '2', '1', '6', '6');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('207', '2', '1', '6', '7');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('208', '2', '1', '6', '8');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('209', '2', '1', '6', '9');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('210', '2', '1', '6', '10');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('211', '2', '1', '6', '11');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('212', '2', '1', '6', '12');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('213', '2', '1', '7', '1');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('214', '2', '1', '7', '2');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('215', '2', '1', '7', '3');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('216', '2', '1', '7', '4');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('217', '2', '1', '7', '5');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('218', '2', '1', '7', '6');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('219', '2', '1', '7', '7');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('220', '2', '1', '7', '8');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('221', '2', '1', '7', '9');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('222', '2', '1', '7', '10');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('223', '2', '1', '7', '11');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('224', '2', '1', '7', '12');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('225', '2', '1', '8', '1');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('226', '2', '1', '8', '2');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('227', '2', '1', '8', '3');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('228', '2', '1', '8', '4');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('229', '2', '1', '8', '5');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('230', '2', '1', '8', '6');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('231', '2', '1', '8', '7');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('232', '2', '1', '8', '8');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('233', '2', '1', '8', '9');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('234', '2', '1', '8', '10');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('235', '2', '1', '8', '11');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('236', '2', '1', '8', '12');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('237', '2', '1', '9', '1');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('238', '2', '1', '9', '2');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('239', '2', '1', '9', '3');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('240', '2', '1', '9', '4');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('241', '2', '1', '9', '5');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('242', '2', '1', '9', '6');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('243', '2', '1', '9', '7');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('244', '2', '1', '9', '8');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('245', '2', '1', '9', '9');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('246', '2', '1', '9', '10');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('247', '2', '1', '9', '11');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('248', '2', '1', '9', '12');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('249', '2', '1', '10', '1');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('250', '2', '1', '10', '2');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('251', '2', '1', '10', '3');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('252', '2', '1', '10', '4');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('253', '2', '1', '10', '5');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('254', '2', '1', '10', '6');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('255', '2', '1', '10', '7');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('256', '2', '1', '10', '8');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('257', '2', '1', '10', '9');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('258', '2', '1', '10', '10');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('259', '2', '1', '10', '11');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('260', '2', '1', '10', '12');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('261', '3', '1', '1', '1');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('262', '3', '1', '1', '2');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('263', '3', '1', '1', '3');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('264', '3', '1', '1', '4');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('265', '3', '1', '1', '5');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('266', '3', '1', '1', '6');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('267', '3', '1', '1', '7');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('268', '3', '1', '1', '8');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('269', '3', '1', '1', '9');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('270', '3', '1', '1', '10');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('271', '3', '1', '1', '11');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('272', '3', '1', '1', '12');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('273', '3', '1', '2', '1');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('274', '3', '1', '2', '2');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('275', '3', '1', '2', '3');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('276', '3', '1', '2', '4');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('277', '3', '1', '2', '5');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('278', '3', '1', '2', '6');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('279', '3', '1', '2', '7');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('280', '3', '1', '2', '8');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('281', '3', '1', '2', '9');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('282', '3', '1', '2', '10');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('283', '3', '1', '2', '11');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('284', '3', '1', '2', '12');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('285', '3', '1', '3', '1');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('286', '3', '1', '3', '2');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('287', '3', '1', '3', '3');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('288', '3', '1', '3', '4');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('289', '3', '1', '3', '5');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('290', '3', '1', '3', '6');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('291', '3', '1', '3', '7');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('292', '3', '1', '3', '8');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('293', '3', '1', '3', '9');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('294', '3', '1', '3', '10');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('295', '3', '1', '3', '11');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('296', '3', '1', '3', '12');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('297', '3', '1', '4', '1');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('298', '3', '1', '4', '2');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('299', '3', '1', '4', '3');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('300', '3', '1', '4', '4');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('301', '3', '1', '4', '5');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('302', '3', '1', '4', '6');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('303', '3', '1', '4', '7');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('304', '3', '1', '4', '8');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('305', '3', '1', '4', '9');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('306', '3', '1', '4', '10');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('307', '3', '1', '4', '11');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('308', '3', '1', '4', '12');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('309', '3', '1', '5', '1');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('310', '3', '1', '5', '2');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('311', '3', '1', '5', '3');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('312', '3', '1', '5', '4');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('313', '3', '1', '5', '5');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('314', '3', '1', '5', '6');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('315', '3', '1', '5', '7');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('316', '3', '1', '5', '8');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('317', '3', '1', '5', '9');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('318', '3', '1', '5', '10');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('319', '3', '1', '5', '11');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('320', '3', '1', '5', '12');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('321', '3', '1', '6', '1');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('322', '3', '1', '6', '2');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('323', '3', '1', '6', '3');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('324', '3', '1', '6', '4');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('325', '3', '1', '6', '5');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('326', '3', '1', '6', '6');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('327', '3', '1', '6', '7');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('328', '3', '1', '6', '8');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('329', '3', '1', '6', '9');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('330', '3', '1', '6', '10');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('331', '3', '1', '6', '11');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('332', '3', '1', '6', '12');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('333', '3', '1', '7', '1');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('334', '3', '1', '7', '2');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('335', '3', '1', '7', '3');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('336', '3', '1', '7', '4');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('337', '3', '1', '7', '5');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('338', '3', '1', '7', '6');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('339', '3', '1', '7', '7');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('340', '3', '1', '7', '8');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('341', '3', '1', '7', '9');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('342', '3', '1', '7', '10');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('343', '3', '1', '7', '11');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('344', '3', '1', '7', '12');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('345', '3', '1', '8', '1');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('346', '3', '1', '8', '2');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('347', '3', '1', '8', '3');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('348', '3', '1', '8', '4');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('349', '3', '1', '8', '5');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('350', '3', '1', '8', '6');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('351', '3', '1', '8', '7');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('352', '3', '1', '8', '8');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('353', '3', '1', '8', '9');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('354', '3', '1', '8', '10');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('355', '3', '1', '8', '11');
INSERT INTO "public"."hall_seat" (seat_id, hall_id, seat_type_id, seat_row, seat_number) VALUES ('356', '3', '1', '8', '12');
select setval('hall_seat_seat_id_seq', 357, false);

-- ----------------------------
-- Records of booking
-- ----------------------------
INSERT INTO "public"."booking" (booking_id, projection_id, customer_id, booking_status_id, price_total, time_created, employee_id)
  VALUES ('1', '1', '1', '1', '200.00', '2014-05-07 11:29:09+02', null);
INSERT INTO "public"."booking" (booking_id, projection_id, customer_id, booking_status_id, price_total, time_created, employee_id)
  VALUES ('2', '2', '1', '2', '600.00', '2014-05-07 11:30:06+02', null);
INSERT INTO "public"."booking" (booking_id, projection_id, customer_id, booking_status_id, price_total, time_created, employee_id)
  VALUES ('3', '3', '1', '2', '600.00', '2014-05-07 11:30:06+02', null);
INSERT INTO "public"."booking" (booking_id, projection_id, customer_id, booking_status_id, price_total, time_created, employee_id)
  VALUES ('4', '4', '1', '2', '600.00', '2014-05-07 11:30:06+02', null);
INSERT INTO "public"."booking" (booking_id, projection_id, customer_id, booking_status_id, price_total, time_created, employee_id)
  VALUES ('5', '5', '1', '2', '600.00', '2014-05-07 11:30:06+02', null);
INSERT INTO "public"."booking" (booking_id, projection_id, customer_id, booking_status_id, price_total, time_created, employee_id)
  VALUES ('6', '6', '1', '2', '600.00', '2014-05-07 11:30:06+02', null);
INSERT INTO "public"."booking" (booking_id, projection_id, customer_id, booking_status_id, price_total, time_created, employee_id)
  VALUES ('7', '7', '1', '2', '600.00', '2014-05-07 11:30:06+02', null);
INSERT INTO "public"."booking" (booking_id, projection_id, customer_id, booking_status_id, price_total, time_created, employee_id)
  VALUES ('8', '7', '1', '2', '600.00', '2014-05-07 11:30:06+02', null);
select setval('booking_booking_id_seq', 9, false);

-- ----------------------------
-- Records of booking_hall_seat
-- ----------------------------
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 94);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 16);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 130);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 66);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 10);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 5);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 45);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 92);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 110);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 59);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 32);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 79);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 20);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 21);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 7);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 90);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 86);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 33);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 136);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 58);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 48);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 111);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 53);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 88);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 50);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 34);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 76);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 15);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 81);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 112);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 71);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 65);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 3);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 118);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 99);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 95);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 2);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 134);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 115);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 98);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 113);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 119);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 128);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 27);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 126);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 129);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 54);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 68);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 102);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 1);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 137);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 108);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 29);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 78);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 11);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 73);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 18);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 19);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 42);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 46);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 43);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 52);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 44);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 84);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 124);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 31);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 72);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 55);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 106);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 64);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 104);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 4);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 63);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 107);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 89);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 24);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 87);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 135);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 51);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 49);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 14);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 93);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 91);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 25);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 47);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 127);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 85);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 100);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 6);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 77);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 36);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (1, 57);
-- booking 2
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 6);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 47);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 11);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 131);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 4);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 67);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 139);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 54);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 64);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 29);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 96);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 91);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 88);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 100);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 18);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 55);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 118);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 105);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 42);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 23);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 92);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 90);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 86);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 56);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 81);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 60);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 77);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 41);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 58);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 108);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 135);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 93);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 130);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 106);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 53);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 3);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 76);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 57);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 35);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 124);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 109);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 117);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 38);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 95);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 107);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 28);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 103);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 82);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 20);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 9);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 32);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 119);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 70);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 99);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 39);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 17);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 50);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (2, 136);
--booking 3
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (3, 74);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (3, 106);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (3, 66);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (3, 36);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (3, 18);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (3, 65);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (3, 103);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (3, 55);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (3, 32);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (3, 21);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (3, 76);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (3, 26);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (3, 114);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (3, 80);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (3, 15);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (3, 86);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (3, 132);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (3, 37);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (3, 94);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (3, 108);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (3, 111);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (3, 43);
--booking 4
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 169);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 168);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 251);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 148);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 176);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 238);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 213);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 257);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 190);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 179);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 194);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 258);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 247);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 198);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 210);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 160);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 249);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 202);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 189);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 177);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 187);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 163);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 151);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 161);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 252);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 195);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 192);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 208);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 226);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 215);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 180);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 243);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 171);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 152);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 188);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 150);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 227);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 146);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 241);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 259);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 165);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 186);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 142);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 181);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 224);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 222);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 221);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 242);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 225);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 147);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 200);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 149);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 197);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 216);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 178);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 162);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 233);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 236);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 154);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 223);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 175);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 245);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 191);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 199);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 173);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 219);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 228);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 231);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 218);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 239);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 205);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 253);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 214);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 182);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 212);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 203);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 240);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 217);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 193);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 183);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 246);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 155);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 220);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 158);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 157);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 196);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 141);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 229);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 174);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 172);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 201);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (4, 143);
--booking 5
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 192);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 217);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 224);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 210);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 243);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 194);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 191);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 170);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 193);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 162);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 179);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 230);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 164);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 195);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 238);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 206);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 205);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 141);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 184);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 146);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 228);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 143);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 154);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 147);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 152);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 242);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 167);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 161);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 236);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 182);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 258);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 157);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 151);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 198);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 229);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 211);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 257);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 204);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 207);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 158);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 218);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 173);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 190);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 186);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 144);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 252);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 223);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 159);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 247);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 231);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 250);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 237);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 178);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 166);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 197);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 149);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 253);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 201);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 155);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 145);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 165);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 142);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 241);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 239);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 148);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 153);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 180);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 245);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 176);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 203);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 172);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 177);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 214);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 187);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 225);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 202);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 251);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 171);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 213);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 222);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 216);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 255);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 254);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 233);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 249);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 163);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 199);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 246);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 156);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 174);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 212);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 235);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 209);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 226);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 248);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 185);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 208);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 150);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 220);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 188);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 200);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 227);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 215);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 196);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 183);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 219);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 240);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (5, 234);
--booking 6
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 230);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 157);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 254);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 180);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 255);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 153);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 206);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 166);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 181);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 156);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 199);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 196);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 218);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 238);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 170);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 234);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 214);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 179);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 143);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 141);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 154);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 233);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 237);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 194);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 182);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 220);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 212);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 150);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 225);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 239);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 193);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 176);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 144);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 142);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 256);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 236);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 240);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (6, 162);
--booking 7
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 329);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 353);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 305);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 263);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 319);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 303);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 342);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 309);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 304);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 274);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 308);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 273);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 338);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 272);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 284);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 264);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 292);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 320);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 312);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 297);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 350);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 278);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 354);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 266);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 331);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 311);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 291);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 262);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 286);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 275);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 339);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 341);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 300);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 325);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 290);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 324);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 276);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 289);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 293);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 322);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 344);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 313);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 281);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 268);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 267);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 328);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 327);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 345);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 326);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 288);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 333);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 283);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 280);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 270);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 277);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 271);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 336);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 307);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 261);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 321);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 330);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 323);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 347);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (7, 340);
--booking 8
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (8, 280);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (8, 270);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (8, 277);
INSERT INTO "public"."booking_hall_seat" (booking_id, seat_id) VALUES (8, 271);



-- new hall
INSERT INTO "public"."hall" ("hall_id", "branch_office_id", "label", "is_3D") VALUES ('7', '1', 'Sál 4', 't');
INSERT INTO "public"."projection" ("movie_id", "hall_id", "start", "price", "is_3D") VALUES ('1', '7', '2014-05-13 16:50:00+02', '150', 't');

INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 1, 1);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 1, 2);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 1, 3);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 1, 4);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 1, 7);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 1, 8);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 1, 9);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 1, 10);

INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 2, 1);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 2, 2);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 2, 3);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 2, 4);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 2, 7);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 2, 8);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 2, 9);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 2, 10);

INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 3, 1);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 3, 2);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 3, 3);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 3, 4);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 3, 7);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 3, 8);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 3, 9);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 3, 10);

INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 4, 1);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 4, 2);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 4, 3);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 4, 4);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 4, 7);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 4, 8);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 4, 9);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 4, 10);

INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 5, 1);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 5, 2);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 5, 3);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 5, 4);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 5, 7);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 5, 8);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 5, 9);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 5, 10);

INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 6, 1);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 2, 6, 2);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 6, 4);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 2, 6, 5);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 6, 7);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 2, 6, 8);
INSERT INTO "public"."hall_seat" (hall_id, seat_type_id, seat_row, seat_number) VALUES (7, 1, 6, 10);
