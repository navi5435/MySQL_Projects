
 -- 16. Warehouse Management System


-- Create Database
CREATE DATABASE 16_SqlPrj_warehouse_db;
USE 16_SqlPrj_warehouse_db;

-- Create Tables

CREATE TABLE Items (
    ItemID INT PRIMARY KEY,
    ItemName VARCHAR(100),
    Category VARCHAR(50),
    UnitPrice DECIMAL(10,2)
);

CREATE TABLE Locations (
    LocationID INT PRIMARY KEY,
    LocationName VARCHAR(100),
    Capacity INT
);

-- Shipments Table
-- MovementType: IN (Stock In) / OUT (Stock Out)

CREATE TABLE Shipments (
    ShipmentID INT PRIMARY KEY,
    ItemID INT,
    LocationID INT,
    Quantity INT,
    MovementType VARCHAR(10),
    ShipmentDate DATE,
    FOREIGN KEY (ItemID) REFERENCES Items(ItemID),
    FOREIGN KEY (LocationID) REFERENCES Locations(LocationID)
);

-- Insert Records To Each Tables

-- Items
INSERT INTO Items VALUES
(1,'Laptop','Electronics',50000),
(2,'Mouse','Electronics',500),
(3,'Keyboard','Electronics',1500),
(4,'Monitor','Electronics',12000),
(5,'Chair','Furniture',3000),
(6,'Table','Furniture',7000),
(7,'Printer','Electronics',10000),
(8,'Scanner','Electronics',8000),
(9,'Router','Electronics',4000),
(10,'Fan','Appliances',2500);

-- Locations
INSERT INTO Locations VALUES
(1,'Warehouse A',1000),
(2,'Warehouse B',800),
(3,'Warehouse C',1200),
(4,'Warehouse D',600),
(5,'Warehouse E',900),
(6,'Warehouse F',1100),
(7,'Warehouse G',750),
(8,'Warehouse H',950),
(9,'Warehouse I',850),
(10,'Warehouse J',1000);

-- Shipments
INSERT INTO Shipments VALUES
(101,1,1,50,'IN','2024-01-01'),
(102,1,1,10,'OUT','2024-01-05'),
(103,2,2,200,'IN','2024-01-02'),
(104,2,2,50,'OUT','2024-01-06'),
(105,3,3,150,'IN','2024-01-03'),
(106,4,4,80,'IN','2024-01-04'),
(107,5,5,60,'IN','2024-01-07'),
(108,6,6,40,'IN','2024-01-08'),
(109,1,1,20,'IN','2024-01-09'),
(110,1,1,15,'OUT','2024-01-10');

-- Indexes

CREATE INDEX idx_item_category ON Items(Category);
CREATE INDEX idx_shipment_date ON Shipments(ShipmentDate);
CREATE INDEX idx_movement_type ON Shipments(MovementType);

-- View: Stock Movement Tracking

CREATE VIEW Stock_Movement_View AS
SELECT 
    i.ItemName,
    l.LocationName,
    s.Quantity,
    s.MovementType,
    s.ShipmentDate
FROM Shipments s
JOIN Items i ON s.ItemID = i.ItemID
JOIN Locations l ON s.LocationID = l.LocationID;

-- View: Current Stock Per Item (IN - OUT)

CREATE VIEW Current_Stock_View AS
SELECT 
    i.ItemID,
    i.ItemName,
    SUM(CASE 
            WHEN s.MovementType = 'IN' THEN s.Quantity
            WHEN s.MovementType = 'OUT' THEN -s.Quantity
        END) AS CurrentStock
FROM Items i
LEFT JOIN Shipments s ON i.ItemID = s.ItemID
GROUP BY i.ItemID, i.ItemName;

-- FIFO Logic View (First-In-First-Out)

-- Shows stock batches ordered by oldest shipment first

CREATE VIEW FIFO_Stock_View AS
SELECT 
    s.ShipmentID,
    i.ItemName,
    s.Quantity,
    s.ShipmentDate,
    SUM(s.Quantity) OVER (
        PARTITION BY s.ItemID 
        ORDER BY s.ShipmentDate
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS CumulativeStock
FROM Shipments s
JOIN Items i ON s.ItemID = i.ItemID
WHERE s.MovementType = 'IN';

-- Stored Procedure: Add Shipment

DELIMITER //

CREATE PROCEDURE AddShipment(
    IN p_ShipmentID INT,
    IN p_ItemID INT,
    IN p_LocationID INT,
    IN p_Quantity INT,
    IN p_MovementType VARCHAR(10),
    IN p_Date DATE
)
BEGIN
    INSERT INTO Shipments
    VALUES(p_ShipmentID, p_ItemID, p_LocationID,
           p_Quantity, p_MovementType, p_Date);
END //

DELIMITER ;

-- Stored Procedure: Get Item Stock

DELIMITER //

CREATE PROCEDURE GetItemStock(IN p_ItemID INT)
BEGIN
    SELECT 
        i.ItemName,
        SUM(CASE 
                WHEN s.MovementType = 'IN' THEN s.Quantity
                WHEN s.MovementType = 'OUT' THEN -s.Quantity
            END) AS CurrentStock
    FROM Items i
    LEFT JOIN Shipments s ON i.ItemID = s.ItemID
    WHERE i.ItemID = p_ItemID
    GROUP BY i.ItemName;
END //

DELIMITER ;


-- Sample Execution

-- SELECT * FROM Stock_Movement_View;
-- SELECT * FROM Current_Stock_View;
-- SELECT * FROM FIFO_Stock_View;
-- CALL GetItemStock(1);
