##########################################
# Final Project					    	  #
# Chao Gao (CG3283)  Dantong Zhu (dz2451) #
##########################################

# Add a new schema called `drug`
CREATE SCHEMA drug;

# Write a statement that applies all subsequent code to the weighin schema
USE drug;

# Parent table: Participants table
CREATE TABLE participants (
	PRIMARY KEY (participant_id),
    participant_id SMALLINT UNSIGNED AUTO_INCREMENT,
    participant_dob DATE,
    sex VARCHAR(8),
    age TINYINT UNSIGNED,
    education VARCHAR(100),
    drug_name VARCHAR(225),
    drug_id TINYINT UNSIGNED
);

CREATE INDEX participant_dob
	ON participants(participant_dob);
    
CREATE INDEX drug_id
	ON participants(drug_id);
   
# Child table: Visits table
CREATE TABLE visits (
	PRIMARY KEY (visit_id),
    visit_id MEDIUMINT UNSIGNED AUTO_INCREMENT,
    participant_id SMALLINT UNSIGNED,
    visitor_name VARCHAR(100),
    visit_date DATE,
    visit_time VARCHAR(100),
    result VARCHAR(220),
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id) ON UPDATE CASCADE
);

CREATE INDEX visit_date
	ON visits(visit_date);
    
CREATE INDEX visit_time
	ON visits(visit_time);

# Look up table: Adverse_events table
CREATE TABLE adverse_events (
	PRIMARY KEY (ae_id),
    ae_id TINYINT UNSIGNED AUTO_INCREMENT,
    ae_type VARCHAR(225)
);

CREATE INDEX ae_id
	ON adverse_events(ae_id);

# Child table: Adverse_events_log table
CREATE TABLE adverse_events_log (
	PRIMARY KEY (ae_log_id),
    ae_log_id TINYINT UNSIGNED AUTO_INCREMENT,
    drug_id TINYINT UNSIGNED,
    visit_id MEDIUMINT UNSIGNED,
    ae_id TINYINT UNSIGNED,
    ae_date DATE,
    ae_duration TINYINT UNSIGNED,
    FOREIGN KEY (drug_id) REFERENCES participants(drug_id) ON UPDATE CASCADE,
    FOREIGN KEY (visit_id) REFERENCES visits(visit_id) ON UPDATE CASCADE,
    FOREIGN KEY (ae_id) REFERENCES adverse_events(ae_id) ON UPDATE CASCADE
);

CREATE UNIQUE INDEX ae_unique
	ON adverse_events_log(drug_id, visit_id, ae_id);
    
CREATE INDEX ae_id
	ON adverse_events_log(ae_id);
    
CREATE INDEX drug_id
	ON adverse_events_log(drug_id);

CREATE INDEX visit_id
	ON adverse_events_log(visit_id);


############
# TRIGGERS #
############

# Trigger for Participants Table
DELIMITER //

CREATE TRIGGER trigger_participants
	BEFORE INSERT ON participants
    FOR EACH ROW
BEGIN
	/* Limit age range: 18 to 55 */
    IF NEW.age < 18 OR NEW.age > 55 THEN
		SIGNAL SQLSTATE 'HY000'
        SET MESSAGE_TEXT = 'Valid age range is 18 to 55 years';
	END IF;
    
END//


# Trigger for visits table
DELIMITER //

CREATE TRIGGER trigger_visits
	BEFORE INSERT ON visits
    FOR EACH ROW
BEGIN
	/* Limit visit_type to 0, 4, 8, 12, 16, or 20 */
    IF NEW.visit_date > CURDATE() THEN
		SIGNAL SQLSTATE 'HY000'
        SET MESSAGE_TEXT = 'Valid event dates are before or containing today';
	END IF;

END//


# Trigger for adverse_event_log table
DELIMITER //

CREATE TRIGGER trigger_ae_log
	BEFORE INSERT ON adverse_events_log
    FOR EACH ROW
BEGIN
	/*Limit event_date to dates between 6/15/2017 and today*/
	IF NEW.ae_date > CURDATE() THEN
		SIGNAL SQLSTATE 'HY000'
        SET MESSAGE_TEXT = 'Valid event dates are before or containing today';
	END IF;
    
END//

##############
# DATA ENTRY #
##############

/**** Think about the order in which to enter data into the tables to avoid errors related to orphaned records ****/

# Enter data into participants table
INSERT INTO participants (participant_dob, sex, age, education, drug_name, drug_id)
 VALUES
	("1997-08-21", "female", "25", "undergraduate", "ibuprofen", "001"),
    ("1998-09-22", "female", "24", "graduate", "ibuprofen", "001"),
    ("1999-06-23", "male", "23", "undergraduate", "aspirin", "002"),
    ("1999-05-24", "male", "23", "graduate", "aspirin", "002"),
    ("1996-04-25", "female", "26", "phd", "imuran", "003"),
    ("1987-06-23", "male", "35", "undergraduate", "Marijuana", "004"),
	("1997-01-11", "female", "25", "undergraduate", "ibuprofen", "001"),
    ("1998-02-12", "female", "24", "graduate", "ibuprofen", "001"),
    ("1999-04-13", "male", "23", "undergraduate", "aspirin", "002"),
    ("1999-05-14", "male", "23", "graduate", "aspirin", "002"),
    ("1996-06-15", "female", "26", "phd", "imuran", "003"),
    ("1987-07-13", "male", "35", "undergraduate", "Marijuana", "004");
    

# Enter data into visits table
INSERT INTO visits (participant_id, visitor_name, visit_date, visit_time, result)
 VALUES
	(1, 'Olivia', "2017-08-21", '08:04', 'good'),
    (2, 'Emma',	"2017-04-24", '11:03', 'good'),
    (3, 'Ava', "2017-05-19", '11:19', 'bad'),
	(1, 'Charlotte', "2016-04-09", '15:37', 'bad'),
	(4, 'Sophia', "2021-08-26", '02:05', 'good'),
	(2, 'Amelia', "2020-09-28", '02:08', 'good'),
	(5, 'Isabella', "2022-01-22", '03:49', 'good'),
	(1, 'Mia', "2020-02-19", "04:06", 'bad'),
	(6, 'Evelyn', "2021-08-21", '08:04', 'good'),
    (7, 'Harper',	"2020-04-30", '11:03', 'good'),
    (7, 'Camila', "2019-05-21", '11:19', 'bad'),
	(9, 'Abigail', "2018-04-26", '15:37', 'bad'),
	(8, 'Gianna', "2021-08-24", '02:05', 'good'),
	(7, 'Amelia', "2022-09-16", '02:08', 'good'),
	(5, 'Luna', "2020-01-12", '03:49', 'good'),
	(6, 'Mia', "2021-02-05", "04:06", 'bad');


# Enter data into adverse_events table
INSERT INTO adverse_events (ae_type)
 VALUES
	("Excessive fatigue"), 
	("Reaction to medication"),
	("Abnormal lab results"),
	("Hospitalization"),
	("Skin rash"),
	("Normal reaction"),
    ("Skin swell"),
    ("Omit"),
    ("Other");


# Enter data into adverse_events_log table
INSERT INTO adverse_events_log (drug_id, visit_id, ae_id,ae_date,ae_duration)
 VALUES
	('004', 3, 4, "2019-08-29", 20),
	('001', 2, 5, "2018-09-30", 30),
	('002', 3, 3, "2019-11-12", 10),
	('001', 3, 4, "2022-02-19", 25),
	('001', 1, 5, "2020-06-10", 35),
	('002', 4, 3, "2021-12-22", 15),
    ('003', 5, 4, "2022-01-12", 15),
	('003', 7, 5, "2020-04-13", 32),
	('002', 6, 3, "2021-10-24", 14),
    ('001', 5, 2, "2021-05-10", 12),
	('004', 7, 1, "2017-04-11", 30),
	('002', 6, 2, "2018-06-22", 08),
    ('001', 5, 4, "2019-07-19", 05),
	('004', 9, 1, "2020-08-10", 12),
	('002', 8, 3, "2021-10-22", 24);
