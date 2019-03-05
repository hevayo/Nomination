-- 
-- NOMINATION V2.7.0
-- 
DROP DATABASE IF EXISTS EC_NOMINATION;

CREATE DATABASE IF NOT EXISTS EC_NOMINATION CHARACTER SET UTF8MB4 COLLATE UTF8MB4_UNICODE_CI;

USE EC_NOMINATION;



-- 
-- ELECTION MODULES
-- mainly regarding to maintain the configs
-- 


-- election_module file to maintain election types
CREATE TABLE IF NOT EXISTS ELECTION_MODULE(
    ID VARCHAR(36) PRIMARY KEY,
    NAME VARCHAR(100) NOT NULL, 		/* eg value: 'parliamentary', 'provincial' */
    DIVISION_COMMON_NAME VARCHAR(20),	/* eg value: 'district', 'province' */
    CREATED_BY VARCHAR(50),
    CREATED_AT BIGINT,
    UPDATED_AT BIGINT
)ENGINE=INNODB;

-- manage approval status of election module
CREATE TABLE IF NOT EXISTS ELECTION_MODULE_APPROVAL(
	ID VARCHAR(36) PRIMARY KEY,
	STATUS ENUM('PENDING','APPROVE','REJECT'),
	APPROVED_BY VARCHAR(50),
	APPROVED_AT BIGINT,
    UPDATED_AT BIGINT,
	
	MODULE_ID VARCHAR(36),
    FOREIGN KEY(MODULE_ID) REFERENCES ELECTION_MODULE(ID) ON UPDATE CASCADE ON DELETE RESTRICT
)ENGINE=INNODB;

-- defines all module configs required
CREATE TABLE IF NOT EXISTS ELECTION_MODULE_CONFIG(
    ID VARCHAR(36) PRIMARY KEY,
    KEY_NAME VARCHAR(50),
    DESCRIPTION VARCHAR(100)
)ENGINE=INNODB;

-- keep values for defined module configs
CREATE TABLE IF NOT EXISTS ELECTION_MODULE_CONFIG_DATA(
	VALUE VARCHAR(100) NOT NULL,
	
	ELECTION_MODULE_CONFIG_ID VARCHAR(36),
	FOREIGN KEY(ELECTION_MODULE_CONFIG_ID) REFERENCES ELECTION_MODULE_CONFIG(ID) ON UPDATE CASCADE ON DELETE RESTRICT,
	
	MODULE_ID VARCHAR(36),
	FOREIGN KEY(MODULE_ID) REFERENCES ELECTION_MODULE(ID) ON UPDATE CASCADE ON DELETE RESTRICT,
	
	PRIMARY KEY(ELECTION_MODULE_CONFIG_ID, MODULE_ID)
)ENGINE=INNODB;

-- where you store all eligibity criteria of nominations
CREATE TABLE IF NOT EXISTS ELIGIBILITY_CONFIG(
    ID VARCHAR(36) PRIMARY KEY,
    DESCRIPTION TEXT NOT NULL,
    
    MODULE_ID VARCHAR(36),
    FOREIGN KEY(MODULE_ID) REFERENCES ELECTION_MODULE(ID) ON UPDATE CASCADE ON DELETE RESTRICT
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS SUPPORT_DOC_CONFIG(
	ID VARCHAR(36) PRIMARY KEY,
	KEY_NAME VARCHAR(50) NOT NULL, /* eg: 'NIC', 'Birth Certificate' */
	DESCRIPTION VARCHAR(100),
	DOC_CATEGORY ENUM('NOMINATION', 'CANDIDATE', 'OBJECTION')
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS SUPPORT_DOC_CONFIG_DATA(	
	SUPPORT_DOC_CONFIG_ID VARCHAR(36),
	FOREIGN KEY (SUPPORT_DOC_CONFIG_ID) REFERENCES SUPPORT_DOC_CONFIG(ID) ON UPDATE CASCADE ON DELETE RESTRICT,
	
	MODULE_ID VARCHAR(36),
    FOREIGN KEY(MODULE_ID) REFERENCES ELECTION_MODULE(ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    
	SELECT_FLAG BOOLEAN,
    
    PRIMARY KEY(SUPPORT_DOC_CONFIG_ID, MODULE_ID)
)ENGINE=INNODB;




--
-- ELECTION 
--

CREATE TABLE IF NOT EXISTS ELECTION(
    ID VARCHAR(36) PRIMARY KEY,
    NAME VARCHAR(100) NOT NULL,
	CREATED_BY VARCHAR(50),
    CREATED_AT BIGINT,
    UPDATED_AT BIGINT,
    
    MODULE_ID VARCHAR(36),
    FOREIGN KEY(MODULE_ID) REFERENCES ELECTION_MODULE(ID) ON UPDATE CASCADE ON DELETE RESTRICT
)ENGINE=INNODB;

-- defines all election configs required
CREATE TABLE IF NOT EXISTS ELECTION_CONFIG(
    ID VARCHAR(36) PRIMARY KEY,
    KEY_NAME VARCHAR(50),
    DESCRIPTION VARCHAR(100)
)ENGINE=INNODB;

-- keep values for defined election configs
CREATE TABLE IF NOT EXISTS ELECTION_CONFIG_DATA(
	VALUE VARCHAR(100) NOT NULL,
	
	ELECTION_CONFIG_ID VARCHAR(36),
	FOREIGN KEY(ELECTION_CONFIG_ID) REFERENCES ELECTION_CONFIG(ID) ON UPDATE CASCADE ON DELETE RESTRICT,
	
	ELECTION_ID VARCHAR(36),
	FOREIGN KEY(ELECTION_ID) REFERENCES ELECTION(ID) ON UPDATE CASCADE ON DELETE RESTRICT,
	
	PRIMARY KEY(ELECTION_CONFIG_ID, ELECTION_ID)
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS ELECTION_TIMELINE_CONFIG(
	ID VARCHAR(36) PRIMARY KEY,
	KEY_NAME VARCHAR(50) NOT NULL,
	DESCRIPTION VARCHAR(100)
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS ELECTION_TIMELINE_CONFIG_DATA(
	ELECTION_TIMELINE_CONFIG_ID VARCHAR(36),
	FOREIGN KEY (ELECTION_TIMELINE_CONFIG_ID) REFERENCES ELECTION_TIMELINE_CONFIG(ID) ON UPDATE CASCADE ON DELETE RESTRICT,
	
	ELECTION_ID VARCHAR(36),
	FOREIGN KEY(ELECTION_ID) REFERENCES ELECTION(ID) ON UPDATE CASCADE ON DELETE RESTRICT,
	
	VALUE BIGINT,
	PRIMARY KEY(ELECTION_TIMELINE_CONFIG_ID, ELECTION_ID)
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS ELECTION_APPROVAL(
	ID VARCHAR(36) PRIMARY KEY,
	STATUS ENUM('PENDING','APPROVE','REJECT'),
	APPROVED_BY VARCHAR(50),
	APPROVED_AT BIGINT,
    UPDATED_AT BIGINT,
	
	ELECTION_ID VARCHAR(36),
	FOREIGN KEY(ELECTION_ID) REFERENCES ELECTION(ID) ON UPDATE CASCADE ON DELETE RESTRICT
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS ELECTION_TEAM(
	ID VARCHAR(36) PRIMARY KEY,
	
	TEAM_ID VARCHAR(36),
	
	ELECTION_ID VARCHAR(36),
	FOREIGN KEY(ELECTION_ID) REFERENCES ELECTION(ID) ON UPDATE CASCADE ON DELETE RESTRICT
)ENGINE=INNODB;





-- 
-- DIVISION DATA
-- 

CREATE TABLE IF NOT EXISTS DIVISION_CONFIG(
	ID VARCHAR(36) PRIMARY KEY,
	NAME VARCHAR(100) NOT NULL,
	CODE VARCHAR(10) NOT NULL,
	NO_OF_CANDIDATES INT(5) NOT NULL,
	
	MODULE_ID VARCHAR(36),
    FOREIGN KEY(MODULE_ID) REFERENCES ELECTION_MODULE(ID) ON UPDATE CASCADE ON DELETE RESTRICT
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS DIVISION_CONFIG_DATA(
	ELECTION_ID VARCHAR(36),
	FOREIGN KEY(ELECTION_ID) REFERENCES ELECTION(ID) ON UPDATE CASCADE ON DELETE RESTRICT,
	
	DIVISION_CONFIG_ID VARCHAR(36),
	FOREIGN KEY (DIVISION_CONFIG_ID) REFERENCES DIVISION_CONFIG(ID) ON UPDATE CASCADE ON DELETE RESTRICT,
	
	SELECT_FLAG BOOLEAN,
	
	PRIMARY KEY(ELECTION_ID, DIVISION_CONFIG_ID)
)ENGINE=INNODB;




-- 
-- NOMINATION 
-- 

CREATE TABLE IF NOT EXISTS NOMINATION(
    ID VARCHAR(36) PRIMARY KEY,
    STATUS ENUM('DRAFT','SUBMIT'),
    
    TEAM_ID VARCHAR(36),
    
    CREATED_BY VARCHAR(50),
    CREATED_AT BIGINT,
    UPDATED_AT BIGINT,
    
    ELECTION_ID VARCHAR(36) NOT NULL,
    FOREIGN KEY (ELECTION_ID) REFERENCES ELECTION(ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    
    DIVISION_CONFIG_ID VARCHAR(36),
    FOREIGN KEY (DIVISION_CONFIG_ID) REFERENCES DIVISION_CONFIG(ID) ON UPDATE CASCADE ON DELETE RESTRICT
    
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS NOMINATION_SUPPORT_DOC(
    ID VARCHAR(36) PRIMARY KEY,
	FILE_PATH VARCHAR(200),
	
	SUPPORT_DOC_CONFIG_ID VARCHAR(36),
	FOREIGN KEY (SUPPORT_DOC_CONFIG_ID) REFERENCES SUPPORT_DOC_CONFIG(ID) ON UPDATE CASCADE ON DELETE RESTRICT,
	
	NOMINATION_ID VARCHAR(36),
    FOREIGN KEY (NOMINATION_ID) REFERENCES NOMINATION(ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    
	STATUS ENUM('NEW','DELETE') DEFAULT 'NEW'
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS NOMINATION_APPROVAL(
	ID VARCHAR(36) PRIMARY KEY,
	APPROVED_BY VARCHAR(50),
	APPROVED_AT BIGINT,
	UPDATED_AT BIGINT,
	STATUS ENUM('1ST-APPROVE', '2ND-APPROVE','REJECT'),
	REVIEW_NOTE TEXT,
	
	NOMINATION_ID VARCHAR(36),
    FOREIGN KEY (NOMINATION_ID) REFERENCES NOMINATION(ID) ON UPDATE CASCADE ON DELETE RESTRICT
)ENGINE=INNODB;


CREATE TABLE IF NOT EXISTS OBJECTION(
    ID VARCHAR(36) PRIMARY KEY,
    DESCRIPTION TEXT,
    CREATED_AT BIGINT,
    CREATED_BY VARCHAR(100),
    CREATED_BY_TEAM_ID VARCHAR(36),
    
    NOMINATION_ID VARCHAR(36),
    FOREIGN KEY (NOMINATION_ID) REFERENCES NOMINATION(ID) ON UPDATE CASCADE ON DELETE RESTRICT
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS OBJECTION_REVIEW(
	ID VARCHAR(36) PRIMARY KEY,
	CREATED_BY VARCHAR(100), /* plans is store use logged user id */
	CREATED_AT BIGINT,
	NOTE TEXT,
	
	OBJECTION_ID VARCHAR(36),
    FOREIGN KEY (OBJECTION_ID) REFERENCES OBJECTION(ID) ON UPDATE CASCADE ON DELETE RESTRICT
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS OBJECTION_SUPPORT_DOC(
    ID VARCHAR(36) PRIMARY KEY,
    FILE_PATH VARCHAR(300),
    
    SUPPORT_DOC_CONFIG_ID VARCHAR(36),
	FOREIGN KEY (SUPPORT_DOC_CONFIG_ID) REFERENCES SUPPORT_DOC_CONFIG(ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    
    OBJECTION_ID VARCHAR(36),
    FOREIGN KEY (OBJECTION_ID) REFERENCES OBJECTION(ID) ON UPDATE CASCADE ON DELETE RESTRICT
)ENGINE=INNODB;

-- payment for nomination
CREATE TABLE IF NOT EXISTS PAYMENT(
    ID VARCHAR(36) PRIMARY KEY,
    DEPOSITOR VARCHAR(100),
    DEPOSIT_DATE BIGINT,
    AMOUNT DECIMAL(13,4),
    FILE_PATH VARCHAR(300),
    STATUS ENUM('PENDING','RECEIVED'),
    NOTE TEXT,
    
    CREATED_BY VARCHAR(50),
    CREATED_AT BIGINT,
    UPDATED_AT BIGINT,
    
    NOMINATION_ID VARCHAR(36),
    FOREIGN KEY (NOMINATION_ID) REFERENCES NOMINATION(ID) ON UPDATE CASCADE ON DELETE RESTRICT
)ENGINE=INNODB;






-- 
-- CANDIDATE 
-- 

CREATE TABLE IF NOT EXISTS CANDIDATE(
    ID VARCHAR(36) PRIMARY KEY,
    FULL_NAME VARCHAR(200),
    PREFERRED_NAME VARCHAR(50),
    NIC VARCHAR(15),
    DATE_OF_BIRTH BIGINT,
    GENDER VARCHAR(6),
    ADDRESS VARCHAR(300),
    OCCUPATION VARCHAR(20),
    ELECTORAL_DIVISION_NAME VARCHAR(50),
    ELECTORAL_DIVISION_CODE VARCHAR(10),
    COUNSIL_NAME VARCHAR(20),
    
    NOMINATION_ID VARCHAR(36),
    FOREIGN KEY(NOMINATION_ID) REFERENCES NOMINATION(ID) ON UPDATE CASCADE ON DELETE RESTRICT
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS CANDIDATE_CONFIG(
    ID VARCHAR(36) PRIMARY KEY,
    FULL_NAME BOOLEAN,
    PREFERRED_NAME BOOLEAN,
    NIC BOOLEAN,
    DATE_OF_BIRTH BOOLEAN,
    GENDER BOOLEAN,
    ADDRESS BOOLEAN,
    OCCUPATION BOOLEAN,
    ELECTORAL_DIVISION_NAME BOOLEAN,
    ELECTORAL_DIVISION_CODE BOOLEAN,
    COUNSIL_NAME BOOLEAN,
    
    MODULE_ID VARCHAR(36),
    FOREIGN KEY (MODULE_ID) REFERENCES ELECTION_MODULE(ID) ON UPDATE CASCADE ON DELETE RESTRICT
)ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS CANDIDATE_SUPPORT_DOC(
    ID VARCHAR(36) PRIMARY KEY,
	FILE_PATH VARCHAR(200),
	
	SUPPORT_DOC_CONFIG_ID VARCHAR(36),
	FOREIGN KEY (SUPPORT_DOC_CONFIG_ID) REFERENCES SUPPORT_DOC_CONFIG(ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    
    CANDIDATE_ID VARCHAR(36),
    FOREIGN KEY(CANDIDATE_ID) REFERENCES CANDIDATE(ID) ON UPDATE CASCADE ON DELETE RESTRICT
)ENGINE=INNODB;







-- 
-- Table structure fsor table `USER`
-- 

DROP TABLE IF EXISTS `USER`;

CREATE TABLE `USER` (
  `ID` VARCHAR(36) NOT NULL,
  `NAME` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`ID`)
)ENGINE=INNODB;

INSERT INTO USER VALUES ('123', 'CLEMENT');





-- 
-- EC-NOMINATION DATA DUMP FOR V2.7.0
-- 

-- USE EC_NOMINATION;


-- 
-- ELECTION MODULE 
-- 

INSERT INTO ELECTION_MODULE 
	(ID, NAME, DIVISION_COMMON_NAME, CREATED_BY, CREATED_AT, UPDATED_AT)	/* eg value: 'district', 'province' */
VALUES 
('455cd89e-269b-4b69-96ce-8d7c7bf44ac2', 'parliamentary', 'DISTRICT', 'admin-user-1', 1546713528, 1546713528),
('7404a229-6274-43d0-b3c5-740c3c2e1256', 'presidential', 'ALL', 'admin-user-1', 1546713528, 1546713528),
('27757873-ed40-49f7-947b-48b432a1b062', 'provincial', 'PROVINCE', 'admin-user-1', 1546713528, 1546713528);

INSERT INTO ELECTION_MODULE_APPROVAL
	(ID, STATUS, APPROVED_BY, APPROVED_AT, UPDATED_AT, MODULE_ID)
VALUES
('77baf5c9-7fb7-424d-ab07-9fff2dfa9f2c', 'APPROVE', 'admin-user-2', 1546713528, 1546713528, '455cd89e-269b-4b69-96ce-8d7c7bf44ac2'),
('27e4bf42-927b-4c88-8ae0-825741ddda4e', 'PENDING', 'admin-user-2', 1546713528, 1546713528, '7404a229-6274-43d0-b3c5-740c3c2e1256'),
('354ee027-093b-412d-becc-be9b354eddcc', 'APPROVE', 'admin-user-2', 1546713528, 1546713528, '27757873-ed40-49f7-947b-48b432a1b062');


INSERT INTO SUPPORT_DOC_CONFIG
	(ID, KEY_NAME, DESCRIPTION, DOC_CATEGORY)
VALUES
('59f4d9df-006b-4d7c-82dc-736041e97f37', 'Objection Support Document', 'Submit any type of document related to objection', 'OBJECTION'),
('b20dd58c-e5bb-469d-98c9-8711d6da1879', 'Nomination Form', 'Nomination form with signature', 'NOMINATION'),
('3fac66f2-302c-4d27-b9ae-1d004037a9ba', 'Female Declaration Form', 'Declaration form that denotes the precentage of female representation for the nomination', 'NOMINATION'),
('fe2c2d7e-66de-406a-b887-1143023f8e72', 'NIC', 'National Identification Card', 'CANDIDATE'),
('ff4c6768-bdbe-4a16-b680-5fecb6b1f747', 'Birth Certificate', 'Birth Certification', 'CANDIDATE'),
('15990459-2ea4-413f-b1f7-29a138fd7a97', 'Affidavit', 'Affidavit', 'CANDIDATE');

INSERT INTO SUPPORT_DOC_CONFIG_DATA
	(SUPPORT_DOC_CONFIG_ID, MODULE_ID, SELECT_FLAG)
VALUES
('59f4d9df-006b-4d7c-82dc-736041e97f37', '455cd89e-269b-4b69-96ce-8d7c7bf44ac2', TRUE),
('b20dd58c-e5bb-469d-98c9-8711d6da1879', '455cd89e-269b-4b69-96ce-8d7c7bf44ac2', TRUE), -- Nomination - nomination form
('3fac66f2-302c-4d27-b9ae-1d004037a9ba', '455cd89e-269b-4b69-96ce-8d7c7bf44ac2', TRUE), -- Nomination - female declaration form
('fe2c2d7e-66de-406a-b887-1143023f8e72', '455cd89e-269b-4b69-96ce-8d7c7bf44ac2', TRUE),
('ff4c6768-bdbe-4a16-b680-5fecb6b1f747', '455cd89e-269b-4b69-96ce-8d7c7bf44ac2', TRUE),
('15990459-2ea4-413f-b1f7-29a138fd7a97', '455cd89e-269b-4b69-96ce-8d7c7bf44ac2', TRUE);


-- 
-- ELECTION
-- 

INSERT INTO ELECTION 
	(ID, NAME, MODULE_ID, CREATED_BY, CREATED_AT, UPDATED_AT) 
VALUES 
-- parliamentary
('43680f3e-97ac-4257-b27a-5f3b452da2e6', 'Parliamentary Election 2019', '455cd89e-269b-4b69-96ce-8d7c7bf44ac2', 'admin-user-1', 1546713528, 1546713528),

-- presidentail
('9b85a650-709e-4cdc-83e1-ba4a2ad97cbc', 'Presidentail Election 2020', '7404a229-6274-43d0-b3c5-740c3c2e1256', 'admin-user-1', 1546713528, 1546713528),

-- provincial
('293d67ea-5898-436d-90d9-27177387be6a', 'Provincial Election 2019', '27757873-ed40-49f7-947b-48b432a1b062', 'admin-user-1', 1546713528, 1546713528);

INSERT INTO ELECTION_APPROVAL 
	(ID, STATUS, APPROVED_BY, APPROVED_AT, UPDATED_AT, ELECTION_ID) 
VALUES
('43242b3b-ff26-483e-8f8b-a62742882c44', 'PENDING', 'admin-user-1', 1546713528, 1546713528, '9b85a650-709e-4cdc-83e1-ba4a2ad97cbc'),
('520d60d5-6f16-47be-b938-8497aafa415f', 'APPROVE', 'admin-user-1', 1546713528, 1546713528, '43680f3e-97ac-4257-b27a-5f3b452da2e6'),
('6d6ead0a-135c-4eec-b379-a9d4561e0af3', 'PENDING', 'admin-user-1', 1544400000, 1544400000, '293d67ea-5898-436d-90d9-27177387be6a'),
('7764fcbd-55b7-428f-860d-44f75d93cbf6', 'PENDING', 'admin-user-1', 1548394625, 1548394625, '43680f3e-97ac-4257-b27a-5f3b452da2e6'),
('c4f3dfd0-e73d-4b49-bc06-386d9967bb39', 'APPROVE', 'admin-user-1', 1546713528, 1546713528, '293d67ea-5898-436d-90d9-27177387be6a');


INSERT INTO ELECTION_CONFIG 
	(ID, KEY_NAME, DESCRIPTION) 
VALUES
('21e1f616-52f7-41ef-b0a0-efdd86df6939', 'Payment amount per nominee (LKR)', 'Payment amount per nominee (LKR)'),
('d89f5fd5-6270-49e2-a553-7f2065996c77', 'Weightage (%) vote-based', 'Weightage (%) vote-based'),
('ddd7a12c-283b-45d3-a17b-45497d9cec8d', 'Weightage (%) preference-based', 'Weightage (%) preference-based');

INSERT INTO ELECTION_CONFIG_DATA 
	(VALUE, ELECTION_CONFIG_ID, ELECTION_ID) 
VALUES
('2000.00', '21e1f616-52f7-41ef-b0a0-efdd86df6939', '43680f3e-97ac-4257-b27a-5f3b452da2e6'),
('75', 'd89f5fd5-6270-49e2-a553-7f2065996c77', '43680f3e-97ac-4257-b27a-5f3b452da2e6'),
('25', 'ddd7a12c-283b-45d3-a17b-45497d9cec8d', '43680f3e-97ac-4257-b27a-5f3b452da2e6');



INSERT INTO ELECTION_TIMELINE_CONFIG 
	(ID, KEY_NAME, DESCRIPTION)
VALUES 
('0f62755e-9784-4046-9804-8d4deed36f2a', 'nomination_start_date', 'Start date of Nomination in UNIX TIMESTAMP'),
('c06a789c-405c-4e7a-8df2-66766284589b','nomination_end_date', 'End date of Nomination in UNIX TIMESTAMP'),
('675ec08b-2937-4222-94a6-0143a94763f1', 'objection_start_date', 'Start date of Objection in UNIX TIMESTAMP'),
('64ae3e95-591a-4bf9-8a5b-10803e0eca82','objection_end_date', 'End date of Objection in UNIX TIMESTAMP');

INSERT INTO ELECTION_TIMELINE_CONFIG_DATA 
	(ELECTION_TIMELINE_CONFIG_ID, ELECTION_ID, VALUE)
VALUES
-- parliamentary '43680f3e-97ac-4257-b27a-5f3b452da2e6'
('0f62755e-9784-4046-9804-8d4deed36f2a', '43680f3e-97ac-4257-b27a-5f3b452da2e6', 1546713528),
('c06a789c-405c-4e7a-8df2-66766284589b', '43680f3e-97ac-4257-b27a-5f3b452da2e6', 1548873528),
('675ec08b-2937-4222-94a6-0143a94763f1', '43680f3e-97ac-4257-b27a-5f3b452da2e6', 1549046328),
('64ae3e95-591a-4bf9-8a5b-10803e0eca82', '43680f3e-97ac-4257-b27a-5f3b452da2e6', 1550255928),

-- presidential '9b85a650-709e-4cdc-83e1-ba4a2ad97cbc'
('0f62755e-9784-4046-9804-8d4deed36f2a', '9b85a650-709e-4cdc-83e1-ba4a2ad97cbc', 1581791928),
('c06a789c-405c-4e7a-8df2-66766284589b', '9b85a650-709e-4cdc-83e1-ba4a2ad97cbc', 1585593528),
('675ec08b-2937-4222-94a6-0143a94763f1', '9b85a650-709e-4cdc-83e1-ba4a2ad97cbc', 1585766328),
('64ae3e95-591a-4bf9-8a5b-10803e0eca82', '9b85a650-709e-4cdc-83e1-ba4a2ad97cbc', 1586975928);


-- 
-- DIVISION
-- 

INSERT INTO DIVISION_CONFIG 
	(ID, NAME, CODE, NO_OF_CANDIDATES, MODULE_ID) 
VALUES
-- divisions for parliamentary ('455cd89e-269b-4b69-96ce-8d7c7bf44ac2') therefore all possible districts available here..
('65fa860e-2928-4602-9b1e-2a7cb09ea83e', 'Colombo', '1', 22, '455cd89e-269b-4b69-96ce-8d7c7bf44ac2'),
('21b9752f-8641-40c3-8205-39a612bf5244', 'Gampaha', '2', 21, '455cd89e-269b-4b69-96ce-8d7c7bf44ac2'),
('c9c710e6-cf9c-496c-9b53-2fce36598ea1', 'Kaluthara', '3', 13, '455cd89e-269b-4b69-96ce-8d7c7bf44ac2'),
('f15ae97b-8e95-4f38-93d9-fb97fabdcf22', 'Kandy', '4', 15, '455cd89e-269b-4b69-96ce-8d7c7bf44ac2'),
('3ab3cf77-a468-41a8-821a-8aa6f38222ad', 'Matale', '5', 08, '455cd89e-269b-4b69-96ce-8d7c7bf44ac2'),
('437bd796-597f-4d9e-9b09-874ecded15bf', 'Nuwaraeliya', '6', 11, '455cd89e-269b-4b69-96ce-8d7c7bf44ac2'),
('44424777-9888-44cb-90ed-f4742e687ca6', 'Galle', '7', 13, '455cd89e-269b-4b69-96ce-8d7c7bf44ac2'),
('e6af28f3-c12e-4202-bc4a-883895db0c4d', 'Matara', '8', 10, '455cd89e-269b-4b69-96ce-8d7c7bf44ac2'),
('ea950ed0-525a-4f6e-bb7a-478e36983d90', 'Hambantota', '9', 10, '455cd89e-269b-4b69-96ce-8d7c7bf44ac2'),
('7740f20e-363f-4e10-bc1f-a67d2b9cfecd', 'Jaffna', '10', 10, '455cd89e-269b-4b69-96ce-8d7c7bf44ac2'),
('561f4c0b-e278-496d-a740-f1dd7c1f4f70', 'Vanni', '11', 09, '455cd89e-269b-4b69-96ce-8d7c7bf44ac2'),
('9c1e3ae2-c78b-4f03-8b0c-8d636a36589f', 'Batticaloa', '12', 08, '455cd89e-269b-4b69-96ce-8d7c7bf44ac2'),
('682a2b2c-3d78-4fe7-8c25-4c04a7f75328', 'Digamulla', '13', 10, '455cd89e-269b-4b69-96ce-8d7c7bf44ac2'),
('1a29913e-3bc4-4a48-a35e-88f8a874e623', 'Trincomalee', '14', 07, '455cd89e-269b-4b69-96ce-8d7c7bf44ac2'),
('6541f00c-abf6-4f26-a8b0-a46599fceaeb', 'Kurunegala', '15', 18, '455cd89e-269b-4b69-96ce-8d7c7bf44ac2'),
('5aa87f72-90c5-4a4d-8160-be750b15ed7b', 'Puttalam', '16', 11, '455cd89e-269b-4b69-96ce-8d7c7bf44ac2'),
('4875b722-fa52-4a6f-a339-ed2fdf86fbcb', 'Anuradhapura', '17', 12, '455cd89e-269b-4b69-96ce-8d7c7bf44ac2'),
('bf6d8e67-bb79-41c6-8647-1424ef4d6103', 'Polonnaruwa', '18', 08, '455cd89e-269b-4b69-96ce-8d7c7bf44ac2'),
('16ab500d-31b1-4176-bfa3-42e766e9d691', 'Badulla', '19', 11, '455cd89e-269b-4b69-96ce-8d7c7bf44ac2'),
('482ddfa5-b6d3-4701-8f17-2e92f9e02774', 'Monaragala', '20', 09, '455cd89e-269b-4b69-96ce-8d7c7bf44ac2'),
('9c2a87ca-1a5e-425b-9965-a2b7e469f647', 'Ratnapura', '21', 14, '455cd89e-269b-4b69-96ce-8d7c7bf44ac2'),
('f0cbfece-4c96-44ac-b493-f10a45753229', 'Kegalle', '22', 12, '455cd89e-269b-4b69-96ce-8d7c7bf44ac2'),

-- divisions for presidential module ('7404a229-6274-43d0-b3c5-740c3c2e1256') therefore there will be only one division as 'all-island'
('f04e4732-83c3-4444-a706-78b3928afd33', 'Island-wide', '00A', 1, '7404a229-6274-43d0-b3c5-740c3c2e1256');

INSERT INTO DIVISION_CONFIG_DATA
	(ELECTION_ID, DIVISION_CONFIG_ID, SELECT_FLAG)
VALUES
-- division approval for 'Parliamentary Election 2019' 
('43680f3e-97ac-4257-b27a-5f3b452da2e6', '65fa860e-2928-4602-9b1e-2a7cb09ea83e', TRUE),
('43680f3e-97ac-4257-b27a-5f3b452da2e6', '21b9752f-8641-40c3-8205-39a612bf5244', TRUE),
('43680f3e-97ac-4257-b27a-5f3b452da2e6', 'c9c710e6-cf9c-496c-9b53-2fce36598ea1', TRUE),
('43680f3e-97ac-4257-b27a-5f3b452da2e6', 'f15ae97b-8e95-4f38-93d9-fb97fabdcf22', TRUE),
('43680f3e-97ac-4257-b27a-5f3b452da2e6', '44424777-9888-44cb-90ed-f4742e687ca6', TRUE),
('43680f3e-97ac-4257-b27a-5f3b452da2e6', '7740f20e-363f-4e10-bc1f-a67d2b9cfecd', TRUE),
('43680f3e-97ac-4257-b27a-5f3b452da2e6', '9c1e3ae2-c78b-4f03-8b0c-8d636a36589f', TRUE),
('43680f3e-97ac-4257-b27a-5f3b452da2e6', '1a29913e-3bc4-4a48-a35e-88f8a874e623', TRUE),
('43680f3e-97ac-4257-b27a-5f3b452da2e6', '16ab500d-31b1-4176-bfa3-42e766e9d691', TRUE),
('43680f3e-97ac-4257-b27a-5f3b452da2e6', 'f0cbfece-4c96-44ac-b493-f10a45753229', FALSE),
('43680f3e-97ac-4257-b27a-5f3b452da2e6', 'ea950ed0-525a-4f6e-bb7a-478e36983d90', FALSE),

-- division approval for 'Presidentail Election 2020'
('9b85a650-709e-4cdc-83e1-ba4a2ad97cbc', 'f04e4732-83c3-4444-a706-78b3928afd33', TRUE);




-- 
-- NOMINATION 
-- 

INSERT INTO NOMINATION
	(ID, STATUS, TEAM_ID, ELECTION_ID, DIVISION_CONFIG_ID)
VALUES

-- nominations for parlimentary election and team ('5eedb70e-a4da-48e0-b971-e06cd19ecc70')
('135183e2-a0ca-44a0-9577-0d2b16c3217f', 'SUBMIT', '5eedb70e-a4da-48e0-b971-e06cd19ecc70', '43680f3e-97ac-4257-b27a-5f3b452da2e6', '65fa860e-2928-4602-9b1e-2a7cb09ea83e'),
('416e0c20-b274-4cf2-9531-8167d2f35bf7', 'DRAFT', '5eedb70e-a4da-48e0-b971-e06cd19ecc70', '43680f3e-97ac-4257-b27a-5f3b452da2e6', '21b9752f-8641-40c3-8205-39a612bf5244'),
('a0e4a9c9-4841-45df-9600-f7a607400ab6', 'SUBMIT', '5eedb70e-a4da-48e0-b971-e06cd19ecc70', '43680f3e-97ac-4257-b27a-5f3b452da2e6', 'c9c710e6-cf9c-496c-9b53-2fce36598ea1'),
('ed7e455c-eb95-4ccc-b090-32c1616c6d0c', 'SUBMIT', '5eedb70e-a4da-48e0-b971-e06cd19ecc70', '43680f3e-97ac-4257-b27a-5f3b452da2e6', 'f15ae97b-8e95-4f38-93d9-fb97fabdcf22'),
('c1313d6d-bac3-48f6-afd7-ce7899f1714a', 'SUBMIT', '5eedb70e-a4da-48e0-b971-e06cd19ecc70', '43680f3e-97ac-4257-b27a-5f3b452da2e6', '7740f20e-363f-4e10-bc1f-a67d2b9cfecd'),
('07d4d5d9-fd83-473f-836c-a5a565d75ed1', 'SUBMIT', '5eedb70e-a4da-48e0-b971-e06cd19ecc70', '43680f3e-97ac-4257-b27a-5f3b452da2e6', '1a29913e-3bc4-4a48-a35e-88f8a874e623'),

('358f0d3c-5632-4046-9abb-f0aeab5bfe9e', 'SUBMIT', '62fcdfa7-3c5a-405f-b344-79089131dd8e', '43680f3e-97ac-4257-b27a-5f3b452da2e6', '16ab500d-31b1-4176-bfa3-42e766e9d691'),
('f3ed108c-0c01-4115-8f1f-4f9a56c53323', 'SUBMIT', '62fcdfa7-3c5a-405f-b344-79089131dd8e', '43680f3e-97ac-4257-b27a-5f3b452da2e6', '1a29913e-3bc4-4a48-a35e-88f8a874e623'),
('aa64b16f-5881-4bb8-9b92-abb66d05b88b', 'DRAFT', '62fcdfa7-3c5a-405f-b344-79089131dd8e', '43680f3e-97ac-4257-b27a-5f3b452da2e6', '7740f20e-363f-4e10-bc1f-a67d2b9cfecd'),

-- nominations for presidential election and 2 teams
('6fb66fbb-acd2-4b2e-94ac-12bee6468f5f', 'SUBMIT', '5eedb70e-a4da-48e0-b971-e06cd19ecc70', '9b85a650-709e-4cdc-83e1-ba4a2ad97cbc', 'f04e4732-83c3-4444-a706-78b3928afd33'),
('ad78d32d-dd5a-41ac-a410-aa8500c04102', 'SUBMIT', '5eedb70e-a4da-48e0-b971-e06cd19ecc70', '9b85a650-709e-4cdc-83e1-ba4a2ad97cbc', 'f04e4732-83c3-4444-a706-78b3928afd33'),

('7db3d4ba-c8a0-4340-8d6e-2d9096de7d2e', 'DRAFT', '62fcdfa7-3c5a-405f-b344-79089131dd8e', '9b85a650-709e-4cdc-83e1-ba4a2ad97cbc', 'f04e4732-83c3-4444-a706-78b3928afd33');


INSERT INTO NOMINATION_APPROVAL
	(ID, APPROVED_BY, APPROVED_AT, UPDATED_AT, STATUS, REVIEW_NOTE, NOMINATION_ID)
VALUES
('2e0913ba-4c24-4e72-ab9d-6fa3f33a9f2e', 'admin-user-1', 1550342328, 1550342328, '1ST-APPROVE', 'this is review note', '135183e2-a0ca-44a0-9577-0d2b16c3217f'),
('ff59b053-0ef9-49f1-b8cf-d831bb115a89', 'admin-user-1', 1550342328, 1550342328, '1ST-APPROVE', 'this is review note', '416e0c20-b274-4cf2-9531-8167d2f35bf7'),
('3ec4ed76-0783-48f9-ac53-a4b4a8c313c8', 'admin-user-1', 1550342328, 1550342328, '1ST-APPROVE', 'this is review note', 'a0e4a9c9-4841-45df-9600-f7a607400ab6'),
('0948ed2a-c84f-4652-8a5f-52ef75a624a5', 'admin-user-1', 1550342328, 1550342328, '1ST-APPROVE', 'this is review note', '358f0d3c-5632-4046-9abb-f0aeab5bfe9e'),
('5514a274-bb2b-46d8-afc0-51d119c61217', 'admin-user-1', 1550342328, 1550342328, '2ND-APPROVE', 'this is review note', '135183e2-a0ca-44a0-9577-0d2b16c3217f'),
('5e23632b-7de7-4acb-be32-fb2399e14367', 'admin-user-1', 1550342328, 1550342328, '2ND-APPROVE', 'this is review note', '358f0d3c-5632-4046-9abb-f0aeab5bfe9e');


INSERT INTO NOMINATION_SUPPORT_DOC
	(ID, FILE_PATH, SUPPORT_DOC_CONFIG_ID, NOMINATION_ID, STATUS)
VALUES
('5b8aff7b-44e6-43fe-8254-ba81c5d94129', 'url/resource/to/file/server/file1.pdf', 'b20dd58c-e5bb-469d-98c9-8711d6da1879', '135183e2-a0ca-44a0-9577-0d2b16c3217f', 'NEW'),
('32a82ec0-f60c-49a3-9fa7-c971903d230e', 'url/resource/to/file/server/file2.pdf', '3fac66f2-302c-4d27-b9ae-1d004037a9ba', '135183e2-a0ca-44a0-9577-0d2b16c3217f', 'NEW');



-- 
-- OBJECTION
-- 

INSERT INTO OBJECTION
	(ID, DESCRIPTION, CREATED_AT, CREATED_BY, CREATED_BY_TEAM_ID, NOMINATION_ID)
VALUES
-- objections for praliamentary election nominations
('417c0d5d-d417-4333-b334-56d40f725c8a', 'Objection Description 1', 1550342328, 'UsernameFromIS-1', '62fcdfa7-3c5a-405f-b344-79089131dd8e', '135183e2-a0ca-44a0-9577-0d2b16c3217f'),
('1ecbc3f5-7802-483b-9ff4-61dd4cbc7e91', 'Objection Description 2', 1550428728, 'UsernameFromIS-1', '62fcdfa7-3c5a-405f-b344-79089131dd8e', 'a0e4a9c9-4841-45df-9600-f7a607400ab6'),
('36f6062e-356a-4d14-84c6-2da68c962287', 'Objection Description 3', 1587148728, 'UsernameFromIS-3', '5eedb70e-a4da-48e0-b971-e06cd19ecc70', '358f0d3c-5632-4046-9abb-f0aeab5bfe9e'),
('e0093c7d-8636-4467-931c-1fbc4f2053b8', 'Objection Description 5', 1550428728, 'UsernameFromIS-1', '62fcdfa7-3c5a-405f-b344-79089131dd8e', 'ed7e455c-eb95-4ccc-b090-32c1616c6d0c'),

-- objections for presidential election nominations
('4ebac898-0e6f-11e9-ab14-d663bd873d93', 'Objection Description 4', 1550428728, 'UsernameFromIS-1', '62fcdfa7-3c5a-405f-b344-79089131dd8e', 'ad78d32d-dd5a-41ac-a410-aa8500c04102'),
('27a74411-ed86-484b-9904-7146183135dc', 'Objection Description 6', 1587235128, 'UsernameFromIS-4', '5eedb70e-a4da-48e0-b971-e06cd19ecc70', '7db3d4ba-c8a0-4340-8d6e-2d9096de7d2e');

INSERT INTO OBJECTION_REVIEW
	(ID, CREATED_BY, CREATED_AT, NOTE, OBJECTION_ID)
VALUES
('2f3ea8b3-a21e-497f-ab91-8e9eafdcd922', 'UsernameFromIS-EC-Admin1', 1550428728, 'this is a review note.', '417c0d5d-d417-4333-b334-56d40f725c8a' ),
('7048cc45-6dab-44aa-818f-5030a93daa26', 'UsernameFromIS-EC-Admin1', 1550428728, 'this is a review note.', '1ecbc3f5-7802-483b-9ff4-61dd4cbc7e91' );

INSERT INTO OBJECTION_SUPPORT_DOC
	(ID, FILE_PATH, SUPPORT_DOC_CONFIG_ID, OBJECTION_ID)
VALUES
('999af464-ac5a-4b48-bdbc-fcea2840bf5b', 'url/resource/to/file/server/file1.pdf', '59f4d9df-006b-4d7c-82dc-736041e97f37', '417c0d5d-d417-4333-b334-56d40f725c8a' ),
('bce0ba43-1098-4570-953a-81cb09e27d55', 'url/resource/to/file/server/file2.pdf', '59f4d9df-006b-4d7c-82dc-736041e97f37', '417c0d5d-d417-4333-b334-56d40f725c8a' ),
('03d71aee-880b-4898-b04f-da21f8f095bb', 'url/resource/to/file/server/file3.pdf', '59f4d9df-006b-4d7c-82dc-736041e97f37', '36f6062e-356a-4d14-84c6-2da68c962287' ),
('7d70a34f-bce6-4a29-a693-c1ace2075a81', 'url/resource/to/file/server/file4.pdf', '59f4d9df-006b-4d7c-82dc-736041e97f37', '27a74411-ed86-484b-9904-7146183135dc' );


-- payment for nomination
INSERT INTO PAYMENT
    (ID, DEPOSITOR, DEPOSIT_DATE, AMOUNT, FILE_PATH, STATUS, NOTE, CREATED_BY, CREATED_AT, UPDATED_AT, NOMINATION_ID)
    -- DEPOSITOR = user role
VALUES
('aaba475b-fb11-4395-86f5-c7e2afdab491', 'SECRETARY', 1546851055, 200000.00, 'url/resource/to/file/server/file1.pdf', 'PENDING', null, 'party-user-1', 1546713528, 1546713528, '135183e2-a0ca-44a0-9577-0d2b16c3217f' ),
('e14c183e-4e26-499f-ab6f-78666f1d5e47', 'SECRETARY', 1546851055, 260000.00, 'url/resource/to/file/server/file2.pdf', 'PENDING', null, 'party-user-2', 1546713528, 1546713528,  '416e0c20-b274-4cf2-9531-8167d2f35bf7' ),
('9f7b9f8f-0045-477e-a663-0bef194d9a0f', 'SECRETARY', 1546851055, 300000.00, 'url/resource/to/file/server/file3.pdf', 'PENDING', null, 'party-user-3', 1546713528, 1546713528,  'a0e4a9c9-4841-45df-9600-f7a607400ab6' ),
('378a33e1-5ad0-42f1-9403-dc9dbba32f4c', 'SECRETARY', 1546851055, 500000.00, 'url/resource/to/file/server/file4.pdf', 'PENDING', 'This is a sample note.', 'party-user-4', 1546713528, 1546713528,  'ed7e455c-eb95-4ccc-b090-32c1616c6d0c' );



-- 
-- CANDIDATE
-- 

INSERT INTO CANDIDATE
    (ID, FULL_NAME, PREFERRED_NAME, NIC, DATE_OF_BIRTH, GENDER, ADDRESS, OCCUPATION, ELECTORAL_DIVISION_NAME, ELECTORAL_DIVISION_CODE, COUNSIL_NAME, NOMINATION_ID)
VALUES
('fc32c310-a1eb-4cc6-a739-da9433b5aeef', 'Full-Name1', 'Preffered-Name1', '883120740v', '595209600', 'Male', 'Address', 'Businessman', 'electoral-division-name', '12', 'counsil-name', '135183e2-a0ca-44a0-9577-0d2b16c3217f'),
('587b46ab-5425-408a-b303-4e992d90e2ad', 'Full-Name1', 'Preffered-Name1', '883120740v', '595209600', 'Male', 'Address', 'Businessman', 'electoral-division-name', '22', 'counsil-name', '135183e2-a0ca-44a0-9577-0d2b16c3217f'),
('b4f7af64-61d4-42c4-8623-8c9efb9d0f21', 'Full-Name1', 'Preffered-Name1', '883120740v', '595209600', 'Male', 'Address', 'Businessman', 'electoral-division-name', '1', 'counsil-name', '135183e2-a0ca-44a0-9577-0d2b16c3217f'),
('1d986c33-0e3d-4e27-9ff3-a8b03118408c', 'Full-Name1', 'Preffered-Name1', '883120740v', '595209600', 'Male', 'Address', 'Businessman', 'electoral-division-name', '3', 'counsil-name', '135183e2-a0ca-44a0-9577-0d2b16c3217f'),
('a5215262-6da0-4455-a7f3-9b1ae51b97f5', 'Full-Name1', 'Preffered-Name1', '883120740v', '595209600', 'Male', 'Address', 'Businessman', 'electoral-division-name', '4', 'counsil-name', '135183e2-a0ca-44a0-9577-0d2b16c3217f'),
('72c6427d-4378-4bd9-b83b-d4bb21fd4b49', 'Full-Name1', 'Preffered-Name1', '883120740v', '595209600', 'Male', 'Address', 'Businessman', 'electoral-division-name', '8', 'counsil-name', '135183e2-a0ca-44a0-9577-0d2b16c3217f'),
('82af0374-2475-47bc-bef1-ff75070ff6d5', 'Full-Name1', 'Preffered-Name1', '883120740v', '595209600', 'Male', 'Address', 'Businessman', 'electoral-division-name', '7', 'counsil-name', '135183e2-a0ca-44a0-9577-0d2b16c3217f'),
('5aee10f5-8e39-4f48-a3ba-d44d49b6a68e', 'Full-Name1', 'Preffered-Name1', '883120740v', '595209600', 'Male', 'Address', 'Businessman', 'electoral-division-name', '14', 'counsil-name', '135183e2-a0ca-44a0-9577-0d2b16c3217f'),
('a6eb639c-c6e6-4da0-b0b0-30dff94b1a8b', 'Full-Name1', 'Preffered-Name1', '883120740v', '595209600', 'Male', 'Address', 'Businessman', 'electoral-division-name', '16', 'counsil-name', '135183e2-a0ca-44a0-9577-0d2b16c3217f'),
('4ebce670-4226-476e-8bf8-aa810c0a60a5', 'Full-Name1', 'Preffered-Name1', '883120740v', '595209600', 'Female', 'Address', 'Businessman', 'electoral-division-name', '20', 'counsil-name', '135183e2-a0ca-44a0-9577-0d2b16c3217f');







