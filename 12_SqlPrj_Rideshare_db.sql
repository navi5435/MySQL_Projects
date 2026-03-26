
-- 12. Ride Sharing System (Like Uber)

-- Create Database
CREATE DATABASE 12_SqlPrj_rideshare_db;
USE 12_SqlPrj_rideshare_db;

-- Create Tables

CREATE TABLE Drivers (
    DriverID INT PRIMARY KEY,
    DriverName VARCHAR(100),
    Phone VARCHAR(15),
    VehicleType VARCHAR(50),
    Rating DECIMAL(3,2)
);

CREATE TABLE Riders (
    RiderID INT PRIMARY KEY,
    RiderName VARCHAR(100),
    Phone VARCHAR(15),
    City VARCHAR(50)
);

CREATE TABLE Trips (
    TripID INT PRIMARY KEY,
    DriverID INT,
    RiderID INT,
    StartLocation VARCHAR(100),
    EndLocation VARCHAR(100),
    DistanceKM DECIMAL(6,2),
    BaseFare DECIMAL(8,2),
    TripDate DATE,
    FOREIGN KEY (DriverID) REFERENCES Drivers(DriverID),
    FOREIGN KEY (RiderID) REFERENCES Riders(RiderID)
);

CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY,
    TripID INT,
    PaymentMethod VARCHAR(50),
    PaymentStatus VARCHAR(20),
    FOREIGN KEY (TripID) REFERENCES Trips(TripID)
);


-- Inserting Records To Each Tables

-- Drivers 
INSERT INTO Drivers VALUES
(1,'Raj Kumar','9876500001','Sedan',4.5),
(2,'Arjun Singh','9876500002','SUV',4.7),
(3,'Vikram Rao','9876500003','Mini',4.2),
(4,'Karthik R','9876500004','Sedan',4.8),
(5,'Suresh P','9876500005','SUV',4.4),
(6,'Mahesh T','9876500006','Mini',4.1),
(7,'Ravi K','9876500007','Sedan',4.6),
(8,'Deepak N','9876500008','SUV',4.3),
(9,'Ajay L','9876500009','Mini',4.0),
(10,'Manoj D','9876500010','Sedan',4.9);

-- Riders
INSERT INTO Riders VALUES
(1,'Amit','9000000001','Bangalore'),
(2,'Priya','9000000002','Mumbai'),
(3,'Rahul','9000000003','Delhi'),
(4,'Sneha','9000000004','Chennai'),
(5,'Kiran','9000000005','Hyderabad'),
(6,'Anita','9000000006','Pune'),
(7,'Rohit','9000000007','Kolkata'),
(8,'Meera','9000000008','Ahmedabad'),
(9,'Neha','9000000009','Jaipur'),
(10,'Varun','9000000010','Coimbatore');

-- Trips
INSERT INTO Trips VALUES
(101,1,1,'A','B',10,50,'2024-01-01'),
(102,2,2,'C','D',15,50,'2024-01-02'),
(103,3,3,'E','F',8,50,'2024-01-03'),
(104,4,4,'G','H',20,50,'2024-01-04'),
(105,5,5,'I','J',12,50,'2024-01-05'),
(106,6,6,'K','L',5,50,'2024-01-06'),
(107,7,7,'M','N',18,50,'2024-01-07'),
(108,8,8,'O','P',9,50,'2024-01-08'),
(109,9,9,'Q','R',14,50,'2024-01-09'),
(110,10,10,'S','T',7,50,'2024-01-10');

-- Payments
INSERT INTO Payments VALUES
(1001,101,'UPI','Completed'),
(1002,102,'Card','Completed'),
(1003,103,'Cash','Pending'),
(1004,104,'UPI','Completed'),
(1005,105,'Card','Completed'),
(1006,106,'Cash','Completed'),
(1007,107,'UPI','Pending'),
(1008,108,'Card','Completed'),
(1009,109,'Cash','Completed'),
(1010,110,'UPI','Completed');

-- Indexes

CREATE INDEX idx_driver_rating ON Drivers(Rating);
CREATE INDEX idx_trip_date ON Trips(TripDate);
CREATE INDEX idx_payment_status ON Payments(PaymentStatus);

-- Distance & Fare Calculation View

-- Assume Fare Formula:
-- TotalFare = BaseFare + (DistanceKM * 12)

CREATE VIEW Trip_Fare_Details AS
SELECT 
    t.TripID,
    d.DriverName,
    r.RiderName,
    t.DistanceKM,
    t.BaseFare,
    (t.BaseFare + (t.DistanceKM * 12)) AS TotalFare,
    t.TripDate
FROM Trips t
JOIN Drivers d ON t.DriverID = d.DriverID
JOIN Riders r ON t.RiderID = r.RiderID;

-- Window Function View

-- Ranking drivers based on total earnings

CREATE VIEW Driver_Earnings_Rank AS
SELECT 
    d.DriverID,
    d.DriverName,
    SUM(t.BaseFare + (t.DistanceKM * 12)) AS TotalEarnings,
    RANK() OVER (ORDER BY SUM(t.BaseFare + (t.DistanceKM * 12)) DESC) AS EarningsRank
FROM Drivers d
JOIN Trips t ON d.DriverID = t.DriverID
GROUP BY d.DriverID, d.DriverName;

-- Stored Procedure: Add New Trip

DELIMITER //

CREATE PROCEDURE AddTrip(
    IN p_TripID INT,
    IN p_DriverID INT,
    IN p_RiderID INT,
    IN p_Start VARCHAR(100),
    IN p_End VARCHAR(100),
    IN p_Distance DECIMAL(6,2),
    IN p_BaseFare DECIMAL(8,2),
    IN p_Date DATE
)
BEGIN
    INSERT INTO Trips
    VALUES(p_TripID, p_DriverID, p_RiderID, p_Start, p_End,
           p_Distance, p_BaseFare, p_Date);
END //

DELIMITER ;

-- Stored Procedure: Get Driver Total Earnings

DELIMITER //

CREATE PROCEDURE GetDriverEarnings(IN p_DriverID INT)
BEGIN
    SELECT 
        d.DriverName,
        SUM(t.BaseFare + (t.DistanceKM * 12)) AS TotalEarnings
    FROM Drivers d
    JOIN Trips t ON d.DriverID = t.DriverID
    WHERE d.DriverID = p_DriverID
    GROUP BY d.DriverName;
END //

DELIMITER ;

-- Sample Execution

-- SELECT * FROM Trip_Fare_Details;
-- SELECT * FROM Driver_Earnings_Rank;
-- CALL GetDriverEarnings(1);