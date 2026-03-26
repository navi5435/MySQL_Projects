
 -- 17. Job Portal Database

-- Create Database
CREATE DATABASE 17_SqlPrj_job_portal_db;
USE 17_SqlPrj_job_portal_db;

-- Create Tables

CREATE TABLE Employers (
    EmployerID INT PRIMARY KEY,
    CompanyName VARCHAR(100),
    Industry VARCHAR(50),
    Location VARCHAR(50)
);

CREATE TABLE Jobs (
    JobID INT PRIMARY KEY,
    EmployerID INT,
    JobTitle VARCHAR(100),
    Salary DECIMAL(10,2),
    PostedDate DATE,
    FOREIGN KEY (EmployerID) REFERENCES Employers(EmployerID)
);

CREATE TABLE Applicants (
    ApplicantID INT PRIMARY KEY,
    ApplicantName VARCHAR(100),
    Email VARCHAR(100),
    ExperienceYears INT
);

-- Status: Applied / Shortlisted / Rejected / Hired

CREATE TABLE Applications (
    ApplicationID INT PRIMARY KEY,
    JobID INT,
    ApplicantID INT,
    ApplicationDate DATE,
    Status VARCHAR(20) DEFAULT 'Applied',
    FOREIGN KEY (JobID) REFERENCES Jobs(JobID),
    FOREIGN KEY (ApplicantID) REFERENCES Applicants(ApplicantID)
);

-- Inserting Records To Each Tables

-- Employers
INSERT INTO Employers VALUES
(1,'TechSoft','IT','Bangalore'),
(2,'FinCorp','Finance','Mumbai'),
(3,'HealthPlus','Healthcare','Delhi'),
(4,'EduWorld','Education','Chennai'),
(5,'RetailHub','Retail','Hyderabad'),
(6,'BuildPro','Construction','Pune'),
(7,'AutoDrive','Automobile','Kolkata'),
(8,'MediaWave','Media','Ahmedabad'),
(9,'AgroFarm','Agriculture','Jaipur'),
(10,'DataGen','IT','Coimbatore');

-- Jobs
INSERT INTO Jobs VALUES
(101,1,'Software Developer',600000,'2024-01-01'),
(102,2,'Financial Analyst',500000,'2024-01-05'),
(103,3,'Medical Officer',700000,'2024-01-10'),
(104,4,'Teacher',400000,'2024-01-15'),
(105,5,'Store Manager',450000,'2024-01-20'),
(106,6,'Site Engineer',550000,'2024-01-25'),
(107,7,'Mechanical Engineer',650000,'2024-02-01'),
(108,8,'Content Creator',350000,'2024-02-05'),
(109,9,'Agriculture Officer',480000,'2024-02-10'),
(110,10,'Data Analyst',620000,'2024-02-15');

-- Applicants
INSERT INTO Applicants VALUES
(201,'Amit','amit@gmail.com',2),
(202,'Priya','priya@gmail.com',3),
(203,'Rahul','rahul@gmail.com',5),
(204,'Sneha','sneha@gmail.com',1),
(205,'Karan','karan@gmail.com',4),
(206,'Anita','anita@gmail.com',6),
(207,'Rohit','rohit@gmail.com',2),
(208,'Meera','meera@gmail.com',3),
(209,'Neha','neha@gmail.com',5),
(210,'Varun','varun@gmail.com',7);

-- Applications
INSERT INTO Applications VALUES
(301,101,201,'2024-02-20','Applied'),
(302,101,202,'2024-02-21','Shortlisted'),
(303,102,203,'2024-02-22','Rejected'),
(304,103,204,'2024-02-23','Applied'),
(305,104,205,'2024-02-24','Shortlisted'),
(306,105,206,'2024-02-25','Hired'),
(307,101,207,'2024-02-26','Applied'),
(308,110,208,'2024-02-27','Shortlisted'),
(309,110,209,'2024-02-28','Applied'),
(310,107,210,'2024-03-01','Applied');

-- Indexes

CREATE INDEX idx_job_title ON Jobs(JobTitle);
CREATE INDEX idx_application_status ON Applications(Status);
CREATE INDEX idx_applicant_experience ON Applicants(ExperienceYears);

-- View: Application Status Tracking

CREATE VIEW Application_Status_View AS
SELECT 
    a.ApplicationID,
    ap.ApplicantName,
    j.JobTitle,
    a.Status,
    a.ApplicationDate
FROM Applications a
JOIN Applicants ap ON a.ApplicantID = ap.ApplicantID
JOIN Jobs j ON a.JobID = j.JobID;

-- View: Most Applied Job

CREATE VIEW Most_Applied_Job_View AS
SELECT 
    j.JobID,
    j.JobTitle,
    COUNT(a.ApplicationID) AS TotalApplications
FROM Jobs j
LEFT JOIN Applications a ON j.JobID = a.JobID
GROUP BY j.JobID, j.JobTitle
ORDER BY TotalApplications DESC;

-- Ranking Jobs by Applications (Window Function)

CREATE VIEW Job_Application_Ranking AS
SELECT 
    j.JobID,
    j.JobTitle,
    COUNT(a.ApplicationID) AS TotalApplications,
    RANK() OVER (ORDER BY COUNT(a.ApplicationID) DESC) AS ApplicationRank
FROM Jobs j
LEFT JOIN Applications a ON j.JobID = a.JobID
GROUP BY j.JobID, j.JobTitle;

-- Stored Procedure: Update Application Status

DELIMITER //

CREATE PROCEDURE UpdateApplicationStatus(
    IN p_ApplicationID INT,
    IN p_Status VARCHAR(20)
)
BEGIN
    UPDATE Applications
    SET Status = p_Status
    WHERE ApplicationID = p_ApplicationID;
END //

DELIMITER ;

-- Stored Procedure: Get Job Application Count

DELIMITER //

CREATE PROCEDURE GetJobApplicationCount(IN p_JobID INT)
BEGIN
    SELECT 
        j.JobTitle,
        COUNT(a.ApplicationID) AS TotalApplications
    FROM Jobs j
    LEFT JOIN Applications a ON j.JobID = a.JobID
    WHERE j.JobID = p_JobID
    GROUP BY j.JobTitle;
END //

DELIMITER ;

-- Sample Execution

-- SELECT * FROM Application_Status_View;
-- SELECT * FROM Most_Applied_Job_View;
-- SELECT * FROM Job_Application_Ranking;
-- CALL GetJobApplicationCount(101);