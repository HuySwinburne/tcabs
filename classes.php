<?php
	// Define different classes with relevant and useful functions here
	require("db-conn.php");	// connect to database

	function parse_csv_file($csvfile) {

		// check if file exists -- exit if error
		if (!file_exists('../user.csv') ) {
			throw new Exception('File not found.');
		}

		// check if file is a csv file - exit if error
		if($_FILES['csvFile']['type'] !== "text/csv") {
			throw new Exception('File is not csv!!');
		} 

		$csv = Array();
		$rowcount = 0;

		if ($handle = fopen($csvfile, "r")) {

			$max_line_length = defined('MAX_LINE_LENGTH') ? MAX_LINE_LENGTH : 10000;
			$header = fgetcsv($handle, $max_line_length, "	");
			$header_colcount = count($header);

			while (($row = fgetcsv($handle, $max_line_length, "	")) !== FALSE) {
				$row_colcount = count($row);

				if ($row_colcount == $header_colcount) {
					$entry = array_combine($header, $row);
					$csv[] = $entry;
				} else {
					throw new exception("CSV Reader: Invalid number of columns at line - " . ($rowcount + 2));
					return null;
				}
				$rowcount++;
			}

			fclose($handle);

		} else {
			error_log("csvreader: Could not read CSV \"$csvfile\"");
			return null;
		}
		return $csv;
	}

	class Role {
		public $roles;

		public function __construct() {
			$this->roles = array();
		}

		public function getRoles($userEmail) {

			// Populate the $roles array with all the roles a user has
			$stmt = $GLOBALS['conn']->prepare("SELECT userType 
							FROM UserCat WHERE email = ?");

			$stmt->bind_param('s', $userEmail);

			try {
				$stmt->execute();
				$stmt->store_result();
				$stmt->bind_result($userType);

				while($stmt->fetch()) {
					$this->roles[$userType] = TRUE;
				}
			} catch(mysqli_sql_exception $e) {
				echo "<script type='text/javascript'>alert('{$e}');</script>";
			}
		}

		public function assignRoles($userEmail, $userRoleArr) {
			// how to roll back if error occurs for some role
			$stmt = $GLOBALS['conn']->prepare("call TCABSUserCatAssignUserARole(?, ?)");

			foreach($userRoleArr as $userRole => $value) {
				$stmt->bind_param('ss', $userEmail, $value);
				
				try {
					$stmt->execute();
				} catch(mysqli_sql_exception $e) {
					throw $e;
				}
			}
			$stmt->close();
		}

	}

	class Permission{
		protected $permissions;

		protected function __construct() {
			$this->permissions = array();
		}
		
		protected function getPerms($userRoles) {

			if($userRoles == NULL) {
			} else {

				$subQuery = "";

				foreach($userRoles as $userType => $access) {
					$subQuery = $subQuery . "'{$userType}', "; 
				}
				$subQuery = substr($subQuery, 0, -2);

				// using subquery
				// this method wont work with prepared statement
				$sql = "SELECT procName FROM Permission	
								WHERE userType IN (" . $subQuery .")";

				try {

					$result = $GLOBALS['conn']->query($sql);

					if($GLOBALS['conn']->error) {
         		echo $GLOBALS['conn']->error;
       		} else {
						if($result->num_rows > 0) {
							while($row = $result->fetch_assoc()) {
								$this->permissions[$row['procName']] = true;
          	 	}
						} else {
         	  	return NULL;
         		}
       		}
				} catch(mysqli_sql_exception $e) {
					echo "<script type='text/javascript'>alert('{$e}');</script>";
				}
			}
		}

		// Pass in a stored procedure/function name to check if user has access -- get TRUE/FALSE
		public function hasPerm($procedureName) {
			return isset($this->permissions[$procedureName]);
		}
	}

	class User extends Permission {
		public $fName;
		public $lName;
		public $gender;
		public $pNum;
		public $email;
		private $pwd;	// hidden to outside classes and functions

		public $uRoles;

		public function __construct() {
			Permission::__construct();
			$uRoles = array();
		}

		public function userExist() {
			if($this->email != null) {
				return TRUE;
			} else {
				return FALSE;
			}
		}

		public function checkPwd($userPwd) {
			// encrypt
			$userPwd = sha1($userPwd);

			if($userPwd == $this->pwd) {
				return TRUE;
			} else {
				return FALSE;
			}
		}
		public function getUser($userEmail) {

			// Populate basic user information into member variables
			$sql = "SELECT * FROM Users WHERE email = '" . $userEmail . "';";
			$result = $GLOBALS['conn']->query($sql);

			if($GLOBALS['conn']->error) {
				echo $GLOBALS['conn']->error;
			} else {
				if($result->num_rows > 0) {
					while($row = $result->fetch_assoc()) {
						$this->fName = $row['fName'];
						$this->lName = $row['lName'];
						$this->email = $row['email'];
						$this->gender = $row['gender'];
						$this->pwd = $row['pwd'];
						$this->pNum = $row['pNum'];
 	   			}
				} else {
					return NULL;
				}
			}

			// get all roles of user and store it in uRoles
			$roleObj = new Role;
			$roleObj->getRoles($this->email);
			$this->uRoles = $roleObj->roles;

			// Get all the stored procedures/functions a user can access
			Permission::getPerms($this->uRoles);
		}

		public function searchUser($searchQuery) {
		
			$stmt = $GLOBALS['conn']->prepare("SELECT email FROM Users
									WHERE email LIKE ? or fName LIKE ? or lName LIKE ?");
			$stmt->bind_param('sss', $searchQuery, $searchQuery, $searchQuery);

			$Users = [];
			$row = new User;

			try {
				$stmt->execute();
				$stmt->store_result();
				$stmt->bind_result($email);

				$i = 0;
				if($stmt->num_rows > 0) {
					while($stmt->fetch()) {

						$row->getUser($email);

						$Users[$i] = (array)[
							"email" => $row->email,
							"fName" => $row->fName,
							"lName" => $row->lName,
							"gender" => $row->gender,
							"pNum" => $row->pNum,
							"roles" => $row->uRoles
						];

						$i = $i +1;
					}
				} else {
					return null;
				}
				$stmt->close();
				return $Users;
			} catch(mysqli_sql_exception $e) {
				throw $e;
				return null;
			}
		}

		// this function can be used to get all users with a particular role
		public function getUsersForRole($userRole) {

			$stmt = $GLOBALS['conn']->prepare("SELECT email FROM UserCat
								WHERE userType = ?");

			$stmt->bind_param('s', $userRole);

			try {
				$stmt->execute();
				$stmt->store_result();
				$stmt->bind_result($email);

				$userArr = array();

				if($stmt->num_rows > 0) {
					while($stmt->fetch()) {
						array_push($userArr, $email);
					}
				}
				return $userArr;
				$stmt->close();
			} catch(mysqli_sql_exception $e) {
				throw $e;
			}
		
		}

		// to add a user to a data base - updating Users and UserCat tables
		public function registerUser($fName, $lName, $gender, $pNum, $email, $pwd, $roles) {

			// convert pNum to ###-###-####
			// will only work on 10-digit number without country code
			$pNum = sprintf("%s-%s-%s", substr($pNum, 0, 3), substr($pNum, 3, 3), substr($pNum, 6, 4));

			// encrypt password
			$pwd = sha1($pwd);

			$stmt = $GLOBALS['conn']->prepare("call TCABS_User_register(?, ?, ?, ?, ?, ?)");
			$stmt->bind_param('ssssss', $fName, $lName, $gender, $pNum, $email, $pwd);

			try {
				$GLOBALS['conn']->begin_transaction();

				$stmt->execute();

				// to update userCat table
				$roleObj = new Role;
				$roleObj->assignRoles($email, $roles);

				$GLOBALS['conn']->commit();

			} catch(mysqli_sql_exception $e) {
				$GLOBALS['conn']->rollback();
				throw $e;
			}

			$stmt->close();
		}
	}

	class Unit {
		public $unitName;
		public $unitFaculty;

		public $unitCode;

		public function getUnit($unitCode) {

			$stmt = $GLOBALS['conn']->prepare("SELECT * FROM Unit WHERE unitCode = ?;");
			$stmt->bind_param('s', $unitCode);

			try {
				$stmt->execute();
				$stmt->store_result();
				$stmt->bind_result($uCode, $uName, $uFaculty);

				if($stmt->num_rows > 0) {
					while($stmt->fetch()) {
						$this->unitName = $uName;
						$this->unitCode = $uCode;
						$this->unitFaculty = $uFaculty;
					}
				} else {
					return null;
				}
			} catch(mysqli_sql_exception $e) {
				return null;
				throw $e;
			}

		}

		public function searchUnit($searchQuery) {
			$searchResult = array();

			$stmt = $GLOBALS['conn']->prepare("SELECT unitCode, unitName FROM Unit
									WHERE unitCode LIKE ? or unitName LIKE ?");
			$stmt->bind_param('ss', $searchQuery, $searchQuery);

			$units = [];
			$row = new Unit;

			try {
				$stmt->execute();
				$stmt->store_result();
				$stmt->bind_result($unitCode, $unitName);

				$i = 0;
				if($stmt->num_rows > 0) {
					while($stmt->fetch()) {

						$row->getUnit($unitCode);

						$units[$i] = (array)[
							"unitCode" => $row->unitCode,
							"unitName" => $row->unitName,
							"unitFaculty" => $row->unitFaculty
						];

						$i = $i +1;
					}
				}
				$stmt->close();
				return $units;
			} catch(mysqli_sql_exception $e) {
				throw $e;
				return null;
			}
		}

		public function updateUnit($unit) {
			
			$stmt = $GLOBALS['conn']->prepare("UPDATE Unit 
								SET unitCode = ?, unitName = ?, faculty = ?
								WHERE unitCode = ?");

			$stmt->bind_param("ssss", $unit->unitCode, $unit->unitName, $unit->unitFaculty, $unit->unitCode);

			try {
				$stmt->execute();
			} catch(mysqli_sql_exception $e) {
				throw $e;
			}

			$stmt->close();
		}

		public function registerUnit($uCode, $uName, $uFaculty) {

			$stmt = $GLOBALS['conn']->prepare("call TCABS_Unit_register(?, ?, ?)");
			$stmt->bind_param("sss", $uCode, $uName, $uFaculty);

			try {
				$stmt->execute();
				echo "<script type='text/javascript'>alert('Unit added successfully!');</script>";
			} catch(mysqli_sql_exception $e) {
				throw $e;
			}

			$stmt->close();
		}
	}

	class UnitOffering extends Unit {
		public $uOffID;
		public $cUserName;
		public $term;
		public $year;
		public $censusDate;

		public $offerings;

		// initialize the object with all unit Offerings of a unit
		public function __construct() {
			$offerings = array();
		}

		public function getUnitOffering($unitCode, $term, $year) {

			$stmt = $GLOBALS['conn']->prepare("SELECT * 
								FROM UnitOffering WHERE unitCode = ? and term = ? and year = ?");
			$stmt->bind_param('sss', $unitCode, $term, $year);

			$uOffObj = new UnitOffering;

			try {
				$stmt->execute();
				$stmt->store_result();
				$stmt->bind_result($uOffID, $unitCode, $cUserName, $term, $year, $censusDate);

				if($stmt->num_rows > 0) {
					while($stmt->fetch()) {
						$uOffObj->uOffID = $uOffID;
						$uOffObj->unitCode = $unitCode;
						$uOffObj->cUserName = $cUserName;
						$uOffObj->term = $term;
						$uOffObj->year = $year;
						$uOffObj->censusDate = $censusDate;
					}
				} else {
					$uOffObj = null;
				}
				$stmt->close();
			} catch(mysqli_sql_exception $e) {
				throw $e;
			}
			return $uOffObj;
		}

		// return offerings array
		public function getOfferings($unitCode) {

			$stmt = $GLOBALS['conn']->prepare("SELECT * FROM UnitOffering WHERE unitCode = ?");
			$stmt->bind_param('s', $unitCode);

			try {
				$stmt->execute();
				$stmt->store_result();
				$stmt->bind_result($uOffID, $unitCode, $cUserName, $term, $year, $censusDate);

				if($stmt->num_rows > 0) {
					while($stmt->fetch()) {
						$this->offerings['uOffID'] = $uOffID;
						$this->offerings['unitCode'] = $unitCode;
						$this->offerings['cUserName'] = $cUserName;
						$this->offerings['term'] = $term;
						$this->offerings['year'] = $year;
						$this->offerings['censusDate'] = $censusDate;
					}
				}
				print_r($this->offerings);
				$stmt->close();
			} catch(mysqli_sql_exception $e) {
				throw $e;
			}
		}

		// add unit offering
		public function addUnitOff($unitCode, $convenorEmail, $term, $year, $censusDate) {

			$stmt = $GLOBALS['conn']->prepare("CALL TCABS_UnitOff_add(?, ?, ?, ?, ?)");
			$stmt->bind_param("sssss", $unitCode, $convenorEmail, $term, $year, $censusDate);

			try {
				$stmt->execute();
				echo "<script type='text/javascript'>alert('Unit Offering added successfully');</script>";
			} catch(mysqli_sql_exception $e) {
				throw $e;
			}

			$stmt->close();
		}
	}

	class Enrolment{
		public $enrolmentID;
		public $sUserName;
		public $unitOfferingID;

		public function getUnitEnrolments($unitCode, $term, $year) {

			// Array of all enrolments in a unit offering
			$enrolments = [];

			// get UnitOffering ID using member function in UnitOffering class
			$uOffObj = new UnitOffering;
			$uOffObj = $uOffObj->getUnitOffering($unitCode, $term, $year);

			if(!isset($uOffObj)) {
				throw new Exception('No Enrolments found!');
			} else {
				
				$uOffID = $uOffObj->uOffID;
				$stmt = $GLOBALS['conn']->prepare("SELECT E.sUserName, UO.unitCode, U.unitName, UO.term, UO.year 
									FROM Enrolment E INNER JOIN UnitOffering UO
									ON E.unitOfferingID = UO.unitOfferingID
									INNER JOIN Unit U
									ON UO.unitCode = U.UnitCode
									WHERE E.unitOfferingID = ?");

				$stmt->bind_param('s', $uOffID);

				try {
					$stmt->execute();
					$stmt->store_result();
					$stmt->bind_result($sUserName, $unitCode, $unitName, $term, $year);

					$i = 0;
					if($stmt->num_rows > 0) {
						while($stmt->fetch()) {

							$enrolments[$i] = (array)[
								"sUserName" => $sUserName,
								"unitCode" => $unitCode,
								"unitName" => $unitName,
								"term" => $term,
								"year" => $year
							];

							$i = $i +1;
						}
					} else throw new Exception('No Enrolments found in table');
					$stmt->close();
				} catch(mysqli_sql_exception $e) {
					throw $e;
				}
			}
			return $enrolments;
		}

		public function getAllEnrolments() {
		
			$stmt = $GLOBALS['conn']->prepare("SELECT E.enrolmentID, E.unitOfferingID, 
								E.sUserName, U.unitCode, UN.unitName, U.term, U.year 
								FROM Enrolment E INNER JOIN UnitOffering U
								ON U.unitOfferingID = E.unitOfferingID
								INNER JOIN Unit UN
								ON U.unitCode = UN.unitCode
							");

			try {
				$stmt->execute();
				$stmt->store_result();
				$stmt->bind_result(
					$enrolmentID, 
					$unitOfferingID,
					$sUserName, 
					$unitCode, 
					$unitName, 
					$term, 
					$year
				);

				$enrolments = [];
				$i = 0;

				if($stmt->num_rows > 0) {
					while($stmt->fetch()) {
						$enrolments[$i] = array(
							'enrolmentID' => $enrolmentID,
							'unitOfferingID' => $unitOfferingID,
							'sUserName' => $sUserName,
							'unitCode' => $unitCode,
							'unitName' => $unitName,
							'term' => $term,
							'year' => $year
						);
						$i = $i + 1;
					}
				}
			} catch(mysqli_sql_exception $e) {
				// set enrolments array back to empty
				$enrolments = [];
				throw $e;
			}
			return $enrolments;
		}

		public function enrolUser($userEmail, $unitCode, $term, $year) {

			$stmt = $GLOBALS['conn']->prepare("CALL TCABS_enrolment_add(?, ?, ?, ?)");
			$stmt->bind_param("ssss", $userEmail, $unitCode, $term, $year);
			
			try {
				$stmt->execute();
			} catch(mysqli_sql_exception $e) {
				throw $e;
			}

			$stmt->close();
		}
	}

	class TeamMember {
		public $tMemberID;
		public $enrolmentID;
		public $teamID;

		public function getMembers($pTeamID) {

			$stmt = $GLOBALS['conn']->prepare("SELECT TeamMemberID, EnrolmentID, TeamID 
								FROM TeamMember 
								WHERE TeamID = ?");
			$stmt->bind_param('s', $pTeamID);

			$members = [];

			try {
				$stmt->execute();
				$stmt->store_result();
				$stmt->bind_result($tMemberID, $enrolmentID, $teamID);

				$i = 0;
				if($stmt->num_rows > 0) {
					while($stmt->fetch()) {

						$members[$i] = (array)[
							"tMemberID" => $tMemberID,
							"enrolmentID" => $enrolmentID,
							"teamID" => $teamID
						];

						$i = $i +1;
					}
				} else throw new Exception('No Enrolments found in table');
				$stmt->close();
			} catch(mysqli_sql_exception $e) {
				throw $e;
			}
			return $members;
		}

		public function searchMembers($searchQuery) {
			
			$searchResult = array();

			$stmt = $GLOBALS['conn']->prepare("SELECT TM.TeamMemberID, TM.EnrolmentID, TM.TeamID, T.teamName, 
						 		E.unitOfferingID, U.email, U.fName, U.lName	
								FROM TeamMember TM INNER JOIN Team T
								ON T.TeamID = TM.TeamID
								INNER JOIN Enrolment E 
								ON TM.enrolmentID = E.EnrolmentID
								INNER JOIN Users U 
								ON U.email = E.sUserName
								WHERE U.email LIKE ? or U.fName LIKE ? or U.lName LIKE ?");
			$stmt->bind_param('sss', $searchQuery, $searchQuery, $searchQuery);

			$members = [];

			try {
				$stmt->execute();
				$stmt->store_result();
				$stmt->bind_result($tMemberID, $enrolmentID, $teamID, $teamName,
					$unitOfferingID, $email, $fName, $lName);

				$i = 0;
				if($stmt->num_rows > 0) {
					while($stmt->fetch()) {

						$members[$i] = (array)[
							"tMemberID" => $tMemberID,
							"enrolmentID" => $enrolmentID,
							"teamID" => $teamID,
							"teamName" => $teamName,
							"unitOfferingID" => $unitOfferingID,
							"email" => $email,
							"fName" => $fName,
							"lName" => $lName,
						];

						$i = $i +1;
					}
				}
				$stmt->close();
			} catch(mysqli_sql_exception $e) {
				throw $e;
			}
			return $members;
		}

		public function addTeamMember($sEmail, $tName, $supEmail, $unitCode, $term, $year) {
		
			$stmt = $GLOBALS['conn']->prepare("CALL TCABSTEAMMEMBERAddTeamMember(?, ?, ?, ?, ?, ?)");
			$stmt->bind_param("ssssss", $sEmail, $tName, $supEmail, $unitCode, $term, $year);
			
			try {
				$stmt->execute();
			} catch(mysqli_sql_exception $e) {
				throw $e;
			}
			$stmt->close();
		}
	}

	class Team {
		public $teamID;
		public $teamName;
		public $offStaffID;
		public $projManager;

		public function getTeam($pTeamID) {
			
			$stmt = $GLOBALS['conn']->prepare("SELECT TeamID, TeamName, OfferingStaffID, ProjectManager 
								FROM Team 
								WHERE TeamID = ?");
			$stmt->bind_param('s', $pTeamID);

			$tObj = new Team;

			try {
				$stmt->execute();
				$stmt->store_result();
				$stmt->bind_result($teamID, $teamName, $offStaffID, $projManager);

				if($stmt->num_rows > 0) {
					while($stmt->fetch()) {

						$tObj->teamID = $teamID;
						$tObj->teamName = $teamName;
						$tObj->offStaffID = $offStaffID;
						$tObj->projManager = $projManager;

					}
				} else throw new Exception("No Team found for Team ID : {$pteamID}");
				$stmt->close();
			} catch(mysqli_sql_exception $e) {
				throw $e;
			}
			return $tObj;
		}

		public function addTeam($tname, $supemail, $unitcode, $term, $year) {
		
			$stmt = $GLOBALS['conn']->prepare("CALL TCABSTeamAddTeam(?, ?, ?, ?, ?)");
			$stmt->bind_param("sssss", $tname, $supemail, $unitcode, $term, $year);
			
			try {
				$stmt->execute();
			} catch(mysqli_sql_exception $e) {
				throw $e;
			}
			$stmt->close();
		}


		public function searchTeam($searchQuery) {
			
			$searchResult = array();

			$stmt = $GLOBALS['conn']->prepare("SELECT T.TeamID, T.TeamName, 
								T.OfferingStaffID, OF.UserName,T.projectManager, 
								OF.UnitOfferingID, UO.unitCode, UO.term, UO.year
								FROM Team T INNER JOIN OfferingStaff OF ON T.OfferingStaffID = OF.OfferingStaffID
								INNER JOIN UnitOffering UO ON UO.unitOfferingID = OF.UnitOfferingID
								WHERE T.TeamID LIKE ? or T.TeamName LIKE ?"
								);
			$stmt->bind_param('ss', $searchQuery, $searchQuery);

			$teams = [];

			try {
				$stmt->execute();
				$stmt->store_result();
				$stmt->bind_result($teamID, $teamName, $offeringStaffID, $uName, 
								$projManager, $uOffID, $unitCode, $term, $year);

				$i = 0;
				if($stmt->num_rows > 0) {
					while($stmt->fetch()) {

						$teams[$i] = (array)[
							"teamID" => $teamID,
							"teamName" => $teamName,
							"offeringStaffID" => $offeringStaffID,
							"uName" => $uName,
							"projManager" => $projManager,
							"uOffID" => $uOffID,
							"unitCode" => $unitCode,
							"term" => $term,
							"year" => $year
						];

						$i = $i +1;
					}
				}
				$stmt->close();
			} catch(mysqli_sql_exception $e) {
				throw $e;
			}
			return $teams;
		}

		public function updateTeam($tname, $supemail, $unitcode, $term, $year, $nsup, $nname, $projman) {
		
			$stmt = $GLOBALS['conn']->prepare("CALL TCABSUpdateFullTeam(?, ?, ?, ?, ?, ?, ?, ?)");
			$stmt->bind_param("ssssssss", $tname, $supemail, $unitcode, $term, $year, $nsup, $nname, $projman);
			
			try {
				$stmt->execute();
			} catch(mysqli_sql_exception $e) {
				throw $e;
			}
			$stmt->close();
		}

		public function deleteTeam($tname, $supemail, $unitcode, $term, $year) {
		
			$stmt = $GLOBALS['conn']->prepare("CALL TCABSTeamDeleteTeam(?, ?, ?, ?, ?)");
			$stmt->bind_param("sssss", $tname, $supemail, $unitcode, $term, $year);
			
			try {
				$stmt->execute();
			} catch(mysqli_sql_exception $e) {
				throw $e;
			}
			$stmt->close();
		}
		
	}

	class Project {
	 public $projName;
	 public $projDesc;

	 public function addProject($projName, $projDesc) {
	 
			$stmt = $GLOBALS['conn']->prepare("CALL TCABS_Project_Add(?, ?)");
			$stmt->bind_param("ss", $projName, $projDesc);
			
			try {
				$stmt->execute();
			} catch(mysqli_sql_exception $e) {
				throw $e;
			}
			$stmt->close();
	 }

		public function searchProjects($searchQuery) {
			
			$searchResult = array();

			$stmt = $GLOBALS['conn']->prepare("SELECT P.projectName,  
								P.ProjectDescription, UO.unitOffering, UO.unitCode, UO.unitName, 
								UO.term, UO.year, UO.cUserName
								FROM Project P INNER JOIN OfferingProject O
								ON O.ProjectName = P.ProjectName
								INNER JOIN UnitOffering UO
								ON UO.unitOfferingID = O.UnitOfferingID
								WHERE P.ProjectName LIKE ? or P.ProjectID LIKE ? or UO.unitCode LIKE ?" 
								);
			$stmt->bind_param('sss', $searchQuery, $searchQuery, $searchQuery);

			$projects = [];
//
			try {
				$stmt->execute();
				$stmt->store_result();
				$stmt->bind_result($teamID, $teamName, $offeringStaffID, $uName, 
								$projManager, $uOffID, $unitCode, $term, $year);

				$i = 0;
				if($stmt->num_rows > 0) {
					while($stmt->fetch()) {

						$teams[$i] = (array)[
							"teamID" => $teamID,
							"teamName" => $teamName,
							"offeringStaffID" => $offeringStaffID,
							"uName" => $uName,
							"projManager" => $projManager,
							"uOffID" => $uOffID,
							"unitCode" => $unitCode,
							"term" => $term,
							"year" => $year
						];

						$i = $i +1;
					}
				}
				$stmt->close();
			} catch(mysqli_sql_exception $e) {
				throw $e;
			}
			return $teams;
		}
	}
?>
