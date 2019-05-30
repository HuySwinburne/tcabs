/*
SET SQL_SAFE_UPDATES = 0;
SET GLOBAL log_bin_trust_function_creators = 1;
SET autocommit=0;
*/
DROP DATABASE tcabs;
CREATE DATABASE tcabs;

USE tcabs;

CREATE TABLE UserRole (
	userType		VARCHAR(50)				NOT NULL,

	PRIMARY KEY (userType)
);

CREATE TABLE Users (
	fName				VARCHAR(255)			, 
	lName				VARCHAR(255)			, 
	gender				VARCHAR(20),
	pNum				VARCHAR(255),
	email				VARCHAR(255)			NOT NULL,
	pwd					VARCHAR(40)				NOT NULL,

	PRIMARY KEY (email)
	-- FOREIGN KEY (userType) REFERENCES UserRole (userType)
);
-- Alter Table Users
-- Alter Users set Default null;

CREATE TABLE Project (
	ProjectName			VARCHAR(255),
    ProjectDescription text,
	-- PHP people add this
    -- filename VARCHAR(128) NOT NULL,
	-- mimetype VARCHAR(64) NOT NULL,
	-- datastore MEDIUMBLOB NOT NULL,

	PRIMARY KEY (ProjectName)
);

CREATE TABLE UserCat (
	email				VARCHAR(50)				NOT NULL,
	userType		VARCHAR(50)				NOT NULL,

	PRIMARY KEY (email, userType),
	FOREIGN KEY (userType) REFERENCES UserRole (userType),
    FOREIGN KEY (email) REFERENCES Users (email) on delete cascade
);

CREATE TABLE Functions (
	procName		VARCHAR(50)				NOT NULL,

	PRIMARY KEY (procName)
);

CREATE TABLE Permission (
	userType		VARCHAR(50)				NOT NULL,
	procName		VARCHAR(50)				NOT NULL,

	PRIMARY KEY (userType, procName),
	FOREIGN KEY (userType) REFERENCES UserRole (userType),
	FOREIGN KEY (procName) REFERENCES Functions (procName)
);

CREATE TABLE Unit (
	unitCode		VARCHAR(10)				NOT NULL,
	unitName		VARCHAR(100)			NOT NULL,
	faculty			VARCHAR(255)				,

	PRIMARY KEY (unitCode),
	INDEX search (unitCode, unitName)
);

CREATE TABLE TeachingPeriod (
	term			VARCHAR(10)				NOT NULL,
	year			VARCHAR(10)				NOT NULL,
	StartDate		date					NOT Null,
	EndDate			date					NOT Null,
	PRIMARY KEY (term, year)
);

CREATE TABLE UnitOffering (
	unitOfferingID			INT				AUTO_INCREMENT,
	unitCode		VARCHAR(10)				NOT NULL,
	cUserName		VARCHAR(255),
	term				VARCHAR(10)				NOT NULL,
	year				VARCHAR(10)				NOT NULL,
	censusDate	Date				, -- i don't think this needs to be filled

	PRIMARY KEY (unitOfferingID),
	FOREIGN KEY (unitCode) REFERENCES Unit(unitCode),
	FOREIGN KEY (term, year) REFERENCES TeachingPeriod(term, year)
);

CREATE TABLE OfferingProject (
	OfferingProjectID			INT				AUTO_INCREMENT,
	UnitOfferingID				int				Not null,
	ProjectName					VARCHAR(255)				Not null,
    
	primary key(OfferingProjectID),
	FOREIGN KEY (UnitOfferingID) REFERENCES UnitOffering(UnitOfferingID),
	FOREIGN KEY (ProjectName) REFERENCES Project(ProjectName)
);


CREATE TABLE Enrolment (
	enrolmentID					INT				AUTO_INCREMENT,
	unitOfferingID			INT				NOT NULL,
	sUserName		VARCHAR(255)			NOT NULL,

	PRIMARY KEY (enrolmentID),
	FOREIGN KEY (sUserName) REFERENCES Users(email),
	FOREIGN KEY (unitOfferingID) REFERENCES UnitOffering(unitOfferingID)
);

 CREATE TABLE OfferingStaff (
	OfferingStaffID			int				auto_increment,
  UserName				VARCHAR(255)	NOT NULL,
	UnitOfferingID			int				NOT NULL,
	PRIMARY KEY (OfferingStaffID),
    FOREIGN KEY (UserName) REFERENCES Users(email),
    FOREIGN KEY (unitOfferingID) REFERENCES UnitOffering(unitOfferingID)
);

Create Table Team (
	TeamID							INT				AUTO_INCREMENT,
	TeamName						Varchar(255) 	not null,
	OfferingStaffID					int				Not Null,
	ProjectManager					Varchar(255),

	PRIMARY KEY (TeamID),
	FOREIGN KEY (OfferingStaffID) REFERENCES OfferingStaff(OfferingStaffID)
);



Create Table TeamProjects(
	TeamProjectID					int				auto_increment,
	TeamID							int				not null,
	ProjectName						Varchar(255)		not null,
	Budget							double(6,2),
    
	Primary key (TeamProjectID),
		foreign key (TeamID)	references Team(TeamID),
		FOREIGN KEY (ProjectName) REFERENCES Project(ProjectName)
);

Create Table TeamMember (
	TeamMemberID					INT				AUTO_INCREMENT,
	EnrolmentID						INT				NOT NULL,
	TeamID							INT				NOT NULL,

	PRIMARY KEY (TeamMemberID),
		FOREIGN KEY (TeamID) REFERENCES Team(TeamID),
		FOREIGN KEY (EnrolmentID) REFERENCES Enrolment(enrolmentID)
);

Create Table ProjectRole (
	Rolename						varchar(255) 			Not Null,
	Salary							double(6,2)			Not Null,
	RoleDescription					text,
    
	Primary Key (Rolename)
);

Create Table Task (
	ProjectTaskID					int 			not null,			
	TeamMemberID					int				not null,
	TeamProjectID					int				not Null,
	Rolename						varchar(255)	not null,
	TaskDetails						text			not null,
	TimeTaken						int				not null,
	logged							boolean			DEFAULT false,
	Altered							boolean			DEFAULT false,

	Primary Key (ProjectTaskID,TeamProjectID),
    Foreign Key (TeamMemberID) REFERENCES TeamMember(TeamMemberID),
    Foreign Key (Rolename) REFERENCES ProjectRole(Rolename),
    Foreign Key (TeamProjectID) REFERENCES TeamProjects(TeamProjectID)
);

Create Table SupervisorMeeting (
	MeetingID						INT				AUTO_INCREMENT,
    TeamID							int				Not Null,
    Agender							text,
    StartTime						datetime		Not null,				
    EndTime							datetime,
    Display_Time					bool			default false, -- can students see the location?
    Location						text,
    Display_Loc						bool			default false, -- can students see the location?
	Meeting_Minutes					text,
    Comments						text,
    Approval						bool			default false,
    Primary Key (MeetingID),
    FOREIGN KEY (TeamID) REFERENCES Team(TeamID)
);

Create Table MeetingAttendees (
	MeetingAttendeeID				int				auto_increment,
    TeamMemberID					int				not null,
    MeetingID						int				not null,
    
	primary key (MeetingAttendeeID),
    Foreign Key (TeamMemberID) REFERENCES TeamMember(TeamMemberID),
    Foreign Key (MeetingID) REFERENCES SupervisorMeeting(MeetingID)
);

Create Table StudentPeerAssessment (
	SPAID					int				auto_increment,
    AssessmentName			varchar(255) 	Not Null,
    
    
	primary key (SPAID)
);

Create Table SPAInstence (
	SPAInstenceID			int				auto_increment,
    UnitOfferingID			int				not null,
    SPAID					int 			not null,
    AssessmentDate			date			not null,
    
	primary key (SPAInstenceID),
    Foreign Key (SPAID) REFERENCES StudentPeerAssessment(SPAID),
    Foreign Key (UnitOfferingID) REFERENCES UnitOffering(UnitOfferingID)
);

Create Table PeerAssessmentFeild (
	FeildID					int				auto_increment,
    SPAID					int 			not null,
    FeildName				varchar(255)	not null,
    FeildDescription		text			not null,
	primary key (FeildID),
    Foreign Key (SPAID) REFERENCES StudentPeerAssessment(SPAID)
);

INSERT INTO tcabs.UserRole VALUES ("admin");
INSERT INTO tcabs.UserRole VALUES ("convenor");
INSERT INTO tcabs.UserRole VALUES ("supervisor");
INSERT INTO tcabs.UserRole VALUES ("student");
INSERT INTO tcabs.UserRole VALUES ("nullUser");

INSERT INTO tcabs.Users VALUES ("Daenerys", "Targaryen", "F", "041-232-3443", "dtargaryen@gmail.com", "5753dca0b5c2ed36a457d3beb5ed75ce9d1d2c8c"); -- pwd motherofdragons
INSERT INTO tcabs.Users VALUES ("John", "Snow", "M", "041-233-2243", "jsnow@gmail.com", "45ee86bd96a5d5c8a34be537fa6d7703767da270"); -- pwd kinginthenorth
INSERT INTO tcabs.Users VALUES ("Robert", "Baratheon", "M", "041-233-2263", "rbaratheon@gmail.com", "80f3008f6a58f3745d2e1fd1a674b239314274a0"); -- rulerofsevenkingdoms
INSERT INTO tcabs.Users VALUES ("Arya", "Stark", "F", "041-233-2263", "astark@gmail.com", "7a3a83e08bd6db9ee1bebaf18e2065597150e39d"); -- pwd thereisonlyonegod
INSERT INTO tcabs.Users VALUES ("Arya", "Stark", "F", "041-233-2263", "astark1@gmail.com", "7a3a83e08bd6db9ee1bebaf18e2065597150e39d"); -- pwd thereisonlyonegod

INSERT INTO tcabs.Unit VALUES ("ICT30001", "Information Technology Project", "FSET");
INSERT INTO tcabs.Unit VALUES ("INF30011", "Database Implementation", "FSET");
INSERT INTO tcabs.Unit VALUES ("STA10003", "Foundation of Statistics", "FSET");
INSERT INTO tcabs.Unit VALUES ("STA20010", "Statisical Computing", "FSET");

INSERT INTO tcabs.TeachingPeriod VALUES ("Semester 1", "2019", STR_TO_DATE("2019-5-3", '%Y-%m-%d') , STR_TO_DATE("2019-8-1", '%Y-%m-%d'));
INSERT INTO tcabs.TeachingPeriod VALUES ("Semester 2", "2019", STR_TO_DATE("2019-5-3", '%Y-%m-%d') , STR_TO_DATE("2019-8-1", '%Y-%m-%d'));
INSERT INTO tcabs.TeachingPeriod VALUES ("Semester 2", "2018", STR_TO_DATE("2019-5-3", '%Y-%m-%d') , STR_TO_DATE("2019-8-1", '%Y-%m-%d'));
INSERT INTO tcabs.TeachingPeriod VALUES ("Winter", "2018", STR_TO_DATE("2019-5-3", '%Y-%m-%d') , STR_TO_DATE("2019-8-1", '%Y-%m-%d'));
INSERT INTO tcabs.TeachingPeriod VALUES ("Summer", "2018", STR_TO_DATE("2019-5-3", '%Y-%m-%d') , STR_TO_DATE("2019-8-1", '%Y-%m-%d'));

INSERT INTO tcabs.UserCat VALUES ("dtargaryen@gmail.com", "admin");
INSERT INTO tcabs.UserCat VALUES ("dtargaryen@gmail.com", "convenor");
INSERT INTO tcabs.UserCat VALUES ("jsnow@gmail.com", "admin");
INSERT INTO tcabs.UserCat VALUES ("astark@gmail.com", "admin");
INSERT INTO tcabs.UserCat VALUES ("astark1@gmail.com", "admin");

INSERT INTO tcabs.UnitOffering VALUES (1, "ICT30001", "dtargaryen@gmail.com", "Semester 2", "2018", "2018-06-05");

INSERT INTO tcabs.Enrolment VALUES("1", "1", "astark@gmail.com");
INSERT INTO tcabs.OfferingStaff VALUES ("1", "dtargaryen@gmail.com", "1");
INSERT INTO tcabs.Team VALUES ("1", "just a name", "1", "asdf");
INSERT INTO tcabs.TeamMember VALUES("213213", "1", "1");

delimiter $$
create PROCEDURE TCABSAuthenticateEmail(in Email varchar (255))
BEGIN
	if(char_length(Email) <= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "the New Email feild has not been filled";
	end if;
	if (Email not Like '%.%' or Email not Like '%@%') then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Email must contain a '@' and a '.' character";
	end if;
	if (position("@" in Email) < 2) then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "'@' character in email can only occur after two characters";
	end if;
	if ((position("." in Email) -2) <= position("@" in Email) ) then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "'.' must occur at least two characters after '@'";
	end if;
	if (position("." in Email) >= (char_length(Email)-2)) then 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "'.' must occur at least two characters before the emailaddresses end";
	end if;
END$$
 delimiter;

DELIMITER //
create PROCEDURE TCABSUSERCreateNewUser(in Newemail varchar(225), in newpassword varchar(225))
	BEGIN
		if (select count(*) from tcabs.Users where email = Newemail) = 0 then 
	    call tcabs.TCABSAuthenticateEmail(Newemail);
			if (char_length(newpassword) <=3) then
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Password is too short';
			end if;
				insert into tcabs.Users(email,pwd) values (newemail,newpassword);
		else
-- call raise_application_error(1234, 'msg');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This email already exists';
	End if;
	END //
 DELIMITER ;

 DELIMITER //
create PROCEDURE TCABSUSERSetUserFirstName(in UserEmail Varchar(255), in NewuserFistname Varchar(255) )
	BEGIN
	Declare Errormsg varchar(255) default "no email entered";
    if(char_length(UserEmail) <= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "the First name Email feild has not been filled";
	end if;
	call TCABSValidateNameString(NewuserFistname);
	if (select count(*) from tcabs.Users where email = UserEmail) = 1 then 
		update tcabs.Users set Fname = NewuserFistname where email = UserEmail;
	else
		set Errormsg = concat("There is no user with the email ", UserEmail);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = Errormsg;
	end if;
	END //
 DELIMITER ;

 DELIMITER //
create PROCEDURE TCABSValidateNameString(in Username varchar(255))
begin
	if (char_length(Username) <= 1) then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "a name must have at least two characters";
    end if;
	 if (Username REGEXP '[0-9]') then 
	 	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "a name can't contain numbers";
	 end if;
   if (Username like '%"%' or Username like "%'%" or Username like '%!%' or Username like '%@%' or Username like '%&%' or Username like '%*%' or Username like '%(%' or Username like '%)%' or Username like '%+%' or Username like '%?%' or Username like '%=%')
   then 
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "a name can only contain letters of the alphabet";
   end if;
	END //
 DELIMITER ;

 DELIMITER //
create PROCEDURE TCABSUSERSetUserLastName(in UserEmail Varchar(255), in NewuserLastname Varchar(255) )
	BEGIN
	Declare Errormsg varchar(255) default "no email entered";
    if(char_length(UserEmail) <= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "the Last name Email feild has not been filled";
	end if;
	call TCABSValidateNameString(NewuserLastname);
	if (select count(*) from tcabs.Users where email = UserEmail) = 1 then 
		update tcabs.Users set lName = NewuserLastname where email = UserEmail;
	else
		set Errormsg = concat("There is no user with the email ", UserEmail);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = Errormsg;
	end if;
	END //
 DELIMITER ;
 
  DELIMITER //
create PROCEDURE TCABSUSERSetUserGender(in UserEmail Varchar(255), in NewuserGender Varchar(20) )
	BEGIN
	Declare Errormsg varchar(255) default "no email entered";
    if(char_length(UserEmail) <= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "the Gender Email feild has not been filled";
	end if;
	if (select count(*) from tcabs.Users where email = UserEmail) = 1 then 
		update tcabs.Users set gender = NewuserGender where email = UserEmail;
	else
		set Errormsg = concat("There is no user with the email ", UserEmail);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = Errormsg;
	end if;
	END //
 DELIMITER ;
 
   DELIMITER //
create PROCEDURE TCABSUSERSetUserPhone(in UserEmail Varchar(255), in NewPhone Varchar(255) )
	BEGIN
	Declare Errormsg varchar(255) default "no email entered";
    if(char_length(UserEmail) <= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "the Phone Email feild has not been filled";
	end if;
    call TCABSValidUserPhonenumber(NewPhone);
	if (select count(*) from tcabs.Users where email = UserEmail) = 1 then 
		update tcabs.Users set pNum = NewPhone where email = UserEmail;
	else
		set Errormsg = concat("There is no user with the email ", UserEmail);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = Errormsg;
	end if;
	END //
 DELIMITER ;
 
DELIMITER //
create PROCEDURE TCABSValidUserPhonenumber( in NewPhone Varchar(255) )
	BEGIN
		if (NewPhone not REGEXP '[0-9]{3}-[0-9]{3}-[0-9]{4}') then
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "phone number must be numbers in ###-###-#### format";
        end if;
	END //
DELIMITER;

DELIMITER //
CREATE PROCEDURE TCABS_User_register(IN fName VARCHAR(255), IN lName VARCHAR(255), IN gender VARCHAR(20), IN pNum VARCHAR(255), IN email VARCHAR(255), IN pwd VARCHAR(40)) 
	BEGIN
		DECLARE EXIT HANDLER FOR 45000 ROLLBACK;

		START TRANSACTION;
			CALL tcabs.TCABSUSERCreateNewUser(email , pwd);
			CALL tcabs.TCABSUSERSetUserFirstName(email, fName);
			CALL tcabs.TCABSUSERSetUserLastName(email, lName);
			CALL tcabs.TCABSUSERSetUserGender(email, gender);
			CALL tcabs.TCABSUSERSetUserPhone(email, pNum);
			-- confused about the procedure below
			-- CALL TCABSUserCatAssignUserARole(email, uRole);
		COMMIT;
	END// 
DELIMITER ;

DELIMITER //
CREATE PROCEDURE TCABS_User_Update(IN fName VARCHAR(255), IN lName VARCHAR(255), IN gender VARCHAR(20), IN pNum VARCHAR(255), IN usrEmail VARCHAR(255)) 
	BEGIN
		DECLARE EXIT HANDLER FOR 45000 ROLLBACK;

		START TRANSACTION;
			-- CALL tcabs.TCABSUSERCreateNewUser(email , pwd); Since we are only updating we don't need this - ssavage 29 05 2019 
			CALL tcabs.TCABSUSERSetUserFirstName(email, fName);
			CALL tcabs.TCABSUSERSetUserLastName(email, lName);
			CALL tcabs.TCABSUSERSetUserGender(email, gender);
			CALL tcabs.TCABSUSERSetUserPhone(email, pNum);
			-- confused about the procedure below
			-- CALL TCABSUserCatAssignUserARole(email, uRole);
		COMMIT;
	END// 
DELIMITER ;


-- adding user actions. You should initalize with TCABSCreatNewUser if you are creating a new user
-- Create new user sets user Email (identification) and user Password
call tcabs.TCABSUSERCreateNewUser("Example@hotmail.com" , 12345);

-- Set User firstname updates users first name from what it was before to new name via the Email identifier
call tcabs.TCABSUSERSetUserFirstName("Example@hotmail.com" , "Billy");

-- Set User Lastname updates users Last name from what it was before to new name via the Email identifier
call tcabs.TCABSUSERSetUserLastName("Example@hotmail.com" , "Bobington");

-- Set User Gender updates users Gender from what it was before to new name via the Email identifier currently there is minimal checks for feild
call tcabs.TCABSUSERSetUserGender("Example@hotmail.com" , "Male");

-- set User Phone updates their phone number from what it was before to new name via the Email identifier. The phone number must follow ###-###-#### pattern
call tcabs.TCABSUSERSetUserPhone("Example@hotmail.com" , "041-144-7897");

call tcabs.TCABSUSERCreateNewUser("BestExample@hotmail.com" , 12345);
call tcabs.TCABSUSERCreateNewUser("Best@Supervisor.com" , 12223);

 
DELIMITER //
create PROCEDURE TCABSUNITAddnewunit( in NewUnitcode varchar(10), in NewUnitname varchar(100))
	BEGIN
		Declare Errormsg varchar(255) default "no Unit code entered";
		if (select count(*) from tcabs.Unit where unitCode = NewUnitcode) = 0 then 
			call TCABSUNITValidateNewUnitCode(NewUnitcode);
			call TCABSUNITValidateNewUnitName(NewUnitname);
		insert into tcabs.Unit (unitCode, unitName) values (NewUnitcode,NewUnitname);
        else
        set Errormsg = concat( NewUnitcode, " already exist");
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = Errormsg;
        end if;
	END //
 DELIMITER ;

     DELIMITER //
create PROCEDURE TCABSUNITValidateNewUnitCode( in NewUnitcode varchar(10))
	BEGIN
		if (Char_length(NewUnitcode) <> 8) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Unit code is not the appropriate length of 8";
        end if;
        
        if(Substring(NewUnitcode,1,3) REGEXP '[0-9]') then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Unit code must start with a three letter prefix";
        end if;
        
        if(Substring(NewUnitcode,4) REGEXP '[A-Z]') then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Unit code must be 3 letters followed by 5 numbers";
        end if;
        
	END //
 DELIMITER ;

     DELIMITER //
create PROCEDURE TCABSUNITValidateNewUnitName( in NewUnitname varchar(100))
	BEGIN
		Declare checkname varchar(255) default "";
        set checkname = Replace(NewUnitname, ' ', '');
        if(char_length(NewUnitname) <= 1) then
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Unit name must be more than one character";
        end if;
        if(Substring(checkname,1) REGEXP '[0-9]') then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Unit name must not contain numbers";
        end if;
	END //
 DELIMITER ;
 
      DELIMITER //
create PROCEDURE TCABSUNITValidateNewFacultyName( in NewFacultyname varchar(100))
	BEGIN
		Declare checkname varchar(255) default "";
        set checkname = Replace(NewFacultyname, ' ', '');
        if(char_length(NewFacultyname) <= 1) then
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Faculty name must be more than one character";
        end if; 
        if(Substring(checkname,1) REGEXP '[0-9]') then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Faculty Name must not contain numbers";
        end if;
	END //
 DELIMITER ;
 
       DELIMITER //
create PROCEDURE TCABSUNITSetNewFacultyName( in EnteredUnitcode Varchar(255), in NewFacultyname varchar(100))
	BEGIN
    Declare Errormsg varchar(255) default "no Faculty entered";
    if(char_length(EnteredUnitcode) <= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "the Unit code for new Faculty has not been filled";
	end if;
        call TCABSUNITValidateNewFacultyName(NewFacultyname);
	if (select count(*) from tcabs.Unit where unitCode = EnteredUnitcode) = 1 then 
		update tcabs.Unit set faculty = NewFacultyname where unitCode = EnteredUnitcode;
	else
		set Errormsg = concat("There is no Unit with the code ", EnteredUnitcode);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = Errormsg;
	end if;
	END //
 DELIMITER ;
 
DELIMITER //
CREATE PROCEDURE TCABS_Unit_register(IN uCode VARCHAR(10), IN uName VARCHAR(100), IN uFaculty VARCHAR(255))
	BEGIN

		DECLARE EXIT HANDLER FOR 45000 ROLLBACK;

		START TRANSACTION;
			CALL tcabs.TCABSUNITAddnewunit(uCode, uName);
			CALL tcabs.TCABSUNITSetNewFacultyName(uCode, uFaculty);
		COMMIT;
	END// 
DELIMITER ;


 -- adding new unit to available subjects
 -- you should initalise with Addnewunit by providing the new units code which is a 3 letter prefix followed by 5 numbers. Then you provide the units name which doesn't contain numbers
call TCABSUNITAddnewunit("ICT30002", "Information Technology Project");
call TCABSUNITAddnewunit("ICT30003", "Information Technology Assignment");
-- this sets the original Faculty name to the new faculty name which doesn't contain numbers, utalising the unit code as its id
call TCABSUNITSetNewFacultyName("ICT30002", "Buisnesses and Law");

 
DELIMITER //
create Procedure TCABSUserCatAssignUserARole(in UserEmail varchar(255), in RoleName varchar(255))
	BEGIN
		if (char_length(UserEmail) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no User Email entered";
        end if;
        
		if (char_length(RoleName) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Role name entered";
        end if;
        
        if ((select count(*) from Users where email = UserEmail) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered User Email does not exist";
        end if;
        
        if ((select count(*) from UserRole where usertype = RoleName) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered Role name does not exist";
        end if;
        
        if ((select count(*) from UserCat where userType = RoleName and email = UserEmail) >= 1) then
			-- SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered User already has the assigned Role";
            update UserCat set usertype = RoleName where email = UserEmail;
		end if;
        insert into UserCat values (UserEmail,RoleName);
	END //
 DELIMITER ;


 -- User Cat
 -- assigns the User with the email Example@hotmail.com to the Role of testerRole
 call TCABSUserCatAssignUserARole("Example@hotmail.com", "student");
 call TCABSUserCatAssignUserARole("BestExample@hotmail.com", "student");
 call TCABSUserCatAssignUserARole("jsnow@gmail.com", "convenor");
  call TCABSUserCatAssignUserARole("dtargaryen@gmail.com", "supervisor");
  call TCABSUserCatAssignUserARole("Best@Supervisor.com", "supervisor");


DELIMITER //
create Procedure TCABSValidateDate(in checkdate varchar(255))
	BEGIN
    Declare ErrormsgTeachingperiod varchar(255) default "no Values entered";
        if ((STR_TO_DATE(checkdate, "%Y-%m-%d")) IS NULL) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "invalid date entry";
        end if;
	END //
DELIMITER ;
 
DELIMITER //
create PROCEDURE TCABSUNITOFFERINGAddNewOffering( in OfferedUnitID Varchar(255), in Offeredterm varchar(255), in Offeredyear varchar(255))
	BEGIN
		if(char_length(OfferedUnitID) <= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "the Unit feild has not been filled";
		end if;
		if((select count(*) from tcabs.Unit where unitCode = OfferedUnitID) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "the Unit you entered does not exist";
		end if;
        call TCABSUNITOFFERINGValidateOfferingPeriod(Offeredterm,Offeredyear);
        if ((select count(*) from UnitOffering where unitCode = OfferedUnitID and term = Offeredterm and year = Offeredyear) = 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "the Unit offering you entered already exists";
        end if;
		insert into UnitOffering(unitCode, term, year) values (OfferedUnitID,Offeredterm,Offeredyear);
	END //
DELIMITER ;

DELIMITER //
create PROCEDURE TCABSUNITOFFERINGValidateOfferingPeriod(in Offeredterm varchar(255), in Offeredyear varchar(255))
	BEGIN
    Declare ErrormsgTeachingperiod varchar(255) default "no Values entered";
		if (char_length(Offeredterm) <= 1 or char_length(Offeredyear) <= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "values have not been entered into the feilds";
        end if;
        -- need to add time validation so that users can't create offerings in the past
		if((select count(*) from TeachingPeriod as T where term = Offeredterm and T.year = Offeredyear) <> 1) then
			set ErrormsgTeachingperiod = concat("There is no teaching period for ", Offeredterm, " ", Offeredyear);
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = ErrormsgTeachingperiod;
		end if;
	END //
 DELIMITER ;
 
DELIMITER //
create Procedure TCABSUNITOFFERINGGetKey(in OfferedUnitID Varchar(255), in Offeredterm varchar(255), in Offeredyear varchar(255), out ValuesunitOfferingID int)
	BEGIN
    Declare ErrormsgTeachingperiod varchar(255) default "no Values entered";
		if (char_length(Offeredterm) <= 1 or char_length(Offeredyear) <= 1 or char_length(OfferedUnitID) <= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "values have not been entered into the feilds";
        end if;
		select unitOfferingID into ValuesunitOfferingID from UnitOffering where unitCode = OfferedUnitID and term = Offeredterm and year = Offeredyear;
       
        if (ValuesunitOfferingID is null) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Unknown Unit code, term and year combination ";
		end if;
	END //
DELIMITER ;
 
DELIMITER //
create Procedure TCABSUNITOFFERINGSetCensusDate(in OfferedUnitID Varchar(255), in Offeredterm varchar(255), in Offeredyear varchar(255), in OfferedCencusdate varchar(255))
	BEGIN
    Declare ErrormsgTeachingperiod varchar(255) default "no Values entered";
		if (char_length(OfferedCencusdate) <= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "values have not been entered for the Cencus date";
        end if;
        call TCABSUNITOFFERINGGetKey(OfferedUnitID,Offeredterm,Offeredyear,@ValuesunitOfferingID);
        call TCABSUNITOFFERINGValidateCenDate(@ValuesunitOfferingID, OfferedCencusdate);
        
        update tcabs.UnitOffering set censusDate = STR_TO_DATE(OfferedCencusdate, '%Y-%m-%d') where unitOfferingID = @ValuesunitOfferingID; 
	END //
DELIMITER ;

DELIMITER //
create Procedure TCABSUNITOFFERINGValidateCenDate(in OfferingKey int, in OfferedCencusdate varchar(255))
	BEGIN
    Declare StoredYear varchar(255) default "";
    Declare StoredPeriod varchar(255) default "";
    Declare CrosscheckDateStart Date;
    Declare CrosscheckDateEnd Date;
		call TCABSValidateDate(OfferedCencusdate);
        select term, year into StoredPeriod ,StoredYear from UnitOffering where unitOfferingID = OfferingKey;
        select StartDate, EndDate into CrosscheckDateStart,CrosscheckDateEnd from TeachingPeriod where term = StoredPeriod and year = StoredYear;
        if (STR_TO_DATE(OfferedCencusdate, '%Y-%m-%d') <= CrosscheckDateStart) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Cencus date can not occur on or before start date";
        end if;
        if (STR_TO_DATE(OfferedCencusdate, '%Y-%m-%d') >= CrosscheckDateEnd) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Cencus date can not occur after or after the end date";
        end if;
	END //
DELIMITER ;
 
DELIMITER //
create Procedure TCABSUNITOFFERINGSetConvenor(in ConvnorEmail varchar(255), in OfferedUnitID Varchar(255), in Offeredterm varchar(255), in Offeredyear varchar(255))
	BEGIN
    Declare ErrormsgTeachingperiod varchar(255) default "no Values entered";
		if (char_length(ConvnorEmail) <= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "values have not been entered into the email feild";
        end if;
        
		 call TCABSUNITOFFERINGGetKey(OfferedUnitID, Offeredterm, Offeredyear, @ValuesunitOfferingID);
          
        if ((select count(*) from Users where email = ConvnorEmail) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Entered Email is not found";
        end if;
        
        if ((select count(*) from UserCat where email = ConvnorEmail and usertype = "convenor") <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Entered User Does not have the role of convenor";
        end if;
        
        if ((select count(*) from OfferingStaff where Username = ConvnorEmail and unitOfferingID = @ValuesunitOfferingID) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Entered user isn't set as a staff member for this offering";
        end if;
        
        update tcabs.UnitOffering set cUserName = ConvnorEmail where unitOfferingID = @ValuesunitOfferingID; 
	END //
DELIMITER ;


 -- add unit offering 
 -- must initalise new unit offering with Add new offering. Pass in a matching Subject code and a matching Offering term and Offering year combo
 call TCABSUNITOFFERINGAddNewOffering("ICT30002", "Semester 1", "2019");
 call TCABSUNITOFFERINGAddNewOffering("ICT30003", "Semester 1", "2019");
 -- this procedures accepts a subject code, offering term and offering year (@ValuesunitOfferingID feild empty). If they are a registored combonation then @ValuesunitOfferingID returns the key for that combination
 -- this shouldn't be called outside of a procedure as it doesn't update tables and returns a key which holds no relation to any information the user would know
 call TCABSUNITOFFERINGGetKey("ICT30002", "Semester 1", "2019", @ValuesunitOfferingID);
 -- the cencus date can only occur during the time period the unit is offered
 call TCABSUNITOFFERINGSetCensusDate("ICT30002", "Semester 1", "2019","2019-6-03");
 call TCABSUNITOFFERINGSetCensusDate("ICT30003", "Semester 1", "2019","2019-6-03");
 -- additional functionality called TCABSUNITOFFERINGSetConvenor after Add new TCABSOFFERINGSTAFFAddOfferingStaff
 


          DELIMITER //
create Procedure TCABSENROLMENTAddNewEnrolment(in NewEnrolUser varchar(255),in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255))
	BEGIN
		
		 if ((select count(*) from Users where email = NewEnrolUser) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Entered Email is not in users";
		end if;
		 call TCABSUNITOFFERINGGetKey(SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @ValuesunitOfferingID);
         call TCABSENROLMENTPossibleEnrolmentTime(@ValuesunitOfferingID);
         if ((select count(*) from Enrolment where sUserName = NewEnrolUser and unitOfferingID = @ValuesunitOfferingID) = 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "user has already been assigned into that unit";
         end if;
         if ((select count(*) from UserCat where email = NewEnrolUser and userType = "student") <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "user is not a student";
         end if;
         insert into Enrolment(sUserName, unitOfferingID) values (NewEnrolUser, @ValuesunitOfferingID);
	END //
 DELIMITER ;
 
           DELIMITER //
create Procedure TCABSENROLMENTPossibleEnrolmentTime(in OfferingKey int)
	BEGIN
		declare storedcensus date;
		 select censusDate into storedcensus from UnitOffering where unitOfferingID = OfferingKey;
         if (storedcensus < sysdate() and storedcensus is not null) then 
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Selected offering is past its census date";
		end if;
	END //
 DELIMITER ;
 
           DELIMITER //
create Procedure TCABSENROLMENTGetEnrolKey(in EnroledUser varchar(255),in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255), out ValueEnrolID int)
	BEGIN
		if (char_length(EnroledUser) <= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "values have not been entered into the email feild";
        end if;
		 if ((select count(*) from Users where email = EnroledUser) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Entered Email is not in users";
		end if;
		 call TCABSUNITOFFERINGGetKey(SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @ValuesunitOfferingID);
         
         select enrolmentid into ValueEnrolID from Enrolment where sUserName = EnroledUser and unitOfferingID = @ValuesunitOfferingID;
         
         if (ValueEnrolID is null) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered user has not enroled in selected unit";
         end if;
	END //
 DELIMITER ;

DELIMITER //	
CREATE PROCEDURE TCABS_enrolment_add(in NewEnrolUser varchar(255),in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255))	
	BEGIN	
		-- I keep getting error -subquery returns more than one row	
		DECLARE EXIT HANDLER FOR 45000 ROLLBACK;	

 		START TRANSACTION;	
			CALL TCABSENROLMENTAddNewEnrolment(NewEnrolUser, SelectedUnitCode, SelectedOfferingTerm, SelectedOfferingyear);	
		COMMIT;	
	END// 	
DELIMITER ;

 -- Create Enrolment 
 -- creates a new Enrolment record using User Email, Unit code, offering term, offering year. returns an error is a filled offering census date is passed by system clock
 call TCABSENROLMENTAddNewEnrolment("Example@hotmail.com","ICT30002", "Semester 1", "2019");
 call TCABSENROLMENTAddNewEnrolment("BestExample@hotmail.com","ICT30002", "Semester 1", "2019");
 -- sub procedure functionally that causes no changes but used in other procedures
 call TCABSENROLMENTGetEnrolKey("Example@hotmail.com","ICT30002", "Semester 1", "2019", @ValueEnrolID);

    DELIMITER //
create PROCEDURE TCABSDeleateUser(in UserEmail Varchar(255))
	BEGIN
	Declare Errormsg varchar(255) default "no email entered";
    if(char_length(UserEmail) <= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = Errormsg;
	end if;
    
    if ((select count(*) from Enrolment where sUserName = UserEmail) >= 1) then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "the student has been enroled into a unit offering";
    end if;
    
    if ((select count(*) from OfferingStaff where username = UserEmail) >= 1) then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "the user has been enroled as a staff member in a unit offering";
    end if;
    
	if (select count(*) from tcabs.Users where email = UserEmail) = 1 then 
		Delete from tcabs.Users where email = UserEmail;
	else
		set Errormsg = concat("There is no user with the email ", UserEmail);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = Errormsg;
	end if;
	END //
 DELIMITER ;
 
 call TCABSUSERCreateNewUser("Example@hotmail2.com" , 12345);
  call TCABSUserCatAssignUserARole("Example@hotmail2.com", "student");
 -- call TCABSENROLMENTAddNewEnrolment("Example@hotmail2.com","ICT30002", "Semester 1", "2019");
 call TCABSDeleateUser("Example@hotmail2.com");
 
-- select * from users;

            DELIMITER //
create Procedure TCABSTEACHINGPERIODCreateNewPeriod(in NewTerm varchar(255), in NewStartDate varchar(255), in NewEndDate varchar(255))
	BEGIN
		if (char_length(NewTerm) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no new term name entered";
        end if;
        call TCABSValidateDate(NewStartDate);
        call TCABSValidateDate(NewEndDate);
        if ((select count(*) from TeachingPeriod where term = NewTerm and year = year(STR_TO_DATE(NewStartDate, '%Y-%m-%d'))) >= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "That term name and startdate year already exists";
        end if;
        if (STR_TO_DATE(NewStartDate, '%Y-%m-%d') >= STR_TO_DATE(NewEndDate, '%Y-%m-%d')) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Enddate cannot occur on or before Start date";
        end if;
        
        insert into TeachingPeriod values (NewTerm, year(STR_TO_DATE(NewStartDate, '%Y-%m-%d')), STR_TO_DATE(NewStartDate, '%Y-%m-%d'), STR_TO_DATE(NewEndDate, '%Y-%m-%d'));
        
	END //
 DELIMITER ;
 -- creating a teaching period
 -- this is to enact the creation of a new period by entering the name of the new period entering the start date and end date (the year column stored in the table is the year of the start date)
-- call TCABSTEACHINGPERIODCreateNewPeriod("Semester 3","2020-3-1","2021-2-2");
 
            DELIMITER //
create Procedure TCABSUSERROLEEnterNewRole(in RoleName varchar(255))
	BEGIN
		Declare checkname varchar(255) default "";
        set checkname = Replace(RoleName, ' ', '');
		if (char_length(checkname) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no new Role name entered";
        end if;
        if(Substring(checkname,1) REGEXP '[0-9]') then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Role Name must not contain numbers";
        end if;
        if ((select count(*) from UserRole where usertype = RoleName) >= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "The entered Role name already exists";
        end if;
        insert into UserRole values (RoleName);
	END //
 DELIMITER ;

-- User role
-- this accepts a new user Role which can then be assigned 
call TCABSUSERROLEEnterNewRole("testerRole");

            DELIMITER //
create Procedure TCABSPERMISSIONAddPermission(in RoleName varchar(255), in Functionality varchar(255))
	BEGIN
		
		if (char_length(RoleName) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Role name entered";
        end if;
        if (char_length(Functionality) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Functionality entered";
        end if;
        if ((select count(*) from UserRole where usertype = RoleName) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered Role name does not exist";
        end if;
        if ((select count(*) from Functions where procName = Functionality) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered Functionality does not exist";
        end if;
        if ((select count(*) from Permission where userType = RoleName and procName = Functionality) >= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered permission already exists";
		end if;
        insert into Permission values (RoleName,Functionality);
	END //
 DELIMITER ;
 
 -- TCABS Permissions 
 -- look at bottom of database code to see call method
 
 -- TCABS Check system date
             DELIMITER //
create function TCABSDateValiadationCheckUnitOfferingVsSystem(SelectedOfferingterm varchar(255), SelectedOfferingyear varchar(255)) returns bool
	BEGIN
		if((select EndDate from TeachingPeriod where term = SelectedOfferingterm and year = SelectedOfferingyear) < sysdate()) then
			return true;
		else
			return false;
        end if;
	END //
 DELIMITER ;

 -- above is a subfunction within procedures
 
             DELIMITER //
create Procedure TCABSOFFERINGSTAFFAddOfferingStaff(in UserEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255))
	BEGIN
		
		if (char_length(UserEmail) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no User Email entered";
        end if;
        
        if ((select count(*) from Users where email = UserEmail) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered User Email does not exist";
        end if;
        
        if ((select count(*) from UserCat where userType = "student" and email = UserEmail) >= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "User is a student and can't be a staff member";
        end if;
        call TCABSUNITOFFERINGGetKey(SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @ValuesunitOfferingID);
        
        if (TCABSDateValiadationCheckUnitOfferingVsSystem(SelectedOfferingterm,SelectedOfferingyear)) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "you can not add a staff member to a unit which has already concluded";
        end if;
        
        if ((select count(*) from OfferingStaff where Username = UserEmail and UnitOfferingID = @ValuesunitOfferingID) >= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered User has already has been assigned as a staff member to this unit";
		end if;
        
        insert into OfferingStaff(Username,UnitOfferingID) values (UserEmail,@ValuesunitOfferingID);
	END //
 DELIMITER ;
 
              DELIMITER //
create Procedure TCABSOFFERINGSTAFFGetOfferingStaffKey(in UserEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255), out ValueOfferingStaff int)
	BEGIN
		
		if (char_length(UserEmail) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no User Email entered";
        end if;
        
        if ((select count(*) from Users where email = UserEmail) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered User Email does not exist";
        end if;
        
        
        call TCABSUNITOFFERINGGetKey(SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @ValuesunitOfferingID);
        
        select OfferingStaffID into ValueOfferingStaff from OfferingStaff where Username = UserEmail and UnitOfferingID = @ValuesunitOfferingID;
        
         if (ValueOfferingStaff is null) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered User Email and unit offering combination does not exist";
         end if;
	END //
 DELIMITER ;
 -- TCABS OfferingStaff
 -- registors user into specified offering
-- call TCABSOFFERINGSTAFFAddOfferingStaff("dtargaryen@gmail.com","ICT30002", "Semester 1", "2019");
 call TCABSOFFERINGSTAFFAddOfferingStaff("jsnow@gmail.com","ICT30002", "Semester 1", "2019");
  call TCABSOFFERINGSTAFFAddOfferingStaff("dtargaryen@gmail.com","ICT30003", "Semester 1", "2019");
  call TCABSOFFERINGSTAFFAddOfferingStaff("Best@Supervisor.com","ICT30003", "Semester 1", "2019");
 -- gets the key for Offering staff instence. This should genrally only be used in procedures
 call TCABSOFFERINGSTAFFGetOfferingStaffKey("jsnow@gmail.com","ICT30002", "Semester 1", "2019",@ValueOfferingStaff);
 
 -- Unit offering Continued..
 -- sets user with entered email to the unit offering convenor if they possess the role of convenor and resgistored as an offering staff member
call TCABSUNITOFFERINGSetConvenor("jsnow@gmail.com","ICT30002", "Semester 1", "2019");

DELIMITER //
CREATE PROCEDURE TCABS_UnitOff_add(IN unitCode Varchar(10), IN convenorEmail varchar(255), IN term varchar(10), IN year varchar(10), IN censusDate varchar(255))
    BEGIN
            declare Exitname varchar(255) default"problem";
		-- I keep getting error -subquery returns more than one row
            DECLARE exit handler for sqlexception
            Begin
                GET DIAGNOSTICS CONDITION 1
                 Exitname = MESSAGE_TEXT;
				rollback;
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = Exitname;
            end;
            START TRANSACTION;
				
				CALL tcabs.TCABSUNITOFFERINGAddNewOffering(unitCode, term, year);
				CALL tcabs.TCABSUNITOFFERINGSetCensusDate(unitCode, term, year, censusDate);
				call TCABSOFFERINGSTAFFAddOfferingStaff(convenorEmail,unitCode, term, year);
				CALL tcabs.TCABSUNITOFFERINGSetConvenor(convenorEmail, unitCode, term, year);
			COMMIT;
	END
    // 
DELIMITER ;

-- select * from unitoffering;
 -- rollback;
 -- select * from unit;
call TCABSUNITAddnewunit("ICT30004","database");
call TCABS_UnitOff_add("ICT30004","dtargaryen@gmail.com","semester 1","2019",STR_TO_DATE("2019-5-20", '%Y-%m-%d'));
 
 
             DELIMITER //
create Procedure TCABSTeamAddTeam(in NewTeamName varchar(255), in UserEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255))
	BEGIN
		
		if (char_length(UserEmail) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no User Email entered";
        end if;
        if (char_length(NewTeamName) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no team name entered";
        end if;
        if ((select count(*) from Users where email = UserEmail) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered User Email does not exist";
        end if;
        
        if ((select count(*) from UserCat where userType = "supervisor" and email = UserEmail) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "User Is not a supervisor and can't be assigned to a team";
        end if;
        call TCABSOFFERINGSTAFFGetOfferingStaffKey(UserEmail, SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear,@ValueOfferingStaff);
        if ((select count(*) from Team where OfferingStaffID = @ValueOfferingStaff and TeamName = NewTeamName) >= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered User has already has been assigned as the supervisor of the team with the entered name";
		end if;
        if (TCABSDateValiadationCheckUnitOfferingVsSystem(SelectedOfferingterm,SelectedOfferingyear)) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "you can not add a team to a unit which has already concluded";
        end if;
        insert into Team(TeamName,OfferingStaffID) values (NewTeamName,@ValueOfferingStaff);
	END //
 DELIMITER ;
 
 
 
              DELIMITER //
create Procedure TCABSTeamSetTeamName(in oldteamname varchar(255), in UserEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255), in newteamname varchar(255))
	BEGIN
		
		if (char_length(UserEmail) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no User Email entered";
        end if;
        if (char_length(newTeamname) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no new Team name entered";
        end if;
        if (char_length(oldTeamname) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no old Team name entered";
        end if;
        if ((select count(*) from Users where email = UserEmail) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered User Email does not exist";
        end if;
        call TCABSTeamGetTeamKey(oldteamname, UserEmail,SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @ValuesTeamID);
        
        update Team set TeamName = newTeamname where OfferingStaffID = @ValuesTeamID and Teamname = oldteamname;
	END //
 DELIMITER ;
 
               DELIMITER //
create Procedure TCABSTeamGetTeamKey(in EnteredTeamname varchar(255), in UserEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255), OUT ValuesTeamID int)
	BEGIN
		if (char_length(EnteredTeamname) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Team name entered";
        end if;
        
        call TCABSOFFERINGSTAFFGetOfferingStaffKey(UserEmail, SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear,@ValueOfferingStaff);
        select TeamID into ValuesTeamID from team where OfferingStaffID = @ValueOfferingStaff and TeamName = EnteredTeamname;
        
        if (ValuesTeamID is null) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Unknown team name and Staff offering combination ";
		end if;
	END //
 DELIMITER ;


                DELIMITER //
create Procedure TCABSTeamSetTeamProjectManager(in Teamname varchar(255), in SuperviserUserEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255), in ProjectManagerUser varchar(255))
	BEGIN
    -- ProjectManagerUser
    
		if (char_length(ProjectManagerUser) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no student Email entered";
        end if;
        
		call TCABSENROLMENTGetEnrolKey(ProjectManagerUser,SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @ValueEnrolID);
		
        call TCABSTeamGetTeamKey(Teamname, SuperviserUserEmail,SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @ValuesTeamID);
        if ((select count(*) from teammember where Enrolmentid = @ValueEnrolID and TeamID = @ValuesTeamID) <> 1) then 
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "student is not assigned to team which they are becoming a project manager of";
        end if;
        
        update Team set ProjectManager = ProjectManagerUser where Teamid = @ValuesTeamID;
	END //
 DELIMITER ;
/*
 -- Addteam
 -- adds a supervisor user to a particular team if they are in the offering staff members list
call TCABSTeamAddTeam("testTeam","jsnow@gmail.com","ICT30002", "Semester 1", "2019");
-- allows for allocation of team name
call TCABSTeamSetTeamName("testTeam","jsnow@gmail.com","ICT30002", "Semester 1", "2019","testTeam2");
-- this procedure is mainly used in other procedures and performs no actions that change tables
call TCABSTeamGetTeamKey("testTeam2", "jsnow@gmail.com","ICT30002", "Semester 1", "2019", @ValuesTeamID);

call TCABSTeamAddTeam("BesttestTeam","jsnow@gmail.com","ICT30002", "Semester 1", "2019");
call TCABSTeamAddTeam("Mortal Combat","jsnow@gmail.com","ICT30003", "Semester 1", "2019");

-- add Project Manager allocation occurs after adding team members
*/

               DELIMITER //
create Procedure TCABSTEAMMEMBERAddTeamMember(in StudentEmail varchar(255),in Teamname varchar(255), in SupervisorEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255))
	BEGIN

		declare StoredEnrolmentID int;
		DECLARE EXIT HANDLER FOR 45000 ROLLBACK;	
		if (char_length(StudentEmail) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Student Email entered";
        end if;
        if (char_length(SupervisorEmail) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Supervisor Email entered";
        end if;
        if (char_length(Teamname) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no team name entered";
        end if;
        if ((select count(*) from Users where email = StudentEmail) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered Student Email does not exist";
        end if;
        if ((select count(*) from Users where email = SupervisorEmail) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered Supervisor Email does not exist";
        end if;
        
        call TCABSUNITOFFERINGGetKey(SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @ValuesunitOfferingID);
        
        select enrolmentID into StoredEnrolmentID from Enrolment where unitOfferingID = @ValuesunitOfferingID and sUserName = StudentEmail;
		if( StoredEnrolmentID is null) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered Student Enrolment not exist";
        end if;
        
        if (TCABSDateValiadationCheckUnitOfferingVsSystem(SelectedOfferingterm,SelectedOfferingyear)) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "you can not add a team member to a unit which has already concluded";
        end if;
        
        call TCABSENROLMENTGetEnrolKey(StudentEmail,SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @ValueEnrolID);
        
        call TCABSTeamGetTeamKey(Teamname,SupervisorEmail,SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @ValuesTeamID);
        
        if ((select count(*) from TeamMember where TeamID = @ValuesTeamID) >= 6) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered team to assign to a student already has the max of 6 team members";
        end if;
        insert into TeamMember(EnrolmentID,TeamID) values (@ValueEnrolID,@ValuesTeamID);

				COMMIT;
        
	END //
 DELIMITER ;
                DELIMITER //
create Procedure TCABSTEAMMEMBERGetTeamMember(in StudentEmail varchar(255),in Teamname varchar(255), in SupervisorEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255), out ValueTeamMemberID int)
	BEGIN
		declare StoredEnrolmentID int;
        
        
        call TCABSENROLMENTGetEnrolKey(StudentEmail,SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @ValueEnrolID);
        call TCABSTeamGetTeamKey(Teamname,SupervisorEmail,SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @ValuesTeamID);
        
        if ((select count(*) from TeamMember where TeamID = @ValuesTeamID and TeamID = @ValueEnrolID) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "The entered team doesn't have the entered Enroled member";
        end if;
        select TeamMemberID into ValueTeamMemberID from TeamMember where TeamID = @ValuesTeamID and TeamID = @ValueEnrolID;
        
	END //
 DELIMITER ;
/*
 -- add student user X to the team called Y with the supervisor user Z which is enroled in the subject A in the period of B for the year of C 
call TCABSTEAMMEMBERAddTeamMember("Example@hotmail.com","testTeam2","dtargaryen@gmail.com","ICT30002", "Semester 1", "2019");
call TCABSTEAMMEMBERAddTeamMember("BestExample@hotmail.com","BesttestTeam","dtargaryen@gmail.com","ICT30002", "Semester 1", "2019");
-- calling method for other procedure this shouldn't be used outside of procedures
call TCABSTEAMMEMBERGetTeamMember("Example@hotmail.com","testTeam2","dtargaryen@gmail.com","ICT30002", "Semester 1", "2019", @ValueTeamMemberID);
-- Team continued 
-- adding the user Example@hotmail.com as the project manager of testTeam2 after he was assigned to that team

call TCABSTeamSetTeamProjectManager("testTeam2","dtargaryen@gmail.com","ICT30002", "Semester 1", "2019","Example@hotmail.com");
call TCABSTeamSetTeamProjectManager("BesttestTeam","dtargaryen@gmail.com","ICT30002", "Semester 1", "2019","bestExample@hotmail.com");
*/

               DELIMITER //
create Procedure TCABSPROJECTROLEAddProjectRole(in EnteredRoleName varchar(255),in EnteredSalary double)
	BEGIN
		call TCABSValidateNameString(EnteredRoleName);
        if (EnteredSalary < 0) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "A Project roles salary can not be negative";
        end if;
        
        if ((select count(*) from ProjectRole where Rolename = EnteredRoleName) >= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Entered Role already exists";
        end if;
        insert into ProjectRole (Rolename,Salary) values (EnteredRoleName,EnteredSalary);
	END //
 DELIMITER ;
 
                DELIMITER //
create Procedure TCABSPROJECTROLESetRoleDescription(in EnteredRoleName varchar(255),in EnteredRoleDesciption text)
	BEGIN
		
        if (char_length(EnteredRoleName) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Role name entered";
        end if;
        
        if (char_length(EnteredRoleDesciption) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Role description entered";
        end if;
        
        if ((select count(*) from ProjectRole where Rolename = EnteredRoleName) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Entered Role Does not exist";
        end if;
        update ProjectRole set RoleDescription = EnteredRoleDesciption where Rolename = EnteredRoleName;
	END //
 DELIMITER ;
 -- Project Roles
 -- adds a project role with an associated salary per hour
 call TCABSProjectRoleAddProjectRole("Project Manager", 56.60);
  call TCABSProjectRoleAddProjectRole("Developer", 30);
 -- sets Project role description
 call TCABSPROJECTROLESetRoleDescription("Project Manager", "Charged with managing high level group tasks and organisation");

-- needs to change after PHP file development
               DELIMITER //
create Procedure TCABSPROJECTAddProject(in EnteredProjectName varchar(255))
	BEGIN
        if (char_length(EnteredProjectName) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Project name entered";
        end if;
        if ((select count(*) from Project where ProjectName = EnteredProjectName)>= 1) then 
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "That Project name already exists";
        end if;
        insert into Project (ProjectName) values (EnteredProjectName);
	END //
 DELIMITER ;
 
                DELIMITER //
create Procedure TCABSPROJECTSetProjectDescription(in EnteredProjectName varchar(255), in EnteredProjectDescription text)
	BEGIN
       if (char_length(EnteredProjectName) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Project name entered";
        end if;
        
        if (char_length(EnteredProjectDescription) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Project description entered";
        end if;
        
        if ((select count(*) from Project where ProjectName = EnteredProjectName) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Entered Project Does not exist";
        end if;
        update Project set ProjectDescription = EnteredProjectDescription where ProjectName = EnteredProjectName;
	END //
 DELIMITER ;

DELIMITER //
create Procedure TCABS_Project_Add(in EnteredProjectName varchar(255), in EnteredProjectDescription text)
	BEGIN
				
		DECLARE EXIT HANDLER FOR 45000 ROLLBACK;	

 		START TRANSACTION;	
			call TCABSPROJECTAddProject(EnteredProjectName);
			call TCABSPROJECTSetProjectDescription(EnteredProjectName, EnteredProjectDescription);
		COMMIT;	
	END //
 DELIMITER ;
 -- Project
 -- adds a project called Big Test Project
 call TCABSPROJECTAddProject("Big Test Project");
 -- sets big test projects description
 call TCABSPROJECTSetProjectDescription("Big Test Project", "Build a database for a client");
 
                DELIMITER //
create Procedure TCABSOFFERINGPROJECTAddProjectOffering(in EnteredProjectName varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255))
	BEGIN
       if (char_length(EnteredProjectName) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Project name entered";
        end if;
        
        call TCABSUNITOFFERINGGetKey(SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @ValuesunitOfferingID);
        
        if ((select count(*) from Project where ProjectName = EnteredProjectName) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Entered Project Does not exist";
        end if;
        
        insert OfferingProject (UnitOfferingID,ProjectName) values (@ValuesunitOfferingID,EnteredProjectName);
	END //
 DELIMITER ;
-- Project offering
-- add the Project X to the subject Y in the period of Z for the year of A
-- call  TCABSOFFERINGPROJECTAddProjectOffering("Big Test Project","ICT30002", "Semester 1", "2019");

  DELIMITER //
create Procedure TCABSTEAMPROJECTAddTeamProject(in EnteredProjectName varchar(255),in TeamName varchar(255), in ConvenorEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255))
	BEGIN
       if (char_length(EnteredProjectName) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Project name entered";
        end if;
        
        call TCABSTeamGetTeamKey(TeamName,ConvenorEmail,SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @ValuesTeamID);
        
        if ((select count(*) from Project where ProjectName = EnteredProjectName) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Entered Project Does not exist";
        end if;
        
        insert TeamProjects (TeamID,ProjectName) values (@ValuesTeamID,EnteredProjectName);
	END //
 DELIMITER ;

  DELIMITER //
create Procedure TCABSTEAMPROJECTGetTeamProjectID(in EnteredProjectName varchar(255),in TeamName varchar(255), in ConvenorEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255),out ValueTeamProjectID int)
	BEGIN
       if (char_length(EnteredProjectName) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Project name entered";
        end if;
        
        call TCABSTeamGetTeamKey(TeamName,ConvenorEmail,SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @ValuesTeamID);
        
        select teamprojectid into ValueTeamProjectID from TeamProjects where TeamID = @ValuesTeamID and ProjectName = EnteredProjectName;
        if (ValueTeamProjectID is null) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Entered team project doesn't exist";
        end if;
        
	END //
 DELIMITER ;

  DELIMITER //
create Procedure TCABSTEAMPROJECTSetProjectBudget(in EnteredProjectBudget double,in EnteredProjectName varchar(255),in TeamName varchar(255), in ConvenorEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255))
	BEGIN
       if (char_length(EnteredProjectName) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Project name entered";
        end if;
        
        if (EnteredProjectBudget < 0) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Project budget can't be negative";
        end if;
        
        call TCABSTEAMPROJECTGetTeamProjectID(EnteredProjectName,TeamName, ConvenorEmail,SelectedUnitCode, SelectedOfferingterm, SelectedOfferingYear,@ValueTeamProjectID);
        
        update TeamProjects set Budget = EnteredProjectBudget where TeamProjectID = @ValueTeamProjectID;
	END //
 DELIMITER ;
 
/*
-- team projects
-- the project X is allocated to the team called Y which has the supervisor with the email Z. The team is in the subject A for the period of B for the year of C
call TCABSTEAMPROJECTAddTeamProject("Big Test Project","testTeam2", "dtargaryen@gmail.com","ICT30002", "Semester 1", "2019");
call TCABSTEAMPROJECTAddTeamProject("Big Test Project","besttestTeam", "dtargaryen@gmail.com","ICT30002", "Semester 1", "2019");
-- gets the key of the team project this shouldn't be used outside of procedures 
call TCABSTEAMPROJECTGetTeamProjectID("Big Test Project","testTeam2", "dtargaryen@gmail.com","ICT30002", "Semester 1", "2019",@ValueTeamProjectID);
-- sets a budget of X for the project Y to the team called Z which has the supervisor with the email A. The team is in the subject B for the period of C for the year of D
call TCABSTEAMPROJECTSetProjectBudget(36000,"Big Test Project","testTeam2", "dtargaryen@gmail.com","ICT30002", "Semester 1", "2019");
call TCABSTEAMPROJECTSetProjectBudget(10,"Big Test Project","besttestTeam", "dtargaryen@gmail.com","ICT30002", "Semester 1", "2019");
*/


                DELIMITER //
create Procedure TCABSTASKAddNewTask(in StudentEmail varchar(255),in ProjectName varchar(255),in Teamname varchar(255), in SupervisorEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255), in MinuteTime int, in Taskdescription text, in EnteredRoleName varchar(255))
	BEGIN
		Declare varProjectTaskID int;
        if (char_length(EnteredRoleName) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Role entered";
        end if;
         if (char_length(Taskdescription) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Task description entered";
        end if;
        if (MinuteTime < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Task must be one or more minutes long ";
        end if;
        
        if ((select count(*) from ProjectRole where Rolename = EnteredRoleName) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Entered project role doesn't exist";
        end if;
		call TCABSTEAMMEMBERGetTeamMember(StudentEmail,Teamname,SupervisorEmail,SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @ValueTeamMemberID);
        call TCABSTEAMPROJECTGetTeamProjectID(ProjectName,Teamname,SupervisorEmail,SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear,@ValueTeamProjectID);
        -- select * from task where TeamProjectID =1 order by ProjectTaskID Desc Limit 1
        
        select ProjectTaskID into varProjectTaskID from task where TeamProjectID = @ValueTeamProjectID order by ProjectTaskID Desc Limit 1;
        if (varProjectTaskID is null) then
			set varProjectTaskID = 1;
		else
			set varProjectTaskID = varProjectTaskID + 1;
        end if;
        insert into Task (TeamMemberID,ProjectTaskID,Rolename,TeamProjectID,TaskDetails,TimeTaken) values (@ValueTeamMemberID,varProjectTaskID,EnteredRoleName,@ValueTeamProjectID,Taskdescription,MinuteTime);
	END //
 DELIMITER ;
 

/* 
 -- Tasks
 -- for the student user X works on the group project Y for the team called Z that has the supervisor of A which watched over this team for the subject B that is offered in period C within the Year D. The user X has submitted a task for E minutes of work that has the description of F and the Role type of G
call TCABSTASKAddNewTask("Example@hotmail.com","Big Test Project","testTeam2","dtargaryen@gmail.com","ICT30002", "Semester 1", "2019",7,"Assigning team tasks","Project Manager");
call TCABSTASKAddNewTask("Example@hotmail.com","Big Test Project","testTeam2","dtargaryen@gmail.com","ICT30002", "Semester 1", "2019",9,"Assigning team tasks","Project Manager");
call TCABSTASKAddNewTask("bestExample@hotmail.com","Big Test Project","besttestTeam","dtargaryen@gmail.com","ICT30002", "Semester 1", "2019",20,"Assigning team tasks","Project Manager");
call TCABSTASKAddNewTask("bestExample@hotmail.com","Big Test Project","besttestTeam","dtargaryen@gmail.com","ICT30002", "Semester 1", "2019",20,"Assigning team tasks","Developer");
-- think up a method for logging changes
*/

                DELIMITER //
create Procedure TCABSSUPERVISORMEETINGAddMeeting(in StartTime datetime, in EndTime datetime, in Location text, in Teamname varchar(255), in SupervisorEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255))
	BEGIN
		Declare TimeresticEnd,TimerestricStart date;
        
		if (char_length(Location) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Location entered";
        end if;
        
        
        if (StartTime <= sysdate()) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Cannot schedual a time behind the current date and time";
        end if;
        
        if (StartTime >= EndTime) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Start time cannot occur after end time";
        end if;
        
		call TCABSTeamGetTeamKey(TeamName,SupervisorEmail,SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @ValuesTeamID);
		
        select StartDate,Enddate into TimerestricStart,TimeresticEnd from TeachingPeriod where Term = SelectedOfferingterm and Year = SelectedOfferingyear;
        
        if (TimerestricStart >= StartTime) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Cannot schedual a time before subject period has started";
        end if;
        if (TimeresticEnd <= EndTime) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Cannot schedual a time after subject period has ended";
        end if;
        
        call TCABSSUPERVISORMEETINGCheckForConflicts(StartTime,EndTime,SupervisorEmail);
        
		insert into SupervisorMeeting(TeamID, StartTime, EndTime , Location) values (@ValuesTeamID,StartTime, EndTime ,Location);
END //
 DELIMITER ;
 
               DELIMITER //
create Procedure TCABSSUPERVISORMEETINGCheckForConflicts(in EnteredStartTime datetime, in EnteredEndTime datetime,in SupervisorEmail varchar(255))
	BEGIN
        DROP TABLE IF EXISTS `Supervisoroffers`;
        create temporary table Supervisoroffers
        select * from SupervisorMeeting natural join team; 
        if ((select count(*) from Supervisoroffers natural join offeringstaff where 
        username = SupervisorEmail and ((StartTime <= EnteredStartTime and EnteredStartTime <= EndTime) 
        or (EndTime >= EnteredEndTime and EnteredEndTime >= StartTime))) >= 1) then
			drop temporary table Supervisoroffers;
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "That period has already been booked for this supervisor";
        end if;
        drop temporary table Supervisoroffers;
END //
 DELIMITER ;
 
                DELIMITER //
create Procedure TCABSSUPERVISORMEETINGGetMeetingKey(in EnteredStartTime datetime, in Teamname varchar(255), in SupervisorEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255), out ValueSuppervisorMeetingKey int)
	BEGIN
        
        call TCABSTeamGetTeamKey(TeamName,SupervisorEmail,SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @ValuesTeamID);
		select MeetingID into ValueSuppervisorMeetingKey from SupervisorMeeting where TeamID = @ValuesTeamID and StartTime = EnteredStartTime;
        
        if (ValueSuppervisorMeetingKey is null) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Invalid Team meeting Time and Team combination";
        end if;
END //
 DELIMITER ;
 
/*
 -- supervisor meeting 
 -- add a meeting with the start Time and date of X and the finish time and date of Y in the location of Z for the team called A with the supervisor of B for the subject of C offered in the period of D in the year of E
 call TCABSSUPERVISORMEETINGAddMeeting('2019-07-14 23:40:00','2019-07-14 23:45:00',"Tutorial room","testTeam2","dtargaryen@gmail.com","ICT30002", "Semester 1", "2019");
 call TCABSSUPERVISORMEETINGAddMeeting('2019-07-15 00:01:00','2019-07-15 00:03:00',"Tutorial room","testTeam2","dtargaryen@gmail.com","ICT30002", "Semester 1", "2019");
 call TCABSSUPERVISORMEETINGAddMeeting('2019-07-14 23:45:01','2019-07-14 23:50:00',"Tutorial room","besttestTeam","dtargaryen@gmail.com","ICT30002", "Semester 1", "2019");
 call TCABSSUPERVISORMEETINGAddMeeting('2019-07-15 23:46:00','2019-07-15 23:47:00',"Tutorial room","Mortal combat","dtargaryen@gmail.com","ICT30003", "Semester 1", "2019");
 call TCABSSUPERVISORMEETINGAddMeeting('2019-07-15 23:48:00','2019-07-15 23:49:00',"Tutorial room","Mortal combat","dtargaryen@gmail.com","ICT30003", "Semester 1", "2019");

-- gets the Meeting ID For supervisor meeting This shouldn't be used outside of Procedures and functions
call TCABSSUPERVISORMEETINGGetMeetingKey('2019-07-14 23:40:00',"testTeam2","dtargaryen@gmail.com","ICT30002", "Semester 1", "2019",@ValueSuppervisorMeetingKey);
*/

                  DELIMITER //
create Procedure TCABSMEETINGATTENDIEESAddAttendiee(in StudentEmail Varchar(255),in EnteredStartTime datetime, in Teamname varchar(255), in SupervisorEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255))
	BEGIN
        call TCABSSUPERVISORMEETINGGetMeetingKey(EnteredStartTime,Teamname,SupervisorEmail,SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear,@ValueSuppervisorMeetingKey);
        call TCABSTEAMMEMBERGetTeamMember(StudentEmail,Teamname,SupervisorEmail,SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @ValueTeamMemberID);
		
        insert into MeetingAttendees(TeamMemberID,MeetingID) values (@ValueTeamMemberID,@ValueSuppervisorMeetingKey);
END //
 DELIMITER ;
 
                   DELIMITER //
create Procedure TCABSMEETINGATTENDIEESGetAttendieeKey(in StudentEmail Varchar(255),in EnteredStartTime datetime, in Teamname varchar(255), in SupervisorEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255), out AttendieeMeetingKey int)
	BEGIN
   
        call TCABSSUPERVISORMEETINGGetMeetingKey(EnteredStartTime,Teamname,SupervisorEmail,SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear,@ValueSuppervisorMeetingKey);
        call TCABSTEAMMEMBERGetTeamMember(StudentEmail,Teamname,SupervisorEmail,SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @ValueTeamMemberID);
        select MeetingAttendeeID into AttendieeMeetingKey from MeetingAttendees where TeamMemberID = @ValueTeamMemberID and MeetingID = @ValueSuppervisorMeetingKey;
        if (AttendieeMeetingKey is null) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "invalid Meeting and Team member Key";
        end if;
END //
 DELIMITER ;
/*
 -- record the attendence of the team member X for the meeting starting at Y for the team called Z whihc is being supervised by A for the subject B in the period of C in the year of D
 call TCABSMEETINGATTENDIEESAddAttendiee("Example@hotmail.com",'2019-07-14 23:40:00',"testTeam2","dtargaryen@gmail.com","ICT30002", "Semester 1", "2019");
 -- gets the meetingattendiee key (this shouldn't be called outside of a procedure)
 call TCABSMEETINGATTENDIEESGetAttendieeKey("Example@hotmail.com",'2019-07-14 23:40:00',"testTeam2","dtargaryen@gmail.com","ICT30002", "Semester 1", "2019",@AttendieeMeetingKey);
 */

                   DELIMITER //
create Procedure STUDENTPEERASSESSMENTAddNewAssessment(in EnteredName varchar(255))
	BEGIN
        if (char_length(EnteredName) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Assessment Name";
        end if;
        
        if ((select count(*) from StudentPeerAssessment where AssessmentName = EnteredName) >= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered Assessment Name already exists";
        end if;
        
        insert into StudentPeerAssessment(AssessmentName) values (EnteredName);
        
END //
 DELIMITER ;
 
                    DELIMITER //
create Procedure STUDENTPEERASSESSMENTGetAssessmentKey(in EnteredName varchar(255), out ValueSPAKey int)
	BEGIN
        if (char_length(EnteredName) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Assessment Name entered";
        end if;
        
        select SPAID into ValueSPAKey from StudentPeerAssessment where AssessmentName = EnteredName;
		
        
        if (ValueSPAKey is null) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "There is no Peer assessment with that name";
        end if;
        
END //
 DELIMITER ;

/*
-- adds a new peer assessment instence 
call STUDENTPEERASSESSMENTAddNewAssessment("AssessMe");
-- gets the peer assessment instence
call STUDENTPEERASSESSMENTGetAssessmentKey("AssessMe",@ValueSPAKey);
*/

                   DELIMITER //
create Procedure PEERASSESSMENTFEILDAddFeild(in EnteredName varchar(255), in enteredfeildName varchar(255), in EnteredFeildDescription text)
	BEGIN
        if (char_length(EnteredFeildDescription) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Feild Description entered";
        end if;
		if (char_length(enteredfeildName) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Feild name entered";
        end if;
        call STUDENTPEERASSESSMENTGetAssessmentKey(EnteredName,@ValueSPAKey);
        if ((select count(*) from PeerAssessmentFeild where FeildName = enteredfeildName and SPAID = @ValueSPAKey ) >= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered Assessment feild already exists for this peer assessment";
        end if;
        insert into PeerAssessmentFeild(SPAID,FeildName,FeildDescription) values (@ValueSPAKey,enteredfeildName,EnteredFeildDescription);
END //
 DELIMITER ;
 
                    DELIMITER //
create Procedure PeerAssessmentFeildGetFeildKey(in EnteredName varchar(255), in enteredfeildName varchar(255), out ValueFeildID int)
	BEGIN
		if (char_length(enteredfeildName) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Feild name entered";
        end if;
        call STUDENTPEERASSESSMENTGetAssessmentKey(EnteredName,@ValueSPAKey);
        if ((select count(*) from PeerAssessmentFeild where FeildName = enteredfeildName and SPAID = @ValueSPAKey ) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered Assessment feild Doesn't exist";
        end if;
        select FeildID into ValueFeildID from PeerAssessmentFeild where FeildName = enteredfeildName and SPAID = @ValueSPAKey;
END //
 DELIMITER ;
 
/*
 call PEERASSESSMENTFEILDAddFeild("AssessMe","Name","Enter your name here");
 
 call PeerAssessmentFeildGetFeildKey("AssessMe","Name",@ValueFeildID);
 */
 
                     DELIMITER //
create Procedure SPAINSTENCEAddInstence(in EnteredName varchar(255), in EnteredAssessmentDate date, in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255))
	BEGIN
		
        declare TimerestricStart,TimeresticEnd date;
        
        call TCABSUNITOFFERINGGetKey(SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @ValuesunitOfferingID);
        call STUDENTPEERASSESSMENTGetAssessmentKey(EnteredName,@ValueSPAKey);
        
        select StartDate,Enddate into TimerestricStart,TimeresticEnd from TeachingPeriod where Term = SelectedOfferingterm and Year = SelectedOfferingyear;
        
        if (EnteredAssessmentDate < TimerestricStart) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "you cannot schedual a peer assessment before the period occurs";
        end if;
        
        if (EnteredAssessmentDate > TimeresticEnd) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "you cannot schedual a peer assessment after the period occurs";
        end if;
        
        if ((select count(*) from SPAInstence where UnitOfferingID = @ValuesunitOfferingID and SPAID = @ValueSPAKey and AssessmentDate = EnteredAssessmentDate) >= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered Assessment already exist";
        end if;
        insert into SPAInstence(UnitOfferingID,SPAID,AssessmentDate) values (@ValuesunitOfferingID,@ValueSPAKey,EnteredAssessmentDate);
END //
 DELIMITER ;
 
                      DELIMITER //
create Procedure SPAINSTENCEGetInstenceKey(in EnteredName varchar(255), in EnteredAssessmentDate date, in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255), out valueSPAInstenceKey int)
	BEGIN
		-- AssessmentDate
      
        
		call TCABSUNITOFFERINGGetKey(SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @ValuesunitOfferingID);
        call STUDENTPEERASSESSMENTGetAssessmentKey(EnteredName,@ValueSPAKey);
        
        select SPAInstenceID into valueSPAInstenceKey from SPAInstence where UnitOfferingID = @ValuesunitOfferingID and SPAID = @ValueSPAKey and AssessmentDate = EnteredAssessmentDate;
		
        if (valueSPAInstenceKey is null) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered Peer assessment and Student team member combination doesn't exist";
        end if;
END //
 DELIMITER ;
/*
 -- add the peer reveiw instence of X with the due date of Y for the user team member of Z in the team of A with the superviosor of B for the subject of C in the period of D in the year of E
  call SPAINSTENCEAddInstence("AssessMe",'2019-07-14',"ICT30002", "Semester 1", "2019");
  -- This should only be used in procedurers
  call SPAINSTENCEGetInstenceKey("AssessMe",'2019-07-14',"ICT30002", "Semester 1", "2019",@valueSPAInstenceKey);
	*/

                      DELIMITER //
create Procedure GenerateAccrualTasks()
	BEGIN
		 
        DROP TABLE IF EXISTS `ProjectCosts`;
        create temporary table ProjectCosts
        -- add entry verification
        select TeamProjectID,sum(TimeTaken) as Total_Time_Spent, sum(TimeTaken * Salary/60) as Pay from task natural join ProjectRole where logged = true group by task.TeamProjectID, Rolename;
END //
 DELIMITER ;



DELIMITER //
create Procedure REPORTUnitOfferingGenerateBudget(in Unitcode varchar(255),in PeriodName Varchar(255),in periodyear varchar(255))
	BEGIN
		 call TCABSUNITOFFERINGGetKey(Unitcode, PeriodName, periodyear, @ValuesunitOfferingID);
         call GenerateAccrualTasks();
		 select TeamName,ProjectName,Budget,Round(Total_Pay,2) as Expense_To_Date,Budget - Round(Total_Pay,2) as Remaining_Budget from team natural join teamProjects t1 inner join (select TeamProjectID, sum(Pay) as Total_Pay from ProjectCosts group by TeamProjectID) t2 on t1.TeamProjectID = t2.TeamProjectID natural join offeringStaff where UnitOfferingID = @ValuesunitOfferingID;
END //
 DELIMITER ;
 
DELIMITER //
create Procedure REPORTUnitOfferingOverVeiw(in Unitcode varchar(255),in PeriodName Varchar(255),in periodyear varchar(255))
	BEGIN
		 call TCABSUNITOFFERINGGetKey(Unitcode, PeriodName, periodyear, @ValuesunitOfferingID);
         call GenerateAccrualTasks();
		select TeamName,Total_Time_Spent,Budget - Round(Total_Pay,2) as Remaining_Budget, Last_Meeting_Date as Last_Meeting from team natural join teamProjects t1 inner join (select team.teamID,max(SupervisorMeeting.StartTime) as Last_Meeting_Date from team natural join SupervisorMeeting group by team.teamid)t3 on t1.TeamID = t3.TeamID inner join (select TeamProjectID,sum(Total_Time_Spent) as Total_Time_Spent, sum(Pay) as Total_Pay from ProjectCosts group by TeamProjectID) t2 on t1.TeamProjectID = t2.TeamProjectID natural join offeringStaff where UnitOfferingID = @ValuesunitOfferingID;
END //
 DELIMITER ;
-- report 7
-- call REPORTUnitOfferingGenerateBudget("ICT30002", "Semester 1", "2019");
-- report 9
-- call REPORTUnitOfferingOverVeiw("ICT30002", "Semester 1", "2019");


   DELIMITER //
create Procedure TCABSTASKSGetTaskID(in EnteredTaskID int, in EnteredProjectName varchar(255),in TeamName varchar(255), in ConvenorEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255),out ValuetaskID int, out ValueTeamProjectID int)
	BEGIN
       if (char_length(EnteredTaskID) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no TaskID entered";
        end if;
        call TCABSTEAMPROJECTGetTeamProjectID(EnteredProjectName,TeamName,ConvenorEmail,SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear,@ValueTeamProjectID);

        if ((select count(*) from task where Projecttaskid = EnteredTaskID and TeamProjectID = @ValueTeamProjectID) != 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Entered combination of task and team Project doesn't exist";
		end if;
        set ValuetaskID = EnteredTaskID;
        set ValueTeamProjectID = @ValueTeamProjectID;
        
	END //
 DELIMITER ;
 
    DELIMITER //
create Procedure TCABSTASKSRegistorTask(in EnteredTaskID int, in EnteredProjectName varchar(255),in TeamName varchar(255), in SupervisorEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255))
	BEGIN
       call TCABSTASKSGetTaskID(EnteredTaskID,EnteredProjectName,TeamName,SupervisorEmail,SelectedUnitCode,SelectedOfferingterm,SelectedOfferingyear,@ValuetaskID,@ValueTeamProjectID);
       update Task set logged = true where ProjectTaskid = @ValuetaskID and TeamProjectID = @ValueTeamProjectID;
        
	END //
 DELIMITER ; 
 
     DELIMITER //
create Procedure TCABSTASKSModifyTask(in EnteredTaskID int, in EnteredProjectName varchar(255),in TeamName varchar(255), in SupervisorEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255), in NewTimeTaken int, in TaskRole varchar(255))
	BEGIN
    if (char_length(TaskRole) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Role entered";
	end if;
    if (NewTimeTaken < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Task must be one or more minutes long ";
	end if;
    if ((select count(*) from ProjectRole where Rolename = TaskRole) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Entered project role doesn't exist";
	end if;
    
       call TCABSTASKSGetTaskID(EnteredTaskID,EnteredProjectName,TeamName,SupervisorEmail,SelectedUnitCode,SelectedOfferingterm,SelectedOfferingyear,@ValuetaskID,@ValueTeamProjectID);
       update Task set Altered = true,TimeTaken = NewTimeTaken,Rolename = TaskRole where ProjectTaskid = @ValuetaskID and TeamProjectID = @ValueTeamProjectID;
        
	END //
 DELIMITER ; 
 
/*
call TCABSTASKSGetTaskID(1,"Big Test Project","testTeam2", "dtargaryen@gmail.com","ICT30002", "Semester 1", "2019",@ValuetaskID,@ValueTeamProjectID);
-- marks the task as logged 
call TCABSTASKSRegistorTask(1,"Big Test Project","testTeam2", "dtargaryen@gmail.com","ICT30002", "Semester 1", "2019");
-- changes the time and role of a selected task
call TCABSTASKSModifyTask(1,"Big Test Project","testTeam2", "dtargaryen@gmail.com","ICT30002", "Semester 1", "2019",30,"Developer");
*/

     DELIMITER //
create Procedure TCABSMEETINGSetAgender(EnteredStartTime datetime, in Teamname varchar(255), in SupervisorEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255),NewAgender text)
	BEGIN
    if (char_length(NewAgender) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Agender entered";
	end if;
    call TCABSSUPERVISORMEETINGGetMeetingKey(EnteredStartTime,Teamname, SupervisorEmail, SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear,@ValueSuppervisorMeetingKey);
	update Supervisormeeting set Agender = NewAgender where Meetingid = @ValueSuppervisorMeetingKey;      
	END //
 DELIMITER ; 
 
      DELIMITER //
create Procedure TCABSMEETINGSetComments(EnteredStartTime datetime, in Teamname varchar(255), in SupervisorEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255),NewComments text)
	BEGIN
    if (char_length(NewComments) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Comments entered";
	end if;
    call TCABSSUPERVISORMEETINGGetMeetingKey(EnteredStartTime,Teamname, SupervisorEmail, SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear,@ValueSuppervisorMeetingKey);
	update Supervisormeeting set Comments = NewComments where Meetingid = @ValueSuppervisorMeetingKey;      
	END //
 DELIMITER ; 
 
       DELIMITER //
create Procedure TCABSMEETINGSetMeetingMinutes(EnteredStartTime datetime, in Teamname varchar(255), in SupervisorEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255),MeetingMinutes text)
	BEGIN
    if (char_length(MeetingMinutes) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "nothing was entered for Meeting Minutes";
	end if;
    call TCABSSUPERVISORMEETINGGetMeetingKey(EnteredStartTime,Teamname, SupervisorEmail, SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear,@ValueSuppervisorMeetingKey);
	update Supervisormeeting set Meeting_Minutes = MeetingMinutes where Meetingid = @ValueSuppervisorMeetingKey;      
	END //
 DELIMITER ; 
 
        DELIMITER //
create Procedure TCABSMEETINGSetLocation(EnteredStartTime datetime, in Teamname varchar(255), in SupervisorEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255),NewLocation varchar(255))
	BEGIN
    call TCABSSUPERVISORMEETINGGetMeetingKey(EnteredStartTime,Teamname, SupervisorEmail, SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear,@ValueSuppervisorMeetingKey);
	update Supervisormeeting set Location = NewLocation where Meetingid = @ValueSuppervisorMeetingKey;      
	END //
 DELIMITER ; 
 
         DELIMITER //
create Procedure TCABSMEETINGChangeTimeDisplay(EnteredStartTime datetime, in Teamname varchar(255), in SupervisorEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255))
	BEGIN
    call TCABSSUPERVISORMEETINGGetMeetingKey(EnteredStartTime,Teamname, SupervisorEmail, SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear,@ValueSuppervisorMeetingKey);
	update Supervisormeeting set Display_Time = not Display_Time where Meetingid = @ValueSuppervisorMeetingKey;    
    
	END //
 DELIMITER ; 
 
          DELIMITER //
create Procedure TCABSMEETINGChangeLocationDisplay(EnteredStartTime datetime, in Teamname varchar(255), in SupervisorEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255))
	BEGIN
    call TCABSSUPERVISORMEETINGGetMeetingKey(EnteredStartTime,Teamname, SupervisorEmail, SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear,@ValueSuppervisorMeetingKey);
	update Supervisormeeting set Display_Loc = not Display_Loc where Meetingid = @ValueSuppervisorMeetingKey;    
    
	END //
 DELIMITER ; 
 
           DELIMITER //
create Procedure TCABSMEETINGChangeBothDisplay(EnteredStartTime datetime, in Teamname varchar(255), in SupervisorEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255))
	BEGIN
    call TCABSMEETINGChangeLocationDisplay(EnteredStartTime,Teamname, SupervisorEmail, SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear);
    call TCABSMEETINGChangeTimeDisplay(EnteredStartTime,Teamname, SupervisorEmail, SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear);
	END //
 DELIMITER ; 
 
           DELIMITER //
create Procedure TCABSMEETINGChangeApproval(EnteredStartTime datetime, in Teamname varchar(255), in SupervisorEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255))
	BEGIN
    call TCABSSUPERVISORMEETINGGetMeetingKey(EnteredStartTime,Teamname, SupervisorEmail, SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear,@ValueSuppervisorMeetingKey);
	update Supervisormeeting set Approval = not Approval where Meetingid = @ValueSuppervisorMeetingKey;    
    
	END //
 DELIMITER ; 
 
            DELIMITER //
create Procedure TCABSMEETINGChangeTime(EnteredOriginalStartTime datetime, in Teamname varchar(255), in SupervisorEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255), in newStartTime datetime, in newEndTime datetime)
	BEGIN
    declare TimerestictStart,TimerestictEnd dateTime;
    
    call TCABSSUPERVISORMEETINGGetMeetingKey(EnteredOriginalStartTime,Teamname, SupervisorEmail, SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear,@ValueSuppervisorMeetingKey);
	if ((select count(*) from MeetingAttendees where MeetingID = @ValueSuppervisorMeetingKey) >= 1) then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "This Meeting has already occured";
    end if;
    select StartDate,Enddate into TimerestictStart,TimerestictEnd from TeachingPeriod where Term = SelectedOfferingterm and Year = SelectedOfferingyear;
        
        if (TimerestictStart >= newStartTime) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Cannot schedual a time before subject period has started";
        end if;
        if (TimerestictEnd <= newEndTime) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Cannot schedual a time after subject period has ended";
        end if;
        
        call TCABSSUPERVISORMEETINGCheckForConflicts(newStartTime,newEndTime,SupervisorEmail);
        
        update Supervisormeeting set StartTime = newStartTime, EndTime = newEndTime where MeetingID = @ValueSuppervisorMeetingKey;
    
	END //
 DELIMITER ; 
 
/*
-- changes both Display_Time and Loc_Display to their oposite state (eg. true to false) for students to veiw details (both start as false)
call TCABSMEETINGChangeBothDisplay('2019-07-14 23:40:00',"testTeam2","dtargaryen@gmail.com","ICT30002", "Semester 1", "2019");
-- TCABSMEETINGChangeLocationDisplay changes Loc_Display to opposite of current state
call TCABSMEETINGChangeLocationDisplay('2019-07-14 23:40:00',"testTeam2","dtargaryen@gmail.com","ICT30002", "Semester 1", "2019");
-- TCABSMEETINGChangeTimeDisplay changes Time_Display to opposite of current state
call TCABSMEETINGChangeTimeDisplay('2019-07-14 23:40:00',"testTeam2","dtargaryen@gmail.com","ICT30002", "Semester 1", "2019");
-- switches registored approval of students meeting minutes from supervisor
call TCABSMEETINGChangeApproval('2019-07-14 23:40:00',"testTeam2","dtargaryen@gmail.com","ICT30002", "Semester 1", "2019");
-- student enters plan for meeting
call TCABSMEETINGSetAgender('2019-07-14 23:40:00',"testTeam2","dtargaryen@gmail.com","ICT30002", "Semester 1", "2019","reveiw over progress");
-- student enters record of what decsions came out of the meeting 
call TCABSMEETINGSetMeetingMinutes('2019-07-14 23:40:00',"testTeam2","dtargaryen@gmail.com","ICT30002", "Semester 1", "2019","There is plentty more to do!");
-- supervisor enters record of what decsions came out of the meeting (no other user should be able to see this)
call TCABSMEETINGSetComments('2019-07-14 23:40:00',"testTeam2","dtargaryen@gmail.com","ICT30002", "Semester 1", "2019","This Team Deserves a HD!");
-- changes the location set for this meeting
call TCABSMEETINGSetLocation('2019-07-14 23:40:00',"testTeam2","dtargaryen@gmail.com","ICT30002", "Semester 1", "2019","My Office");
-- changes the meeting time (given the supervisor isn't booked)
call TCABSMEETINGChangeTime('2019-07-15 00:01:00',"testTeam2","dtargaryen@gmail.com","ICT30002", "Semester 1", "2019",'2019-07-16 23:40:00', '2019-07-16 23:40:05');

*/
-- select * from Supervisormeeting;
-- call TCABSSUPERVISORMEETINGGetMeetingKey('2019-07-14 23:40:00',"testTeam2","dtargaryen@gmail.com","ICT30002", "Semester 1", "2019",@ValueSuppervisorMeetingKey);
-- in EnteredStartTime datetime, in Teamname varchar(255), in SupervisorEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255), out ValueSuppervisorMeetingKey int

DELIMITER //
create Procedure TCABSUpdateTeamSupervisor(in EnteredTeamname varchar(255), in UserEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255), in NewSupervisorsEmail varchar(255))
    BEGIN

        call TCABSTeamGetTeamKey(EnteredTeamname, UserEmail, SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @ValuesTeamID);
        call TCABSOFFERINGSTAFFGetOfferingStaffKey(NewSupervisorsEmail, SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear,@ValueOfferingStaff);
        update team set offeringstaffid = @ValueOfferingStaff where teamid = @ValuesTeamID;
END//
 DELIMITER ;

DELIMITER //
 Create Procedure TCABSUpdateFullTeam(in EnteredTeamname varchar(255), in UserEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255), in NewSupervisorsEmail varchar(255),in newteamname varchar(255),in ProjectManagerUser varchar(255))
 begin
        call TCABSUpdateTeamSupervisor(EnteredTeamname, UserEmail, SelectedUnitCode,SelectedOfferingterm, SelectedOfferingyear, NewSupervisorsEmail);
        call TCABSTeamSetTeamName(EnteredTeamname, UserEmail, SelectedUnitCode,SelectedOfferingterm, SelectedOfferingyear, newteamname);
        call TCABSTeamSetTeamProjectManager(EnteredTeamname, UserEmail, SelectedUnitCode,SelectedOfferingterm, SelectedOfferingyear, ProjectManagerUser);
 end //
 DELIMITER ;

 DELIMITER //
create or replace Procedure TCABSTeamDeleteTeam(in SelectedTeamName varchar(255), in UserEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255))
	BEGIN

		if (char_length(UserEmail) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no User Email entered";
        end if;
        if (char_length(SelectedTeamName) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no team name entered";
        end if;
        if ((select count(*) from Users where email = UserEmail) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered User Email does not exist";
        end if;
        if ((select count(*) from UserCat where userType = "supervisor" and email = UserEmail) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "This user is not currently a supervisor of any team";
        end if;
        if (TCABSDateValiadationCheckUnitOfferingVsSystem(SelectedOfferingterm,SelectedOfferingyear)) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "you can not update a team to a unit which has already concluded";
        end if;

		call TCABSTeamGetTeamKey(SelectedTeamName, UserEmail, SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @ValuesTeamID);

		if ((select COUNT(*) from SupervisorMeeting WHERE @ValuesTeamID = TeamID) >= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Entered Team already having a team meeting cannot be deleted.";
		end if;

		if ((select COUNT(*) from TeamProjects WHERE @ValuesTeamID = TeamID) >= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Entered Team already having a team project cannot be deleted.";
		end if;
		
		if ((select COUNT(*) from TeamMember WHERE @ValuesTeamID = TeamID) >= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Entered Team already having a team member cannot be deleted.";
		end if;

		if (select count(*) from Team where TeamID = @ValuesTeamID) >= 0 then
			DELETE FROM Team
			WHERE TeamID = @ValuesTeamID;
		else
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "There is no Team with the entered Team";
		end if;
	END //
 DELIMITER;

  DELIMITER //
create or replace Procedure TCABSTEAMPROJECTDeleteTeamProject(in EnteredProjectName varchar(255), in TeamName varchar(255), in ConvenorEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255))
	BEGIN
       if (char_length(EnteredProjectName) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Project name entered";
        end if;

		call TCABSTeamGetTeamKey(TeamName,ConvenorEmail,SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @ValuesTeamID);

        if ((select count(*) from Project where ProjectName = EnteredProjectName) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Entered Project Does not exist";
        end if;

		call TCABSTEAMPROJECTGetTeamProjectID(EnteredProjectName, TeamName, ConvenorEmail, SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @ValueTeamProjectID);

		if ((select count(*) from Task where TeamProjectID = @ValueTeamProjectID) >= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Team Project already having Task cannot be deleted";
        end if;

		if (select count(*) from TeamProjects where TeamProjectID = @ValueTeamProjectID) >= 0 then
			DELETE FROM TeamProjects
			WHERE TeamProjectID = @ValueTeamProjectID;
		else
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "There is no Team Project with the entered Team Project";
		end if;
	END //
 DELIMITER;

  DELIMITER //
create or replace Procedure PEERASSESSMENTFEILDDeleteFeild(in EnteredName varchar(255), in enteredfeildName varchar(255), in EnteredFeildDescription text)
	BEGIN
        if (char_length(EnteredFeildDescription) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Feild Description entered";
        end if;
		if (char_length(enteredfeildName) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Feild name entered";
        end if;

		call PeerAssessmentFeildGetFeildKey(EnteredName, enteredfeildName,@ValueFeildID);

		if (select count(*) from PeerAssessmentFeild where FeildID = @ValueFeildID) >= 0 then
			DELETE FROM PeerAssessmentFeild
			WHERE FeildID = @ValueFeildID;
		else
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "There is no Peer Assessment Field with the entered Peer Assessment Field";
		end if;
	END //
 DELIMITER;

  DELIMITER //
create or replace Procedure STUDENTPEERASSESSMENTDeleteAssessment(in EnteredName varchar(255))
	BEGIN
        if (char_length(EnteredName) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Assessment Name";
        end if;

		call STUDENTPEERASSESSMENTGetAssessmentKey(EnteredName, @ValueSPAKey);

		if ((select count(*) from PeerAssessmentFeild where SPAID = @ValueSPAKey) >= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Student Peer Assessment already having Peer Assessment cannot be deleted";
        end if;

		if ((select count(*) from SPAInstence where SPAID = @ValueSPAKey) >= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Student Peer Assessment already having SPA Instence cannot be deleted";
        end if;

		if (select count(*) from StudentPeerAssessment where SPAID = @ValueSPAKey) >= 0 then
			DELETE FROM StudentPeerAssessment
			WHERE SPAID = @ValueSPAKey;
		else
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "There is no Student Peer Assessment with the entered Student Peer Assessment";
		end if;
	END //
 DELIMITER;

 DELIMITER //
create or replace Procedure SPAINSTENCEDeleteInstence(in EnteredName varchar(255), in EnteredAssessmentDate date, in StudentEmail Varchar(255), in Teamname varchar(255), in SupervisorEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255))
	BEGIN

        declare TimerestricStart,TimeresticEnd date;

        call TCABSTEAMMEMBERGetTeamMember(StudentEmail,Teamname,SupervisorEmail,SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @ValueTeamMemberID);
        call STUDENTPEERASSESSMENTGetAssessmentKey(EnteredName,@ValueSPAKey);

        select StartDate,Enddate into TimerestricStart,TimeresticEnd from TeachingPeriod where Term = SelectedOfferingterm and Year = SelectedOfferingyear;

        if (EnteredAssessmentDate < TimerestricStart) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "you cannot schedual a peer assessment before the period occurs";
        end if;

        if (EnteredAssessmentDate > TimeresticEnd) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "you cannot schedual a peer assessment after the period occurs";
        end if;

		call SPAINSTENCEGetInstenceKey(EnteredName, EnteredAssessmentDate, StudentEmail, Teamname, SupervisorEmail, SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @valueSPAInstenceKey);

		if (select count(*) from SPAInstence where SPAInstenceID = @valueSPAInstenceKey) >= 0 then
			DELETE FROM SPAInstence
			WHERE SPAInstenceID = @valueSPAInstenceKey;
		else
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "There is no SPA Instence with the entered SPA Instence";
		end if;
	END //
 DELIMITER;

    DELIMITER //
create or replace Procedure TCABSTEAMMEMBERDeleteTeamMember(in StudentEmail varchar(255),in Teamname varchar(255), in SupervisorEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255))
	BEGIN
		declare StoredEnrolmentID int;
		if (char_length(StudentEmail) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Student Email entered";
        end if;
        if (char_length(SupervisorEmail) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Supervisor Email entered";
        end if;
        if (char_length(Teamname) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no team name entered";
        end if;
        if ((select count(*) from Users where email = StudentEmail) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered Student Email does not exist";
        end if;
        if ((select count(*) from Users where email = SupervisorEmail) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered Supervisor Email does not exist";
        end if;

        call TCABSUNITOFFERINGGetKey(SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @ValuesunitOfferingID);

        select enrolmentID into StoredEnrolmentID from Enrolment where unitOfferingID = @ValuesunitOfferingID and sUserName = StudentEmail;
		if( StoredEnrolmentID is null) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered Student Enrolment not exist";
        end if;

        call TCABSTEAMMEMBERGetTeamMember(StudentEmail, Teamname, SupervisorEmail, SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @ValueTeamMemberID);

		if ((select count(*) from Task where TeamMemberID = @ValueTeamMemberID) >= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Team Member already having Tasks cannot be deleted";
        end if;

		if ((select count(*) from MeetingAttendees where TeamMemberID = @ValueTeamMemberID) >= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Team Member already having Meeting Attendees Instence cannot be deleted";
        end if;

		if ((select count(*) from SPAInstence where TeamMemberID = @ValueTeamMemberID) >= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Team Member already having SPA Instence cannot be deleted";
        end if;

		if (select count(*) from TeamMember where TeamMemberID = @ValueTeamMemberID) >= 0 then
			DELETE FROM TeamMember
			WHERE TeamMemberID = @ValueTeamMemberID;
		else
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "There is no Team Member with the entered Team Member";
		end if;
	END //
 DELIMITER;

 /*
     DELIMITER //
create or replace Procedure TCABSTEAMMEMBERDeleteTeamMember(in StudentEmail varchar(255),in Teamname varchar(255), in SupervisorEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255))
	BEGIN
		declare StoredEnrolmentID int;
		if (char_length(StudentEmail) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Student Email entered";
        end if;
        if (char_length(SupervisorEmail) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Supervisor Email entered";
        end if;
        if (char_length(Teamname) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no team name entered";
        end if;
        if ((select count(*) from Users where email = StudentEmail) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered Student Email does not exist";
        end if;
        if ((select count(*) from Users where email = SupervisorEmail) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered Supervisor Email does not exist";
        end if;

        call TCABSUNITOFFERINGGetKey(SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @ValuesunitOfferingID);

        select enrolmentID into StoredEnrolmentID from Enrolment where unitOfferingID = @ValuesunitOfferingID and sUserName = StudentEmail;
		if( StoredEnrolmentID is null) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered Student Enrolment not exist";
        end if;

        call TCABSTEAMMEMBERGetTeamMember(StudentEmail, Teamname, SupervisorEmail, SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @ValueTeamMemberID);

		if ((select count(*) from Task where TeamMemberID = @ValueTeamMemberID) >= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Team Member already having Tasks cannot be deleted";
        end if;

		if ((select count(*) from MeetingAttendees where TeamMemberID = @ValueTeamMemberID) >= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Team Member already having Meeting Attendees Instence cannot be deleted";
        end if;

		if (select count(*) from TeamMember where TeamMemberID = @ValueTeamMemberID) >= 0 then
			DELETE FROM TeamMember
			WHERE TeamMemberID = @ValueTeamMemberID;
		else
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "There is no Team Member with the entered Team Member";
		end if;
	END //
 DELIMITER;
 */

 DELIMITER //
create or replace Procedure TCABSMEETINGATTENDIEESDeleteAttendiee(in StudentEmail Varchar(255),in EnteredStartTime datetime, in Teamname varchar(255), in SupervisorEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255))
	BEGIN
		call TCABSMEETINGATTENDIEESGetAttendieeKey(StudentEmail, EnteredStartTime, Teamname, SupervisorEmail, SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @AttendieeMeetingKey);

		if (select count(*) from MeetingAttendees where MeetingAttendeeID = @AttendieeMeetingKey) >= 0 then
			DELETE FROM MeetingAttendees
			WHERE MeetingAttendeeID = @AttendieeMeetingKey;
		else
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "There is no Meeting Attendee with the entered Meeting Attendee";
		end if;
END //
 DELIMITER ;

  DELIMITER //
create or replace Procedure TCABSSUPERVISORMEETINGDeleteMeeting(in StartTime datetime, in Teamname varchar(255), in SupervisorEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255))
	BEGIN
        if (StartTime <= sysdate()) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Cannot schedual a time behind the current date and time";
        end if;

		call TCABSSUPERVISORMEETINGGetMeetingKey(StartTime, Teamname, SupervisorEmail, SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @ValueSuppervisorMeetingKey);

		if ((select count(*) from MeetingAttendees where MeetingID = @ValueSuppervisorMeetingKey) >= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Supervisor Meeting already having Meeting Attendees cannot be deleted";
        end if;

		if (select count(*) from SupervisorMeeting where MeetingID = @ValueSuppervisorMeetingKey) >= 0 then
			DELETE FROM SupervisorMeeting
			WHERE MeetingID = @ValueSuppervisorMeetingKey;
		else
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "There is no Supervisor Meeting with the entered Supervisor Meeting";
		end if;
END //
 DELIMITER;

  DELIMITER //
create or replace Procedure TCABSENROLMENTDeleteEnrolment(in EnroledUser varchar(255),in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255))
	BEGIN
		call TCABSENROLMENTGetEnrolKey(EnroledUser, SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @ValueEnrolID);

		if ((select count(*) from TeamMember where enrolmentID = @ValueEnrolID) >= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Enrolment already having Teams cannot be deleted";
        end if;

		if (select count(*) from Enrolment where enrolmentID = @ValueEnrolID) >= 0 then
			DELETE FROM Enrolment
			WHERE enrolmentID = @ValueEnrolID;
		else
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "There is no Enrolment with the entered Enrolment";
		end if;
	END //
 DELIMITER;

  DELIMITER //
create or replace Procedure TCABSOFFERINGSTAFFDeleteOfferingStaff(in UserEmail varchar(255), in SelectedUnitCode varchar(255), in SelectedOfferingterm varchar(255), in SelectedOfferingyear varchar(255))
	BEGIN
		if (char_length(UserEmail) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no User Email entered";
        end if;

        if ((select count(*) from Users where email = UserEmail) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered User Email does not exist";
        end if;

        call TCABSOFFERINGSTAFFGetOfferingStaffKey(UserEmail, SelectedUnitCode, SelectedOfferingterm, SelectedOfferingyear, @ValueOfferingStaff);

		if ((select count(*) from Team where OfferingStaffID = @ValueOfferingStaff) >= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Team already having Offering Staff cannot be deleted";
        end if;

		if (select count(*) from OfferingStaff where OfferingStaffID = @ValueOfferingStaff) >= 0 then
			DELETE FROM OfferingStaff
			WHERE OfferingStaffID = @ValueOfferingStaff;
		else
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "There is no Offering Staff with the entered Offering Staff";
		end if;
	END //
 DELIMITER;

  DELIMITER //
create or replace PROCEDURE TCABSUNITOFFERINGDeleteOffering( in OfferedUnitID Varchar(255), in Offeredterm varchar(255), in Offeredyear varchar(255))
	BEGIN
		if(char_length(OfferedUnitID) <= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "the Unit feild has not been filled";
		end if;
		if((select count(*) from tcabs.Unit where unitCode = OfferedUnitID) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "the Unit you entered does not exist";
		end if;

		call TCABSUNITOFFERINGGetKey(OfferedUnitID, Offeredterm, Offeredyear, @ValuesunitOfferingID);

		if ((select count(*) from OfferingProject where unitOfferingID = @ValuesunitOfferingID) >= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Unit Offering already having Offering PRoject cannot be deleted";
        end if;

		if ((select count(*) from Enrolment where unitOfferingID = @ValuesunitOfferingID) >= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Unit Offering already having Enrolment cannot be deleted";
        end if;

		if ((select count(*) from OfferingStaff where unitOfferingID = @ValuesunitOfferingID) >= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Unit Offering already having Offering Staff cannot be deleted";
        end if;

		if (select count(*) from UnitOffering where unitOfferingID = @ValuesunitOfferingID) >= 0 then
			DELETE FROM UnitOffering
			WHERE unitOfferingID = @ValuesunitOfferingID;
		else
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "There is no Unit Offering with the entered Unit Offering";
		end if;
	END //
DELIMITER;

/*
  DELIMITER //
create or replace PROCEDURE TCABSUNITOFFERINGDeleteOffering( in OfferedUnitID Varchar(255), in Offeredterm varchar(255), in Offeredyear varchar(255))
	BEGIN
		if(char_length(OfferedUnitID) <= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "the Unit feild has not been filled";
		end if;
		if((select count(*) from tcabs.Unit where unitCode = OfferedUnitID) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "the Unit you entered does not exist";
		end if;

		call TCABSUNITOFFERINGGetKey(OfferedUnitID, Offeredterm, Offeredyear, @ValuesunitOfferingID);

		if ((select count(*) from OfferingProject where unitOfferingID = @ValuesunitOfferingID) >= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Unit Offering already having Offering PRoject cannot be deleted";
        end if;

		if ((select count(*) from Enrolment where unitOfferingID = @ValuesunitOfferingID) >= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Unit Offering already having Enrolment cannot be deleted";
        end if;

		if ((select count(*) from OfferingStaff where unitOfferingID = @ValuesunitOfferingID) >= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Unit Offering already having Offering Staff cannot be deleted";
        end if;

		if ((select count(*) from SPAInstence where unitOfferingID = @ValuesunitOfferingID) >= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Unit Offering already having SPA Instence cannot be deleted";
        end if;

		if (select count(*) from UnitOffering where unitOfferingID = @ValuesunitOfferingID) >= 0 then
			DELETE FROM UnitOffering
			WHERE unitOfferingID = @ValuesunitOfferingID;
		else
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "There is no Unit Offering with the entered Unit Offering";
		end if;
	END //
DELIMITER;
*/

  DELIMITER //
create or replace Procedure TCABSPERMISSIONDeletePermission(in RoleName varchar(255), in Functionality varchar(255))
	BEGIN
		if (char_length(RoleName) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Role name entered";
        end if;
        if (char_length(Functionality) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Functionality entered";
        end if;

        if ((select count(*) from Permission where usertype = RoleName) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered Role name does not exist";
        end if;
        if ((select count(*) from Permission where procName = Functionality) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered Functionality does not exist";
        end if;

		if (select count(*) from Permission where usertype = RoleName AND procName = Functionality) >= 0 then
			DELETE FROM Permission
			where usertype = RoleName
			AND procName = Functionality;
		else
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "There is no Permission with the entered Permission";
		end if;
	END //
 DELIMITER;

  DELIMITER //
create or replace PROCEDURE TCABSUNITDeleteunit( in EnteredUnitcode varchar(10), in EnteredUnitname varchar(100))
	BEGIN
		if (char_length(EnteredUnitcode) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Unit Code entered";
        end if;
		if (char_length(EnteredUnitname) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no Unit name entered";
        end if;

		if ((select count(*) from Unit where unitCode = EnteredUnitcode) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered Unit Code does not exist";
        end if;
        if ((select count(*) from Unit where unitName = EnteredUnitname) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered Unit name does not exist";
        end if;

		if ((select count(*) from UnitOffering where unitCode = EnteredUnitcode) >= 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Unit already having Unit Offering cannot be deleted";
        end if;

		if (select count(*) from Unit where unitCode = EnteredUnitcode AND unitName = EnteredUnitname) >= 0 then
			DELETE FROM Unit
			where unitCode = EnteredUnitcode
			AND unitName = EnteredUnitname;
		else
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "There is no Unit with the entered Unit";
		end if;
	END //
 DELIMITER;

  DELIMITER //
create or replace Procedure TCABSTEACHINGPERIODDeletePeriod(in EnteredTerm varchar(255), in EnteredYear varchar(255))
	BEGIN
		if (char_length(EnteredTerm) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no term name entered";
        end if;

		if (char_length(EnteredYear) < 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "no year number entered";
        end if;

		if ((select count(*) from TeachingPeriod where term = EnteredTerm) <> 1) && ((select count(*) from TeachingPeriod where year = EnteredYear) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "entered Term and Year do not exist";
        end if;

		if ((select count(*) from UnitOffering where term = EnteredTerm) >= 1) && ((select count(*) from UnitOffering where year = EnteredYear) <> 1) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Teaching Period already having Unit Offering cannot be deleted";
        end if;

		if (select count(*) from TeachingPeriod where term = EnteredTerm AND year = EnteredYear) >= 0 then
			DELETE FROM TeachingPeriod
			where term = EnteredTerm
			AND year = EnteredYear;
		else
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "There is no Teaching Period with the entered Teaching Period";
		end if;
	END //
 DELIMITER;

-- ---------------------------------------No Procedures or Functions after this point -----------------------------------------------
-- Functions
-- this must run after all procedures and functions as it loads all available user functionality for security to manage
insert into Functions(procName) SELECT Routine_Name FROM INFORMATION_SCHEMA.ROUTINES where Routine_Schema like '%TCABS%';


INSERT INTO tcabs.Permission VALUES ("admin", "TCABS_User_register");
-- TCABS Permissions
-- assigns a Role to a Permission 
-- call TCABSPERMISSIONAddPermission("testerRole", "TCABSauthenticateEmail");
