
-- 3. Hospital Management System

-- Create Database
CREATE DATABASE IF NOT EXISTS 3_SqlPrj_hospital_db;
USE 3_SqlPrj_hospital_db;

-- Create Tables

CREATE TABLE Patients (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50),
    gender ENUM('Male','Female','Other') NOT NULL,
    date_of_birth DATE NOT NULL,
    phone VARCHAR(15) UNIQUE,
    city VARCHAR(50)
);

CREATE TABLE Doctors (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    specialization VARCHAR(50) NOT NULL,
    phone VARCHAR(15) UNIQUE,
    consultation_fee DECIMAL(10,2) CHECK (consultation_fee > 0)
);

CREATE TABLE Appointments (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT,
    doctor_id INT,
    appointment_date DATETIME NOT NULL,
    status ENUM('Scheduled','Completed','Cancelled') DEFAULT 'Scheduled',
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
        ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
        ON DELETE CASCADE
);

CREATE TABLE Billing (
    bill_id INT PRIMARY KEY AUTO_INCREMENT,
    appointment_id INT,
    bill_date DATE NOT NULL,
    total_amount DECIMAL(10,2) CHECK (total_amount >= 0),
    payment_status ENUM('Paid','Unpaid','Pending') DEFAULT 'Pending',
    FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id)
        ON DELETE CASCADE
);

-- Inserting Records For Each Table

-- Patients
INSERT INTO Patients (first_name,last_name,gender,date_of_birth,phone,city) VALUES
('Naveen','Kumar','Male','1998-05-10','9100000001','Bangalore'),
('Amit','Sharma','Male','1995-02-15','9100000002','Delhi'),
('Priya','Rao','Female','1997-08-20','9100000003','Hyderabad'),
('Rahul','Verma','Male','1994-12-11','9100000004','Mumbai'),
('Sneha','Reddy','Female','1996-03-18','9100000005','Chennai'),
('Arjun','Mehta','Male','1993-06-25','9100000006','Pune'),
('Kiran','Patel','Male','1992-07-30','9100000007','Ahmedabad'),
('Divya','Singh','Female','1999-01-05','9100000008','Jaipur'),
('Vikram','Das','Male','1991-09-14','9100000009','Kolkata'),
('Anjali','Nair','Female','1998-11-22','9100000010','Kochi');

SELECT * FROM Patients;

-- Doctors
INSERT INTO Doctors (first_name,specialization,phone,consultation_fee) VALUES
('Dr. Rao','Cardiology','9200000001',800),
('Dr. Sharma','Orthopedics','9200000002',700),
('Dr. Mehta','Dermatology','9200000003',600),
('Dr. Reddy','Neurology','9200000004',1000),
('Dr. Singh','Pediatrics','9200000005',500),
('Dr. Das','ENT','9200000006',650),
('Dr. Nair','Gynecology','9200000007',750),
('Dr. Patel','General','9200000008',400),
('Dr. Verma','Urology','9200000009',900),
('Dr. Kumar','Oncology','9200000010',1200);

SELECT * FROM Doctors;

-- Appointments
INSERT INTO Appointments (patient_id,doctor_id,appointment_date,status) VALUES
(1,1,'2026-03-01 10:00:00','Completed'),
(2,2,'2026-03-02 11:00:00','Completed'),
(3,3,'2026-03-03 12:00:00','Scheduled'),
(4,4,'2026-03-04 09:00:00','Completed'),
(5,5,'2026-03-05 14:00:00','Cancelled'),
(6,6,'2026-03-06 15:00:00','Completed'),
(7,7,'2026-03-07 16:00:00','Scheduled'),
(8,8,'2026-03-08 10:30:00','Completed'),
(9,9,'2026-03-09 13:00:00','Completed'),
(10,10,'2026-03-10 17:00:00','Scheduled');

SELECT * FROM Appointments;

-- Billing
INSERT INTO Billing (appointment_id,bill_date,total_amount,payment_status) VALUES
(1,'2026-03-01',800,'Paid'),
(2,'2026-03-02',700,'Paid'),
(3,'2026-03-03',600,'Pending'),
(4,'2026-03-04',1000,'Paid'),
(5,'2026-03-05',500,'Unpaid'),
(6,'2026-03-06',650,'Paid'),
(7,'2026-03-07',750,'Pending'),
(8,'2026-03-08',400,'Paid'),
(9,'2026-03-09',900,'Paid'),
(10,'2026-03-10',1200,'Pending');

SELECT * FROM Billing;

-- Indexes
CREATE INDEX idx_patient_phone ON Patients(phone);
CREATE INDEX idx_doctor_specialization ON Doctors(specialization);
CREATE INDEX idx_appointment_date ON Appointments(appointment_date);
CREATE INDEX idx_billing_status ON Billing(payment_status);

-- View (Doctor Appointment Summary)

CREATE VIEW Doctor_Appointment_Summary AS
SELECT 
    d.first_name AS doctor_name,
    d.specialization,
    COUNT(a.appointment_id) AS total_appointments
FROM Doctors d
LEFT JOIN Appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id;

-- View (Monthly Revenue)

CREATE VIEW Monthly_Revenue AS
SELECT 
    DATE_FORMAT(bill_date,'%Y-%m') AS month,
    SUM(total_amount) AS total_revenue
FROM Billing
WHERE payment_status = 'Paid'
GROUP BY DATE_FORMAT(bill_date,'%Y-%m');

-- Stored Procedure (Get Patient Billing History)

DELIMITER //

CREATE PROCEDURE GetPatientBilling(IN p_id INT)
BEGIN
    SELECT 
        p.first_name,
        a.appointment_date,
        b.total_amount,
        b.payment_status
    FROM Patients p
    JOIN Appointments a ON p.patient_id = a.patient_id
    JOIN Billing b ON a.appointment_id = b.appointment_id
    WHERE p.patient_id = p_id;
END;
//

DELIMITER ;

-- Stored Procedure (Count Appointments Between Dates)

DELIMITER //

CREATE PROCEDURE AppointmentCountByDate(
    IN start_date DATE,
    IN end_date DATE
)
BEGIN
    SELECT COUNT(*) AS total_appointments
    FROM Appointments
    WHERE DATE(appointment_date) BETWEEN start_date AND end_date;
END;
//

DELIMITER ;

-- Sample GROUP BY & Date Function Queries

-- Doctor-wise Revenue
SELECT 
    d.first_name,
    SUM(b.total_amount) AS revenue
FROM Doctors d
JOIN Appointments a ON d.doctor_id = a.doctor_id
JOIN Billing b ON a.appointment_id = b.appointment_id
WHERE b.payment_status = 'Paid'
GROUP BY d.doctor_id;

-- Patients older than 25 years
SELECT 
    first_name,
    TIMESTAMPDIFF(YEAR,date_of_birth,CURDATE()) AS age
FROM Patients
HAVING age > 25;

-- Daily Appointment Count
SELECT 
    DATE(appointment_date) AS appointment_day,
    COUNT(*) AS total
FROM Appointments
GROUP BY DATE(appointment_date);