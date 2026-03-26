
-- 10. Inventory Management System

CREATE DATABASE 10_SqlPrj_inventory_db;
USE 10_SqlPrj_inventory_db;

-- TABLE: Suppliers
CREATE TABLE Suppliers (
    SupplierID INT PRIMARY KEY,
    SupplierName VARCHAR(100) NOT NULL,
    ContactPerson VARCHAR(100),
    Phone VARCHAR(15),
    Email VARCHAR(100)
);

-- TABLE: Products
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    SupplierID INT,
    Price DECIMAL(10,2),
    Quantity INT DEFAULT 0,
    ReorderLevel INT,
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID)
);

-- Stock_Log
CREATE TABLE Stock_Log (
    LogID INT PRIMARY KEY AUTO_INCREMENT,
    ProductID INT,
    ChangeType VARCHAR(10),  -- IN / OUT
    QuantityChanged INT,
    ChangeDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Suppliers
INSERT INTO Suppliers VALUES
(1,'Tech Distributors','Raj Kumar','9876543210','tech@gmail.com'),
(2,'Global Traders','Anita Sharma','9876543211','global@gmail.com'),
(3,'Prime Supplies','Kiran Patel','9876543212','prime@gmail.com'),
(4,'Star Wholesalers','Sneha Reddy','9876543213','star@gmail.com'),
(5,'Mega Mart','Rahul Singh','9876543214','mega@gmail.com'),
(6,'NextGen Supply','Meena Iyer','9876543215','nextgen@gmail.com'),
(7,'Fresh Source','Arjun Das','9876543216','fresh@gmail.com'),
(8,'Elite Distributors','Priya Verma','9876543217','elite@gmail.com'),
(9,'Super Wholesale','Ravi Kumar','9876543218','super@gmail.com'),
(10,'Smart Traders','Anjali Roy','9876543219','smart@gmail.com');

-- Products
INSERT INTO Products VALUES
(1,'Laptop',1,60000,50,10),
(2,'Mouse',2,500,200,30),
(3,'Keyboard',3,1500,150,20),
(4,'Monitor',4,18000,40,8),
(5,'Printer',5,20000,25,5),
(6,'Router',6,3000,60,15),
(7,'Hard Disk',7,4500,80,20),
(8,'Pen Drive',8,800,300,50),
(9,'Webcam',9,3500,35,10),
(10,'Headphones',10,2500,70,15);


-- INSERT 10 RECORDS INTO Stock_Log

INSERT INTO Stock_Log (ProductID, ChangeType, QuantityChanged) VALUES
(1,'OUT',5),
(2,'OUT',20),
(3,'IN',30),
(4,'OUT',5),
(5,'OUT',3),
(6,'IN',15),
(7,'OUT',10),
(8,'OUT',60),
(9,'IN',10),
(10,'OUT',12);


-- INDEXES

CREATE INDEX idx_product_name ON Products(ProductName);
CREATE INDEX idx_supplier_name ON Suppliers(SupplierName);
CREATE INDEX idx_stock_product ON Stock_Log(ProductID);


-- STOCK UPDATE TRIGGER
-- Automatically updates product quantity

DELIMITER //

CREATE TRIGGER trg_StockUpdate
AFTER INSERT ON Stock_Log
FOR EACH ROW
BEGIN
    IF NEW.ChangeType = 'IN' THEN
        UPDATE Products
        SET Quantity = Quantity + NEW.QuantityChanged
        WHERE ProductID = NEW.ProductID;
    ELSEIF NEW.ChangeType = 'OUT' THEN
        UPDATE Products
        SET Quantity = Quantity - NEW.QuantityChanged
        WHERE ProductID = NEW.ProductID;
    END IF;
END //

DELIMITER ;


-- STORED PROCEDURE
-- Add Stock Entry Safely

DELIMITER //

CREATE PROCEDURE AddStockEntry (
    IN p_ProductID INT,
    IN p_ChangeType VARCHAR(10),
    IN p_Quantity INT
)
BEGIN
    INSERT INTO Stock_Log(ProductID, ChangeType, QuantityChanged)
    VALUES (p_ProductID, p_ChangeType, p_Quantity);
END //

DELIMITER ;

-- To Call:
-- CALL AddStockEntry(1,'IN',20);


-- LOW STOCK ALERT QUERY

SELECT ProductID, ProductName, Quantity, ReorderLevel
FROM Products
WHERE Quantity <= ReorderLevel;


-- VIEWS

-- 1. Product Stock Summary
CREATE VIEW View_ProductSummary AS
SELECT p.ProductID, p.ProductName, s.SupplierName,
       p.Price, p.Quantity, p.ReorderLevel
FROM Products p
JOIN Suppliers s ON p.SupplierID = s.SupplierID;

-- 2. Stock Movement History
CREATE VIEW View_StockHistory AS
SELECT sl.LogID, p.ProductName,
       sl.ChangeType, sl.QuantityChanged, sl.ChangeDate
FROM Stock_Log sl
JOIN Products p ON sl.ProductID = p.ProductID;