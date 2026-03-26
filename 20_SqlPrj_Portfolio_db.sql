
-- 20. Stock Market Portfolio Tracker


-- Create Database
CREATE DATABASE 20_SqlPrj_portfolio_db;
USE 20_SqlPrj_portfolio_db;

-- Create Tables

CREATE TABLE Investors (
    InvestorID INT PRIMARY KEY,
    InvestorName VARCHAR(100),
    Email VARCHAR(100),
    City VARCHAR(50)
);

CREATE TABLE Stocks (
    StockID INT PRIMARY KEY,
    StockName VARCHAR(100),
    TickerSymbol VARCHAR(10),
    Price DECIMAL(10,2),
    PriceDate DATE
);

CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY,
    InvestorID INT,
    StockID INT,
    TransactionType VARCHAR(10), -- BUY / SELL
    Quantity INT,
    PriceAtTransaction DECIMAL(10,2),
    TransactionDate DATE,
    FOREIGN KEY (InvestorID) REFERENCES Investors(InvestorID),
    FOREIGN KEY (StockID) REFERENCES Stocks(StockID)
);

-- Inserting Records To Each Tables

-- Investors
INSERT INTO Investors VALUES
(1,'Naveen Kumar','naveen@gmail.com','Bangalore'),
(2,'Rahul Sharma','rahul@gmail.com','Mumbai'),
(3,'Priya Singh','priya@gmail.com','Delhi'),
(4,'Amit Patel','amit@gmail.com','Ahmedabad'),
(5,'Sneha Reddy','sneha@gmail.com','Hyderabad'),
(6,'Kiran Rao','kiran@gmail.com','Chennai'),
(7,'Anjali Mehta','anjali@gmail.com','Pune'),
(8,'Vikram Das','vikram@gmail.com','Kolkata'),
(9,'Arjun Nair','arjun@gmail.com','Kochi'),
(10,'Meera Iyer','meera@gmail.com','Coimbatore');

-- Stocks 
INSERT INTO Stocks VALUES
(1,'Reliance Industries','RELIANCE',2500,'2024-03-01'),
(2,'TCS','TCS',3800,'2024-03-01'),
(3,'Infosys','INFY',1500,'2024-03-01'),
(4,'HDFC Bank','HDFCBANK',1600,'2024-03-01'),
(5,'ICICI Bank','ICICIBANK',900,'2024-03-01'),
(6,'Wipro','WIPRO',450,'2024-03-01'),
(7,'SBI','SBIN',600,'2024-03-01'),
(8,'Adani Ports','ADANIPORTS',850,'2024-03-01'),
(9,'ITC','ITC',420,'2024-03-01'),
(10,'L&T','LT',3200,'2024-03-01');

-- Transactions
INSERT INTO Transactions VALUES
(101,1,1,'BUY',10,2400,'2024-02-15'),
(102,2,2,'BUY',5,3700,'2024-02-16'),
(103,3,3,'BUY',20,1400,'2024-02-17'),
(104,4,4,'BUY',15,1500,'2024-02-18'),
(105,5,5,'BUY',30,850,'2024-02-19'),
(106,6,6,'BUY',25,420,'2024-02-20'),
(107,7,7,'BUY',40,550,'2024-02-21'),
(108,8,8,'BUY',18,800,'2024-02-22'),
(109,9,9,'BUY',50,390,'2024-02-23'),
(110,10,10,'BUY',8,3100,'2024-02-24');

-- Indexes

CREATE INDEX idx_stock_symbol ON Stocks(TickerSymbol);
CREATE INDEX idx_transaction_investor ON Transactions(InvestorID);
CREATE INDEX idx_transaction_stock ON Transactions(StockID);

-- View: Latest Stock Price (Window Function)

CREATE VIEW Latest_Stock_Price AS
SELECT StockID, StockName, TickerSymbol, Price, PriceDate
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY StockID ORDER BY PriceDate DESC) AS rn
    FROM Stocks
) AS ranked
WHERE rn = 1;

-- View: Investor Portfolio Profit/Loss

CREATE VIEW Investor_Profit_Loss AS
SELECT 
    i.InvestorID,
    i.InvestorName,
    s.StockName,
    SUM(t.Quantity) AS TotalShares,
    SUM(t.Quantity * t.PriceAtTransaction) AS TotalInvestment,
    SUM(t.Quantity * l.Price) AS CurrentValue,
    (SUM(t.Quantity * l.Price) - 
     SUM(t.Quantity * t.PriceAtTransaction)) AS ProfitLoss
FROM Transactions t
JOIN Investors i ON t.InvestorID = i.InvestorID
JOIN Latest_Stock_Price l ON t.StockID = l.StockID
JOIN Stocks s ON t.StockID = s.StockID
GROUP BY i.InvestorID, i.InvestorName, s.StockName;

-- Stored Procedure: Add Transaction

DELIMITER //

CREATE PROCEDURE AddTransaction(
    IN p_TransactionID INT,
    IN p_InvestorID INT,
    IN p_StockID INT,
    IN p_Type VARCHAR(10),
    IN p_Qty INT,
    IN p_Price DECIMAL(10,2),
    IN p_Date DATE
)
BEGIN
    INSERT INTO Transactions
    VALUES(p_TransactionID, p_InvestorID, p_StockID,
           p_Type, p_Qty, p_Price, p_Date);
END //

DELIMITER ;

-- Stored Procedure: Get Investor Portfolio

DELIMITER //

CREATE PROCEDURE GetInvestorPortfolio(IN p_InvestorID INT)
BEGIN
    SELECT *
    FROM Investor_Profit_Loss
    WHERE InvestorID = p_InvestorID;
END //

DELIMITER ;


-- Sample Execution

-- SELECT * FROM Latest_Stock_Price;
-- SELECT * FROM Investor_Profit_Loss;
-- CALL GetInvestorPortfolio(1);