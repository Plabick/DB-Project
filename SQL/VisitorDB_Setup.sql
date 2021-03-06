-- To use the python code as is, plz set up your system like this
-- USER: visitorDBUser
-- PASSWORD: password
drop schema if exists visitorDB;
CREATE SCHEMA visitorDB;
use visitorDB;

DROP TABLE IF EXISTS patient;
CREATE TABLE IF NOT EXISTS patient (
  patient_id INT NOT NULL,
  patient_first_name VARCHAR(50) NOT NULL,
  patient_last_name VARCHAR(50) NOT NULL,
  patient_dob DATE,
  patient_classification ENUM("inpatient", "outpatient", "icu", "er", "ob") NOT NULL,
  patient_precaution ENUM("none", "contact", "airborne") NOT NULL,
  patient_eol TINYINT NOT NULL,
  patient_building ENUM("Tower", "CWN", "Shapiro", "Hale") NULL,
  patient_room INT NULL,
  PRIMARY KEY (patient_id));


DROP TABLE IF EXISTS visitor ;
CREATE TABLE IF NOT EXISTS visitor (
  visitor_id INT auto_increment,
  visitor_name VARCHAR(50) NOT NULL,
  PRIMARY KEY (visitor_id));


DROP TABLE IF EXISTS screener ;
CREATE TABLE IF NOT EXISTS screener (
  screener_id INT NOT NULL,
  screener_name VARCHAR(50) NOT NULL,
  screener_station INT NOT NULL,
  PRIMARY KEY (screener_id));


DROP TABLE IF EXISTS visit ;
CREATE TABLE IF NOT EXISTS visit (
  visit_id INT auto_increment,
  patient_id INT NOT NULL,
  screener_id INT NOT NULL,
  visitor_id INT NOT NULL,
  visit_date DATETIME NOT NULL,
  visit_start TIME NOT NULL,
  visit_end TIME NOT NULL,
  let_in tinyint NOT NULL,
  PRIMARY KEY (visit_id),
  FOREIGN KEY (patient_id) REFERENCES patient (patient_id),
  FOREIGN KEY (screener_id) REFERENCES screener (screener_id),
  FOREIGN KEY (visitor_id) REFERENCES visitor (visitor_id));


DROP TABLE IF EXISTS question ;
CREATE TABLE IF NOT EXISTS question (
  question_id INT NOT NULL,
  question_text varchar(255) NOT NULL UNIQUE,
  question_correct_answer tinyint NOT NULL,
  PRIMARY KEY (question_id));


DROP TABLE IF EXISTS visitor_has_answer ;
CREATE TABLE IF NOT EXISTS visitor_has_answer (
  visitor_id INT NOT NULL,
  date DATETIME NOT NULL,
  question_id INT NOT NULL,
  visitor_answer tinyint NOT NULL,
  FOREIGN KEY (visitor_id) REFERENCES visitor (visitor_id),
  FOREIGN KEY (question_id)REFERENCES question (question_id));
  
-- INSERTS
insert into question
(question_id, question_text, question_correct_answer) 
values
(1,"In the last 14 days, have you traveled out of state?", false),
(2,"In the last 14 days, have you been exposure to anyone with covid-19?", false),
(3,"Are you experiencing any symptoms of covid-19?", false);

insert into screener
(screener_id, screener_name, screener_station)
values
 (1,"Peter Labick",1),
 (2,"Marla Davis",2),
 (3,"Tommy Nelson",2); -- Shares a desk (for contact tracing)
 

insert into patient
(patient_id, patient_first_name, patient_last_name, patient_classification, patient_precaution , patient_eol, patient_building , patient_room )
values
(1, "Normal", "Dude", "inpatient", "none", false, "Tower", 614), -- normal patient
(2, "Joe", "Mama", "inpatient", "none", false, "Shapiro", 411), -- normal patient
(3, "Can't", "Smell", "inpatient", "airborne", false, "CWN", 523), -- No visitors due to airborne precautions
(4, "No", "Limits", "inpatient", "none", true, "Tower", 723), -- No visitor limit due to EOL
(5, "Jane", "Doe", "icu", "contact", true, "Hale", 247),
(6, "John", "Doe", "outpatient", "none", true, "CWN", 133),
(7, "Alice", "Doe", "er", "none", true, "Shapiro", 313),
(81, "James", "Doe", "ob", "none", true, "Tower", 412),
(8, "Sperm", "Whale", "inpatient", "none", false, "Tower", 723),
(9, "Paul", "Erdo", "inpatient", "none", false, "Tower", 623);

insert into visitor
( visitor_name)
values
("Joe Mamma"),
("Sick Man"), -- shouldn't be allowed in to due answer
("Visit Again"), -- shouldn't be allowed in due to 2nd visitor of day for given patient
("Humpback Whale"),  -- is allowed in
("E.F. Codd"),  -- is allowed in
("John Rachlin"); -- is allowed in, already visited erdo

 insert into visitor_has_answer
 (visitor_id, date, question_id, visitor_answer)
 values
 (1,DATE("2020-11-23"), 1, false), -- jo mama's answers
 (1,DATE("2020-11-23"), 2, false),
 (1,DATE("2020-11-23"), 3, false),
 (2,DATE("2020-11-23"), 1, false), -- Sick Man's answers
 (2,DATE("2020-11-23"), 2, false),
 (2,DATE("2020-11-23"), 3, true), -- Sick Man is sick
 (3,DATE("2020-11-23"), 1, false), -- Visit Again's answers
 (3,DATE("2020-11-23"), 2, false),
 (3,DATE("2020-11-23"), 3, false),
 (4,DATE("2020-11-23"), 1, false), -- Humpback Whale's answers
 (4,DATE("2020-11-23"), 2, false),
 (4,DATE("2020-11-23"), 3, false),
 (5,DATE("2020-11-23"), 1, false), -- EF Codd's answers
 (5,DATE("2020-11-23"), 2, false),
 (5,DATE("2020-11-23"), 3, false),
 (6,DATE("2020-11-23"), 1, false), -- John Rachlin's answers
 (6,DATE("2020-11-23"), 2, false),
 (6,DATE("2020-11-23"), 3, false);


insert into visit
(visit_id, patient_id , screener_id , visitor_id, visit_date, visit_start , visit_end, let_in)
values
(1,1,1,1,DATE("2020-11-23"), time("01:30:00"),time("02:30:00"), true),
(2,2,1,5,DATE("2020-11-23"), time("01:30:00"),time("02:30:00"), true), -- EF Codd visit
(3,9,2,6,DATE("2020-11-23"), time("01:30:00"),time("02:30:00"), true); -- Paul Erdos Visit

 -- Test query 



 select patient_building, patient_room from visit join visitor using (visitor_id) join patient using (patient_id) where visitor_name ="Joe Mamma";
 select visitor_name from visit join visitor using (visitor_id) join patient using (patient_id) where patient_first_name ="<tkinter.Entryobject.!entry3>" and patient_last_name ="<tkinter.Entryobject.!entry4>"; 

select patient_first_name, patient_last_name from visit join visitor using (visitor_id) join patient using (patient_id) where visitor_name like "Joe Mamma"; 

select patient_eol = true or patient_precaution = "none" from patient where patient_first_name = "Normal" and patient_last_name = "Dude";

insert into visitor (visitor_name) values ("{vfn}  {vln}");-- To use the python code as is, plz set up your system like this
-- USER: visitorDBUser
-- PASSWORD: password
drop schema if exists visitorDB;
CREATE SCHEMA visitorDB;
use visitorDB;

DROP TABLE IF EXISTS patient;
CREATE TABLE IF NOT EXISTS patient (
  patient_id INT NOT NULL,
  patient_first_name VARCHAR(50) NOT NULL,
  patient_last_name VARCHAR(50) NOT NULL,
  patient_dob DATE,
  patient_classification ENUM("inpatient", "outpatient", "icu", "er", "ob") NOT NULL,
  patient_precaution ENUM("none", "contact", "airborne") NOT NULL,
  patient_eol TINYINT NOT NULL,
  patient_building ENUM("Tower", "CWN", "Shapiro", "Hale") NULL,
  patient_room INT NULL,
  PRIMARY KEY (patient_id));


DROP TABLE IF EXISTS visitor ;
CREATE TABLE IF NOT EXISTS visitor (
  visitor_id INT auto_increment,
  visitor_name VARCHAR(50) NOT NULL,
  PRIMARY KEY (visitor_id));


DROP TABLE IF EXISTS screener ;
CREATE TABLE IF NOT EXISTS screener (
  screener_id INT NOT NULL,
  screener_name VARCHAR(50) NOT NULL,
  screener_station INT NOT NULL,
  PRIMARY KEY (screener_id));


DROP TABLE IF EXISTS visit ;
CREATE TABLE IF NOT EXISTS visit (
  visit_id INT auto_increment,
  patient_id INT NOT NULL,
  screener_id INT NOT NULL,
  visitor_id INT NOT NULL,
  visit_date DATETIME NOT NULL,
  visit_start TIME NOT NULL,
  visit_end TIME NOT NULL,
  let_in tinyint NOT NULL,
  PRIMARY KEY (visit_id),
  FOREIGN KEY (patient_id) REFERENCES patient (patient_id),
  FOREIGN KEY (screener_id) REFERENCES screener (screener_id),
  FOREIGN KEY (visitor_id) REFERENCES visitor (visitor_id));


DROP TABLE IF EXISTS question ;
CREATE TABLE IF NOT EXISTS question (
  question_id INT NOT NULL,
  question_text varchar(255) NOT NULL UNIQUE,
  question_correct_answer tinyint NOT NULL,
  PRIMARY KEY (question_id));


DROP TABLE IF EXISTS visitor_has_answer ;
CREATE TABLE IF NOT EXISTS visitor_has_answer (
  visitor_id INT NOT NULL,
  date DATETIME NOT NULL,
  question_id INT NOT NULL,
  visitor_answer tinyint NOT NULL,
  FOREIGN KEY (visitor_id) REFERENCES visitor (visitor_id),
  FOREIGN KEY (question_id)REFERENCES question (question_id));
  
-- INSERTS
insert into question
(question_id, question_text, question_correct_answer) 
values
(1,"In the last 14 days, have you traveled out of state?", false),
(2,"In the last 14 days, have you been exposure to anyone with covid-19?", false),
(3,"Are you experiencing any symptoms of covid-19?", false);

insert into screener
(screener_id, screener_name, screener_station)
values
 (1,"Peter Labick",1),
 (2,"Marla Davis",2),
 (3,"Tommy Nelson",2); -- Shares a desk (for contact tracing)
 

insert into patient
(patient_id, patient_first_name, patient_last_name, patient_classification, patient_precaution , patient_eol, patient_building , patient_room )
values
(1, "Normal", "Dude", "inpatient", "none", false, "Tower", 614), -- normal patient
(2, "Joe", "Mama", "inpatient", "none", false, "Shapiro", 411), -- normal patient
(3, "Can't", "Smell", "inpatient", "airborne", false, "CWN", 523), -- No visitors due to airborne precautions
(4, "No", "Limits", "inpatient", "none", true, "Tower", 723), -- No visitor limit due to EOL
(5, "Jane", "Doe", "icu", "contact", true, "Hale", 247),
(6, "John", "Doe", "outpatient", "none", true, "CWN", 133),
(7, "Alice", "Doe", "er", "none", true, "Shapiro", 313),
(81, "James", "Doe", "ob", "none", true, "Tower", 412),
(8, "Sperm", "Whale", "inpatient", "none", false, "Tower", 723),
(9, "Paul", "Erdo", "inpatient", "none", false, "Tower", 623);

insert into visitor
( visitor_name)
values
("Joe Mamma"),
("Sick Man"), -- shouldn't be allowed in to due answer
("Visit Again"), -- shouldn't be allowed in due to 2nd visitor of day for given patient
("Humpback Whale"),  -- is allowed in
("E.F. Codd"),  -- is allowed in
("John Rachlin"); -- is allowed in, already visited erdo

 insert into visitor_has_answer
 (visitor_id, date, question_id, visitor_answer)
 values
 (1,DATE("2020-11-23"), 1, false), -- jo mama's answers
 (1,DATE("2020-11-23"), 2, false),
 (1,DATE("2020-11-23"), 3, false),
 (2,DATE("2020-11-23"), 1, false), -- Sick Man's answers
 (2,DATE("2020-11-23"), 2, false),
 (2,DATE("2020-11-23"), 3, true), -- Sick Man is sick
 (3,DATE("2020-11-23"), 1, false), -- Visit Again's answers
 (3,DATE("2020-11-23"), 2, false),
 (3,DATE("2020-11-23"), 3, false),
 (4,DATE("2020-11-23"), 1, false), -- Humpback Whale's answers
 (4,DATE("2020-11-23"), 2, false),
 (4,DATE("2020-11-23"), 3, false),
 (5,DATE("2020-11-23"), 1, false), -- EF Codd's answers
 (5,DATE("2020-11-23"), 2, false),
 (5,DATE("2020-11-23"), 3, false),
 (6,DATE("2020-11-23"), 1, false), -- John Rachlin's answers
 (6,DATE("2020-11-23"), 2, false),
 (6,DATE("2020-11-23"), 3, false);


-- insert into visit
-- (visit_id, patient_id , screener_id , visitor_id, visit_date, visit_start , visit_end, let_in)
-- values
-- (1,1,1,1,DATE("2020-11-23"), time("01:30:00"),time("02:30:00"), true),
-- (2,2,1,5,DATE("2020-11-23"), time("01:30:00"),time("02:30:00"), true), -- EF Codd visit
-- (3,9,2,6,DATE("2020-11-23"), time("01:30:00"),time("02:30:00"), true); -- Paul Erdos Visit

 -- Test query 


 select patient_building, patient_room from visit join visitor using (visitor_id) join patient using (patient_id) where visitor_name ="Joe Mamma";
 select visitor_name from visit join visitor using (visitor_id) join patient using (patient_id) where patient_first_name ="<tkinter.Entryobject.!entry3>" and patient_last_name ="<tkinter.Entryobject.!entry4>"; 

select patient_first_name, patient_last_name from visit join visitor using (visitor_id) join patient using (patient_id) where visitor_name like "Joe Mamma"; 

select patient_eol = true or patient_precaution = "none" from patient where patient_first_name = "Normal" and patient_last_name = "Dude";

insert into visitor (visitor_name) values ("{vfn}  {vln}");
                                                
-- trigger to codify visit rules                   
DROP TRIGGER IF EXISTS codify_visit_rules;

DELIMITER //

CREATE TRIGGER codify_visit_rules
	BEFORE INSERT on visit
	FOR EACH ROW
BEGIN   
   -- if patient is allowed visitors
   if (select patient_eol = true or patient_precaution = "none" 
	from patient 
	where patient_first_name = "{pfn}" 
	and patient_last_name = "{pln}") 
	-- if visitor answered no too all questioons
    and not
    (select visitor_answer 
    from visitor_has_answer
    join visitor using (visitor_id)
    where visitor_id = new.visitor_id and question_id = 0)  = 1 
    and not
    (select visitor_answer 
    from visitor_has_answer
    join visitor using (visitor_id)
    where visitor_id = new.visitor_id and question_id = 1)  = 1 
    and not
    (select visitor_answer 
    from visitor_has_answer
    join visitor using (visitor_id)
    where visitor_id = new.visitor_id and question_id = 2)  = 1 
    then 
    -- add visitor to visit 
    insert into visit values (
    new.visit_id, new.patient_id, new.screener_id, 
    new.visitor_id, new.visit_date, new.visit_start,
    new.visit_end, 1);

   -- else 
    -- else throw an error
   -- signal sqlstate 'HY000';
    
    
  end if;
    
END //

DELIMITER ;