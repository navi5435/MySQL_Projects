
-- 14. CRM (Customer Relationship Management)

-- Create Database
CREATE DATABASE 14_SqlPrj_crm_db;
USE 14_SqlPrj_crm_db;

-- Create Tables

CREATE TABLE Sales_Rep (
    RepID INT PRIMARY KEY,
    RepName VARCHAR(100),
    Region VARCHAR(50),
    TargetAmount DECIMAL(12,2)
);

CREATE TABLE Leads (
    LeadID INT PRIMARY KEY,
    LeadName VARCHAR(100),
    Source VARCHAR(50),
    Status VARCHAR(20) DEFAULT 'Open',  -- Open / Converted / Lost
    CreatedDate DATE,
    RepID INT,
    FOREIGN KEY (RepID) REFERENCES Sales_Rep(RepID)
);

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    Industry VARCHAR(50),
    ConvertedFromLeadID INT,
    JoinDate DATE,
    FOREIGN KEY (ConvertedFromLeadID) REFERENCES Leads(LeadID)
);

CREATE TABLE Deals (
    DealID INT PRIMARY KEY,
    CustomerID INT,
    RepID INT,
    DealAmount DECIMAL(12,2),
    Stage VARCHAR(20), -- Prospect / Negotiation / Closed Won / Closed Lost
    ExpectedCloseDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (RepID) REFERENCES Sales_Rep(RepID)
);

-- Inserting Records To Each Tables

-- Sales Reps
INSERT INTO Sales_Rep VALUES
(1,'Amit','North',500000),
(2,'Priya','South',450000),
(3,'Rahul','East',400000),
(4,'Sneha','West',550000),
(5,'Karan','North',300000),
(6,'Anita','South',350000),
(7,'Rohit','East',600000),
(8,'Meera','West',480000),
(9,'Neha','North',520000),
(10,'Varun','South',420000);

-- Leads
INSERT INTO Leads VALUES
(101,'ABC Corp','Website','Converted','2024-01-01',1),
(102,'XYZ Ltd','Referral','Open','2024-01-05',2),
(103,'TechSoft','Ads','Lost','2024-01-10',3),
(104,'Global Inc','Website','Converted','2024-01-15',4),
(105,'DataSys','Referral','Converted','2024-01-20',5),
(106,'CloudNet','Ads','Open','2024-01-25',6),
(107,'NextGen','Website','Converted','2024-02-01',7),
(108,'BrightTech','Referral','Lost','2024-02-05',8),
(109,'InfoTech','Ads','Converted','2024-02-10',9),
(110,'FutureCorp','Website','Open','2024-02-15',10);

-- Customers
INSERT INTO Customers VALUES
(201,'ABC Corp','IT',101,'2024-02-01'),
(202,'Global Inc','Finance',104,'2024-02-10'),
(203,'DataSys','Healthcare',105,'2024-02-15'),
(204,'NextGen','IT',107,'2024-02-20'),
(205,'InfoTech','Retail',109,'2024-02-25'),
(206,'Alpha Ltd','Manufacturing',NULL,'2024-03-01'),
(207,'Beta Solutions','IT',NULL,'2024-03-05'),
(208,'Gamma Corp','Finance',NULL,'2024-03-10'),
(209,'Delta Tech','Healthcare',NULL,'2024-03-15'),
(210,'Epsilon Ltd','Retail',NULL,'2024-03-20');

-- Deals
INSERT INTO Deals VALUES
(301,201,1,120000,'Closed Won','2024-03-01'),
(302,202,4,150000,'Closed Won','2024-03-10'),
(303,203,5,80000,'Closed Won','2024-03-15'),
(304,204,7,200000,'Negotiation','2024-04-01'),
(305,205,9,175000,'Closed Won','2024-03-25'),
(306,206,2,90000,'Prospect','2024-04-10'),
(307,207,3,110000,'Closed Lost','2024-03-30'),
(308,208,6,130000,'Negotiation','2024-04-05'),
(309,209,8,95000,'Prospect','2024-04-15'),
(310,210,10,160000,'Negotiation','2024-04-20');

-- Indexes

CREATE INDEX idx_lead_status ON Leads(Status);
CREATE INDEX idx_deal_stage ON Deals(Stage);
CREATE INDEX idx_rep_region ON Sales_Rep(Region);

-- View: Conversion Rate Calculation

-- Conversion Rate = (Converted Leads / Total Leads) * 100

CREATE VIEW Conversion_Rate_View AS
SELECT 
    COUNT(CASE WHEN Status='Converted' THEN 1 END) AS ConvertedLeads,
    COUNT(*) AS TotalLeads,
    (COUNT(CASE WHEN Status='Converted' THEN 1 END) * 100.0 / COUNT(*)) AS ConversionRatePercentage
FROM Leads;

-- View: Revenue Forecasting

-- Forecast includes Negotiation & Prospect stages

CREATE VIEW Revenue_Forecast_View AS
SELECT 
    Stage,
    SUM(DealAmount) AS ForecastAmount
FROM Deals
WHERE Stage IN ('Negotiation','Prospect')
GROUP BY Stage;

-- Ranking Sales Reps by Revenue (Window Function)

CREATE VIEW SalesRep_Ranking AS
SELECT 
    s.RepID,
    s.RepName,
    SUM(d.DealAmount) AS TotalRevenue,
    RANK() OVER (ORDER BY SUM(d.DealAmount) DESC) AS RevenueRank
FROM Sales_Rep s
JOIN Deals d ON s.RepID = d.RepID
WHERE d.Stage='Closed Won'
GROUP BY s.RepID, s.RepName;

-- Stored Procedure: Update Lead Status

DELIMITER //

CREATE PROCEDURE UpdateLeadStatus(
    IN p_LeadID INT,
    IN p_Status VARCHAR(20)
)
BEGIN
    UPDATE Leads
    SET Status = p_Status
    WHERE LeadID = p_LeadID;
END //

DELIMITER ;

-- Stored Procedure: Get Rep Performance

DELIMITER //

CREATE PROCEDURE GetRepPerformance(IN p_RepID INT)
BEGIN
    SELECT 
        s.RepName,
        SUM(d.DealAmount) AS TotalRevenue,
        s.TargetAmount,
        (SUM(d.DealAmount) - s.TargetAmount) AS TargetDifference
    FROM Sales_Rep s
    LEFT JOIN Deals d ON s.RepID = d.RepID AND d.Stage='Closed Won'
    WHERE s.RepID = p_RepID
    GROUP BY s.RepName, s.TargetAmount;
END //

DELIMITER ;

-- Sample Execution

-- SELECT * FROM Conversion_Rate_View;
-- SELECT * FROM Revenue_Forecast_View;
-- SELECT * FROM SalesRep_Ranking;
-- CALL GetRepPerformance(1);
