
-- 9. Hotel Booking System


CREATE DATABASE 9_SqlPrj_hotel_db;
USE 9_SqlPrj_hotel_db;


CREATE TABLE Rooms (
    RoomID INT PRIMARY KEY,
    RoomNumber VARCHAR(10) UNIQUE,
    RoomType VARCHAR(50),
    PricePerNight DECIMAL(10,2),
    Status VARCHAR(20)
);


CREATE TABLE Guests (
    GuestID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Phone VARCHAR(15),
    Email VARCHAR(100)
);


CREATE TABLE Reservations (
    ReservationID INT PRIMARY KEY,
    RoomID INT,
    GuestID INT,
    CheckInDate DATE,
    CheckOutDate DATE,
    TotalAmount DECIMAL(10,2),
    FOREIGN KEY (RoomID) REFERENCES Rooms(RoomID),
    FOREIGN KEY (GuestID) REFERENCES Guests(GuestID)
);


CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY,
    ReservationID INT,
    PaymentDate DATE,
    AmountPaid DECIMAL(10,2),
    PaymentMethod VARCHAR(50),
    FOREIGN KEY (ReservationID) REFERENCES Reservations(ReservationID)
);

-- INSERT RECORDS INTO TABLES

INSERT INTO Rooms VALUES
(1,'101','Single',2000,'Available'),
(2,'102','Double',3000,'Available'),
(3,'103','Suite',5000,'Available'),
(4,'104','Single',2000,'Available'),
(5,'105','Double',3000,'Available'),
(6,'106','Suite',5500,'Available'),
(7,'107','Single',2200,'Available'),
(8,'108','Double',3200,'Available'),
(9,'109','Suite',6000,'Available'),
(10,'110','Single',2100,'Available');

-- Guests

INSERT INTO Guests VALUES
(1,'Naveen','Kumar','9876543210','naveen1@gmail.com'),
(2,'Rahul','Sharma','9876543211','rahul@gmail.com'),
(3,'Priya','Verma','9876543212','priya@gmail.com'),
(4,'Amit','Singh','9876543213','amit@gmail.com'),
(5,'Sneha','Reddy','9876543214','sneha@gmail.com'),
(6,'Kiran','Das','9876543215','kiran@gmail.com'),
(7,'Arjun','Patel','9876543216','arjun@gmail.com'),
(8,'Meena','Iyer','9876543217','meena@gmail.com'),
(9,'Ravi','Kumar','9876543218','ravi@gmail.com'),
(10,'Anjali','Roy','9876543219','anjali@gmail.com');

-- Reservations
INSERT INTO Reservations VALUES
(1,1,1,'2026-03-01','2026-03-05',8000),
(2,2,2,'2026-03-02','2026-03-06',12000),
(3,3,3,'2026-03-04','2026-03-07',15000),
(4,4,4,'2026-03-08','2026-03-10',4000),
(5,5,5,'2026-03-09','2026-03-12',9000),
(6,6,6,'2026-03-11','2026-03-15',22000),
(7,7,7,'2026-03-13','2026-03-16',6600),
(8,8,8,'2026-03-14','2026-03-18',12800),
(9,9,9,'2026-03-16','2026-03-20',24000),
(10,10,10,'2026-03-18','2026-03-22',8400);

-- Payments

INSERT INTO Payments VALUES
(1,1,'2026-03-01',8000,'UPI'),
(2,2,'2026-03-02',12000,'Card'),
(3,3,'2026-03-04',15000,'Cash'),
(4,4,'2026-03-08',4000,'UPI'),
(5,5,'2026-03-09',9000,'Card'),
(6,6,'2026-03-11',22000,'UPI'),
(7,7,'2026-03-13',6600,'Cash'),
(8,8,'2026-03-14',12800,'Card'),
(9,9,'2026-03-16',24000,'UPI'),
(10,10,'2026-03-18',8400,'Cash');


-- INDEXES

CREATE INDEX idx_room_type ON Rooms(RoomType);
CREATE INDEX idx_guest_phone ON Guests(Phone);
CREATE INDEX idx_reservation_dates ON Reservations(CheckInDate, CheckOutDate);
CREATE INDEX idx_payment_date ON Payments(PaymentDate);


-- DATE OVERLAPPING LOGIC (Availability Check)

-- Check if Room 1 is available between two dates
SELECT *
FROM Reservations
WHERE RoomID = 1
AND (
    ('2026-03-03' BETWEEN CheckInDate AND CheckOutDate)
    OR
    ('2026-03-04' BETWEEN CheckInDate AND CheckOutDate)
);


-- AVAILABILITY CHECK QUERY

SELECT *
FROM Rooms r
WHERE r.RoomID NOT IN (
    SELECT RoomID
    FROM Reservations
    WHERE '2026-03-10' < CheckOutDate
    AND '2026-03-05' > CheckInDate
);

-- STORED PROCEDURE FOR CHECKING AVAILABILITY

DELIMITER //

CREATE PROCEDURE CheckRoomAvailability (
    IN p_RoomID INT,
    IN p_CheckIn DATE,
    IN p_CheckOut DATE
)
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Reservations
        WHERE RoomID = p_RoomID
        AND p_CheckIn < CheckOutDate
        AND p_CheckOut > CheckInDate
    )
    THEN
        SELECT 'Room is NOT Available' AS Status;
    ELSE
        SELECT 'Room is Available' AS Status;
    END IF;
END //

DELIMITER ;

-- To Call Procedure:
-- CALL CheckRoomAvailability(1,'2026-03-02','2026-03-04');

-- VIEWS

-- 1. View: Reservation Details
CREATE VIEW View_ReservationDetails AS
SELECT r.ReservationID, g.FirstName, g.LastName,
       rm.RoomNumber, r.CheckInDate, r.CheckOutDate, r.TotalAmount
FROM Reservations r
JOIN Guests g ON r.GuestID = g.GuestID
JOIN Rooms rm ON r.RoomID = rm.RoomID;

-- 2. View: Payment Summary
CREATE VIEW View_PaymentSummary AS
SELECT p.PaymentID, g.FirstName, rm.RoomNumber,
       p.AmountPaid, p.PaymentMethod, p.PaymentDate
FROM Payments p
JOIN Reservations r ON p.ReservationID = r.ReservationID
JOIN Guests g ON r.GuestID = g.GuestID
JOIN Rooms rm ON r.RoomID = rm.RoomID;