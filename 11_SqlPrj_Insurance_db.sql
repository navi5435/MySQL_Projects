
-- 11. Insurance Claim Processing

-- Create Database
CREATE DATABASE 11_SqlPrj_insurance_db;
USE 11_SqlPrj_insurance_db;

-- Create Tables

CREATE TABLE Policyholders (
    PolicyholderID INT PRIMARY KEY,
    FullName VARCHAR(100),
    Phone VARCHAR(15),
    Email VARCHAR(100),
    Address VARCHAR(200)
);

CREATE TABLE Policies (
    PolicyID INT PRIMARY KEY,
    PolicyholderID INT,
    PolicyType VARCHAR(50),
    PremiumAmount DECIMAL(10,2),
    StartDate DATE,
    EndDate DATE,
    FOREIGN KEY (PolicyholderID) REFERENCES Policyholders(PolicyholderID)
);

CREATE TABLE Claims (
    ClaimID INT PRIMARY KEY,
    PolicyID INT,
    ClaimDate DATE,
    ClaimAmount DECIMAL(10,2),
    ApprovalStatus VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (PolicyID) REFERENCES Policies(PolicyID)
);

-- Inserting Records To Each Tables


-- Policyholders
INSERT INTO Policyholders VALUES
(1,'Amit Sharma','9876543210','amit@gmail.com','Delhi'),
(2,'Priya Verma','9876543211','priya@gmail.com','Mumbai'),
(3,'Rahul Singh','9876543212','rahul@gmail.com','Chennai'),
(4,'Sneha Reddy','9876543213','sneha@gmail.com','Hyderabad'),
(5,'Karan Mehta','9876543214','karan@gmail.com','Pune'),
(6,'Anjali Rao','9876543215','anjali@gmail.com','Bangalore'),
(7,'Vikram Patel','9876543216','vikram@gmail.com','Ahmedabad'),
(8,'Neha Kapoor','9876543217','neha@gmail.com','Kolkata'),
(9,'Rohan Das','9876543218','rohan@gmail.com','Jaipur'),
(10,'Meera Iyer','9876543219','meera@gmail.com','Coimbatore');

-- Policies
INSERT INTO Policies VALUES
(101,1,'Health',15000,'2023-01-01','2024-01-01'),
(102,2,'Vehicle',12000,'2023-02-01','2024-02-01'),
(103,3,'Life',20000,'2023-03-01','2024-03-01'),
(104,4,'Health',18000,'2023-04-01','2024-04-01'),
(105,5,'Vehicle',14000,'2023-05-01','2024-05-01'),
(106,6,'Life',22000,'2023-06-01','2024-06-01'),
(107,7,'Health',16000,'2023-07-01','2024-07-01'),
(108,8,'Vehicle',13000,'2023-08-01','2024-08-01'),
(109,9,'Life',21000,'2023-09-01','2024-09-01'),
(110,10,'Health',17000,'2023-10-01','2024-10-01');

-- Claims
INSERT INTO Claims VALUES
(1001,101,'2023-06-10',5000,'Pending'),
(1002,102,'2023-07-12',7000,'Approved'),
(1003,103,'2023-08-15',10000,'Rejected'),
(1004,104,'2023-09-18',6000,'Pending'),
(1005,105,'2023-10-20',8000,'Approved'),
(1006,106,'2023-11-25',15000,'Pending'),
(1007,107,'2023-12-05',9000,'Approved'),
(1008,108,'2023-12-15',4000,'Rejected'),
(1009,109,'2024-01-10',12000,'Pending'),
(1010,110,'2024-01-20',11000,'Approved');

-- Indexes

CREATE INDEX idx_policyholder_name
ON Policyholders(FullName);

CREATE INDEX idx_policy_type
ON Policies(PolicyType);

CREATE INDEX idx_claim_status
ON Claims(ApprovalStatus);

-- View: Detailed Claim Information

CREATE VIEW Claim_Details_View AS
SELECT 
    c.ClaimID,
    p.PolicyType,
    ph.FullName,
    c.ClaimAmount,
    c.ApprovalStatus,
    c.ClaimDate
FROM Claims c
JOIN Policies p ON c.PolicyID = p.PolicyID
JOIN Policyholders ph ON p.PolicyholderID = ph.PolicyholderID;

-- Aggregate Claim Amount

-- Total Claim Amount by Status
CREATE VIEW Total_Claim_By_Status AS
SELECT 
    ApprovalStatus,
    SUM(ClaimAmount) AS TotalAmount
FROM Claims
GROUP BY ApprovalStatus;

-- Stored Procedure: Update Claim Status (Workflow)

DELIMITER //

CREATE PROCEDURE UpdateClaimStatus(
    IN p_ClaimID INT,
    IN p_Status VARCHAR(20)
)
BEGIN
    UPDATE Claims
    SET ApprovalStatus = p_Status
    WHERE ClaimID = p_ClaimID;
END //

DELIMITER ;

-- Stored Procedure: Get Total Claim Amount by Policyholder

DELIMITER //

CREATE PROCEDURE GetTotalClaimByPolicyholder(
    IN p_PolicyholderID INT
)
BEGIN
    SELECT 
        ph.FullName,
        SUM(c.ClaimAmount) AS TotalClaimAmount
    FROM Claims c
    JOIN Policies p ON c.PolicyID = p.PolicyID
    JOIN Policyholders ph ON p.PolicyholderID = ph.PolicyholderID
    WHERE ph.PolicyholderID = p_PolicyholderID
    GROUP BY ph.FullName;
END //

DELIMITER ;


-- Sample Execution


-- CALL UpdateClaimStatus(1001,'Approved');
-- CALL GetTotalClaimByPolicyholder(1);

-- SELECT * FROM Claim_Details_View;
-- SELECT * FROM Total_Claim_By_Status;