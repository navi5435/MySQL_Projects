
-- 18. Subscription Billing System


-- Create Database
CREATE DATABASE 18_SqlPrj_subscription_db;
USE 18_SqlPrj_subscription_db;

-- Create Tables

CREATE TABLE Plans (
    PlanID INT PRIMARY KEY,
    PlanName VARCHAR(100),
    Price DECIMAL(10,2),
    DurationMonths INT   -- Duration of subscription
);

CREATE TABLE Users (
    UserID INT PRIMARY KEY,
    UserName VARCHAR(100),
    Email VARCHAR(100),
    PlanID INT,
    SubscriptionStart DATE,
    FOREIGN KEY (PlanID) REFERENCES Plans(PlanID)
);

CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY,
    UserID INT,
    PaymentDate DATE,
    AmountPaid DECIMAL(10,2),
    PaymentStatus VARCHAR(20), -- Completed / Failed / Pending
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- Inserting Records To Each Tables

-- Plans
INSERT INTO Plans VALUES
(1,'Basic',499,1),
(2,'Standard',999,3),
(3,'Premium',1999,6),
(4,'Enterprise',4999,12),
(5,'Student',299,1),
(6,'Pro',1499,3),
(7,'Gold',2499,6),
(8,'Platinum',5999,12),
(9,'Family',1999,3),
(10,'Trial',0,1);

-- Users
INSERT INTO Users VALUES
(101,'Amit','amit@gmail.com',1,'2024-01-01'),
(102,'Priya','priya@gmail.com',2,'2024-01-10'),
(103,'Rahul','rahul@gmail.com',3,'2024-02-01'),
(104,'Sneha','sneha@gmail.com',4,'2024-01-15'),
(105,'Karan','karan@gmail.com',5,'2024-02-20'),
(106,'Anita','anita@gmail.com',6,'2024-03-01'),
(107,'Rohit','rohit@gmail.com',7,'2024-01-25'),
(108,'Meera','meera@gmail.com',8,'2024-02-05'),
(109,'Neha','neha@gmail.com',9,'2024-03-10'),
(110,'Varun','varun@gmail.com',10,'2024-03-15');

-- Payments
INSERT INTO Payments VALUES
(201,101,'2024-01-01',499,'Completed'),
(202,102,'2024-01-10',999,'Completed'),
(203,103,'2024-02-01',1999,'Completed'),
(204,104,'2024-01-15',4999,'Completed'),
(205,105,'2024-02-20',299,'Completed'),
(206,106,'2024-03-01',1499,'Completed'),
(207,107,'2024-01-25',2499,'Completed'),
(208,108,'2024-02-05',5999,'Completed'),
(209,109,'2024-03-10',1999,'Pending'),
(210,110,'2024-03-15',0,'Completed');


-- Indexes

CREATE INDEX idx_user_plan ON Users(PlanID);
CREATE INDEX idx_payment_status ON Payments(PaymentStatus);
CREATE INDEX idx_subscription_start ON Users(SubscriptionStart);

-- View: Expiry Calculation

-- Expiry Date = SubscriptionStart + Plan Duration

CREATE VIEW Subscription_Expiry_View AS
SELECT 
    u.UserID,
    u.UserName,
    p.PlanName,
    u.SubscriptionStart,
    DATE_ADD(u.SubscriptionStart, INTERVAL p.DurationMonths MONTH) AS ExpiryDate
FROM Users u
JOIN Plans p ON u.PlanID = p.PlanID;

-- View: Active vs Expired Users

CREATE VIEW Active_Expired_Status_View AS
SELECT 
    u.UserID,
    u.UserName,
    p.PlanName,
    DATE_ADD(u.SubscriptionStart, INTERVAL p.DurationMonths MONTH) AS ExpiryDate,
    CASE
        WHEN DATE_ADD(u.SubscriptionStart, INTERVAL p.DurationMonths MONTH) >= CURDATE()
        THEN 'Active'
        ELSE 'Expired'
    END AS SubscriptionStatus
FROM Users u
JOIN Plans p ON u.PlanID = p.PlanID;

-- Ranking Plans by Revenue (Window Function)

CREATE VIEW Plan_Revenue_Ranking AS
SELECT 
    p.PlanName,
    SUM(pay.AmountPaid) AS TotalRevenue,
    RANK() OVER (ORDER BY SUM(pay.AmountPaid) DESC) AS RevenueRank
FROM Plans p
JOIN Users u ON p.PlanID = u.PlanID
JOIN Payments pay ON u.UserID = pay.UserID
WHERE pay.PaymentStatus = 'Completed'
GROUP BY p.PlanName;

-- Stored Procedure: Add Payment

DELIMITER //

CREATE PROCEDURE AddPayment(
    IN p_PaymentID INT,
    IN p_UserID INT,
    IN p_Date DATE,
    IN p_Amount DECIMAL(10,2),
    IN p_Status VARCHAR(20)
)
BEGIN
    INSERT INTO Payments
    VALUES(p_PaymentID, p_UserID, p_Date, p_Amount, p_Status);
END //

DELIMITER ;

-- Stored Procedure: Get User Subscription Status

DELIMITER //

CREATE PROCEDURE GetUserSubscriptionStatus(IN p_UserID INT)
BEGIN
    SELECT 
        u.UserName,
        p.PlanName,
        DATE_ADD(u.SubscriptionStart, INTERVAL p.DurationMonths MONTH) AS ExpiryDate,
        CASE
            WHEN DATE_ADD(u.SubscriptionStart, INTERVAL p.DurationMonths MONTH) >= CURDATE()
            THEN 'Active'
            ELSE 'Expired'
        END AS SubscriptionStatus
    FROM Users u
    JOIN Plans p ON u.PlanID = p.PlanID
    WHERE u.UserID = p_UserID;
END //

DELIMITER ;


-- Sample Execution

-- SELECT * FROM Subscription_Expiry_View;
-- SELECT * FROM Active_Expired_Status_View;
-- SELECT * FROM Plan_Revenue_Ranking;
-- CALL GetUserSubscriptionStatus(101);