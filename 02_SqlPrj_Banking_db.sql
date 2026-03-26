
-- 2. Online Banking System

-- Create Database

CREATE DATABASE IF NOT EXISTS 2_SqlPrj_banking_db;

USE 2_SqlPrj_banking_db;

-- Create Tables

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    city VARCHAR(50)
);

CREATE TABLE Accounts (
    account_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    account_type VARCHAR(30),
    balance DECIMAL(12,2),
    status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE Transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    account_id INT,
    transaction_type VARCHAR(20), -- Deposit / Withdrawal
    amount DECIMAL(12,2),
    transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES Accounts(account_id)
);

CREATE TABLE Loans (
    loan_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    loan_type VARCHAR(50),
    loan_amount DECIMAL(12,2),
    interest_rate DECIMAL(5,2),
    loan_status VARCHAR(30),
    issued_date DATE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Inserting records for each table

-- Customers
INSERT INTO Customers (first_name,last_name,email,phone,city) VALUES
('Naveen','Kumar','naveen@bank.com','9000000011','Bangalore'),
('Amit','Sharma','amit@bank.com','9000000012','Delhi'),
('Priya','Rao','priya@bank.com','9000000013','Hyderabad'),
('Rahul','Verma','rahul@bank.com','9000000014','Mumbai'),
('Sneha','Reddy','sneha@bank.com','9000000015','Chennai'),
('Arjun','Mehta','arjun@bank.com','9000000016','Pune'),
('Kiran','Patel','kiran@bank.com','9000000017','Ahmedabad'),
('Divya','Singh','divya@bank.com','9000000018','Jaipur'),
('Vikram','Das','vikram@bank.com','9000000019','Kolkata'),
('Anjali','Nair','anjali@bank.com','9000000020','Kochi');

SELECT * FROM Customers;

-- Accounts
INSERT INTO Accounts (customer_id,account_type,balance,status) VALUES
(1,'Savings',50000,'Active'),
(2,'Current',75000,'Active'),
(3,'Savings',30000,'Active'),
(4,'Savings',45000,'Active'),
(5,'Current',100000,'Active'),
(6,'Savings',25000,'Active'),
(7,'Current',60000,'Active'),
(8,'Savings',35000,'Active'),
(9,'Savings',40000,'Active'),
(10,'Current',80000,'Active');

SELECT * FROM Accounts;

-- Transactions
INSERT INTO Transactions (account_id,transaction_type,amount) VALUES
(1,'Deposit',10000),
(2,'Withdrawal',5000),
(3,'Deposit',15000),
(4,'Withdrawal',7000),
(5,'Deposit',20000),
(6,'Deposit',8000),
(7,'Withdrawal',10000),
(8,'Deposit',12000),
(9,'Withdrawal',6000),
(10,'Deposit',25000);

SELECT * FROM Transactions;
-- Loans
INSERT INTO Loans (customer_id,loan_type,loan_amount,interest_rate,loan_status,issued_date) VALUES
(1,'Home Loan',2000000,7.5,'Approved','2024-01-01'),
(2,'Car Loan',500000,8.2,'Approved','2024-02-01'),
(3,'Personal Loan',200000,10.5,'Pending','2024-03-01'),
(4,'Education Loan',800000,6.8,'Approved','2024-04-01'),
(5,'Business Loan',1500000,9.0,'Approved','2024-05-01'),
(6,'Car Loan',400000,8.0,'Rejected','2024-06-01'),
(7,'Home Loan',2500000,7.2,'Approved','2024-07-01'),
(8,'Personal Loan',300000,11.0,'Pending','2024-08-01'),
(9,'Education Loan',600000,6.5,'Approved','2024-09-01'),
(10,'Business Loan',1200000,9.5,'Approved','2024-10-01');

SELECT * FROM Loans;

-- Indexes
CREATE INDEX idx_customer_email ON Customers(email);
CREATE INDEX idx_account_customer ON Accounts(customer_id);
CREATE INDEX idx_transaction_account ON Transactions(account_id);
CREATE INDEX idx_loan_status ON Loans(loan_status);

-- Transaction Example (Money Transfer)

-- Transfer 5000 from Account 1 to Account 2
START TRANSACTION;

UPDATE Accounts SET balance = balance - 5000 WHERE account_id = 1;
UPDATE Accounts SET balance = balance + 5000 WHERE account_id = 2;

-- If everything correct
COMMIT;

-- If error happens, use:
-- ROLLBACK;

-- View (Customer Account Summary)

CREATE VIEW Customer_Account_Summary AS
SELECT 
    c.customer_id,
    c.first_name,
    a.account_type,
    a.balance
FROM Customers c
JOIN Accounts a ON c.customer_id = a.customer_id;

-- (Loan Summary)

CREATE VIEW Loan_Summary AS
SELECT 
    c.first_name,
    l.loan_type,
    l.loan_amount,
    l.loan_status
FROM Loans l
JOIN Customers c ON l.customer_id = c.customer_id;

-- Stored Procedure (Deposit Money)

DELIMITER //

CREATE PROCEDURE DepositMoney(
    IN acc_id INT,
    IN deposit_amount DECIMAL(12,2)
)
BEGIN
    START TRANSACTION;

    UPDATE Accounts
    SET balance = balance + deposit_amount
    WHERE account_id = acc_id;

    INSERT INTO Transactions(account_id,transaction_type,amount)
    VALUES(acc_id,'Deposit',deposit_amount);

    COMMIT;
END;
//

DELIMITER ;

-- Stored Procedure (Withdraw Money with Balance Check)

DELIMITER //

CREATE PROCEDURE WithdrawMoney(
    IN acc_id INT,
    IN withdraw_amount DECIMAL(12,2)
)
BEGIN
    DECLARE current_balance DECIMAL(12,2);

    SELECT balance INTO current_balance
    FROM Accounts
    WHERE account_id = acc_id;

    IF current_balance >= withdraw_amount THEN
        START TRANSACTION;

        UPDATE Accounts
        SET balance = balance - withdraw_amount
        WHERE account_id = acc_id;

        INSERT INTO Transactions(account_id,transaction_type,amount)
        VALUES(acc_id,'Withdrawal',withdraw_amount);

        COMMIT;
    ELSE
        ROLLBACK;
    END IF;
END;
//

DELIMITER ;

-- Window Function Queries

-- 1. Rank customers by account balance
SELECT 
    account_id,
    balance,
    RANK() OVER (ORDER BY balance DESC) AS balance_rank
FROM Accounts;

-- 2. Running Total of Transactions per Account
SELECT 
    account_id,
    transaction_date,
    amount,
    SUM(amount) OVER (PARTITION BY account_id ORDER BY transaction_date) AS running_total
FROM Transactions;

-- 3. Highest Loan Amount per Loan Type
SELECT *
FROM (
    SELECT loan_type,
           loan_amount,
           ROW_NUMBER() OVER (PARTITION BY loan_type ORDER BY loan_amount DESC) AS rn
    FROM Loans
) t
WHERE rn = 1;
