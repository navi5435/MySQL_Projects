
-- 19. Movie Ticket Booking System


-- Create Database
CREATE DATABASE 19_SqlPrj_movie_booking_db;
USE 19_SqlPrj_movie_booking_db;

-- Create Tables

CREATE TABLE Movies (
    MovieID INT PRIMARY KEY,
    MovieName VARCHAR(100),
    Genre VARCHAR(50),
    DurationMinutes INT
);

CREATE TABLE Theaters (
    TheaterID INT PRIMARY KEY,
    TheaterName VARCHAR(100),
    Location VARCHAR(100),
    TotalSeats INT
);

CREATE TABLE Shows (
    ShowID INT PRIMARY KEY,
    MovieID INT,
    TheaterID INT,
    ShowDate DATE,
    ShowTime TIME,
    TicketPrice DECIMAL(8,2),
    FOREIGN KEY (MovieID) REFERENCES Movies(MovieID),
    FOREIGN KEY (TheaterID) REFERENCES Theaters(TheaterID)
);

CREATE TABLE Bookings (
    BookingID INT PRIMARY KEY,
    ShowID INT,
    SeatsBooked INT,
    BookingDate DATE,
    FOREIGN KEY (ShowID) REFERENCES Shows(ShowID)
);

-- Inserting Records To Each Tables

-- Movies
INSERT INTO Movies VALUES
(1,'Inception','Sci-Fi',148),
(2,'Titanic','Romance',195),
(3,'Avengers','Action',180),
(4,'Interstellar','Sci-Fi',169),
(5,'Joker','Drama',122),
(6,'Frozen','Animation',102),
(7,'Gladiator','Historical',155),
(8,'Avatar','Sci-Fi',162),
(9,'Matrix','Sci-Fi',136),
(10,'Bahubali','Action',170);

-- Theaters
INSERT INTO Theaters VALUES
(1,'PVR Central','Bangalore',200),
(2,'INOX Mall','Mumbai',180),
(3,'Cinepolis','Delhi',220),
(4,'Sathyam','Chennai',150),
(5,'Asian Cinemas','Hyderabad',250),
(6,'IMAX Arena','Pune',300),
(7,'Miraj','Kolkata',170),
(8,'Carnival','Ahmedabad',190),
(9,'Raj Mandir','Jaipur',210),
(10,'Fun Cinemas','Coimbatore',160);

-- Shows
INSERT INTO Shows VALUES
(101,1,1,'2024-03-01','18:00:00',250),
(102,2,2,'2024-03-01','19:00:00',300),
(103,3,3,'2024-03-02','20:00:00',350),
(104,4,4,'2024-03-02','21:00:00',280),
(105,5,5,'2024-03-03','17:00:00',200),
(106,6,6,'2024-03-03','16:00:00',220),
(107,7,7,'2024-03-04','19:30:00',260),
(108,8,8,'2024-03-04','20:30:00',400),
(109,9,9,'2024-03-05','18:30:00',270),
(110,10,10,'2024-03-05','21:30:00',320);

-- Bookings
INSERT INTO Bookings VALUES
(201,101,50,'2024-02-28'),
(202,101,30,'2024-02-28'),
(203,102,60,'2024-02-28'),
(204,103,100,'2024-03-01'),
(205,104,40,'2024-03-01'),
(206,105,70,'2024-03-02'),
(207,106,80,'2024-03-02'),
(208,107,20,'2024-03-03'),
(209,108,120,'2024-03-03'),
(210,109,90,'2024-03-04');

-- Indexes

CREATE INDEX idx_movie_genre ON Movies(Genre);
CREATE INDEX idx_show_date ON Shows(ShowDate);
CREATE INDEX idx_booking_show ON Bookings(ShowID);

-- View: Seat Availability Logic

CREATE VIEW Seat_Availability_View AS
SELECT 
    s.ShowID,
    m.MovieName,
    t.TheaterName,
    t.TotalSeats,
    IFNULL(SUM(b.SeatsBooked),0) AS SeatsBooked,
    (t.TotalSeats - IFNULL(SUM(b.SeatsBooked),0)) AS SeatsAvailable
FROM Shows s
JOIN Movies m ON s.MovieID = m.MovieID
JOIN Theaters t ON s.TheaterID = t.TheaterID
LEFT JOIN Bookings b ON s.ShowID = b.ShowID
GROUP BY s.ShowID, m.MovieName, t.TheaterName, t.TotalSeats;

-- View: Revenue Per Show

CREATE VIEW Revenue_Per_Show_View AS
SELECT 
    s.ShowID,
    m.MovieName,
    SUM(b.SeatsBooked * s.TicketPrice) AS TotalRevenue
FROM Shows s
JOIN Movies m ON s.MovieID = m.MovieID
LEFT JOIN Bookings b ON s.ShowID = b.ShowID
GROUP BY s.ShowID, m.MovieName;

-- Ranking Shows by Revenue (Window Function)

CREATE VIEW Show_Revenue_Ranking AS
SELECT 
    ShowID,
    MovieName,
    TotalRevenue,
    RANK() OVER (ORDER BY TotalRevenue DESC) AS RevenueRank
FROM Revenue_Per_Show_View;

-- Stored Procedure: Add Booking

DELIMITER //

CREATE PROCEDURE AddBooking(
    IN p_BookingID INT,
    IN p_ShowID INT,
    IN p_Seats INT,
    IN p_Date DATE
)
BEGIN
    INSERT INTO Bookings
    VALUES(p_BookingID, p_ShowID, p_Seats, p_Date);
END //

DELIMITER ;

-- Stored Procedure: Get Show Revenue

DELIMITER //

CREATE PROCEDURE GetShowRevenue(IN p_ShowID INT)
BEGIN
    SELECT 
        s.ShowID,
        m.MovieName,
        SUM(b.SeatsBooked * s.TicketPrice) AS TotalRevenue
    FROM Shows s
    JOIN Movies m ON s.MovieID = m.MovieID
    LEFT JOIN Bookings b ON s.ShowID = b.ShowID
    WHERE s.ShowID = p_ShowID
    GROUP BY s.ShowID, m.MovieName;
END //

DELIMITER ;

-- Sample Execution

-- SELECT * FROM Seat_Availability_View;
-- SELECT * FROM Revenue_Per_Show_View;
-- SELECT * FROM Show_Revenue_Ranking;
-- CALL GetShowRevenue(101);