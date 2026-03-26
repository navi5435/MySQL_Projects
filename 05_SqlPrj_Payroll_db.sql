
-- 5. Employee Payroll System

-- Create Database
CREATE DATABASE IF NOT EXISTS 5_SqlPrj_payroll_db;
USE 5_SqlPrj_payroll_db;

-- Create Tables

CREATE TABLE Departments (
    dept_id INT PRIMARY KEY AUTO_INCREMENT,
    dept_name VARCHAR(50) NOT NULL UNIQUE,
    location VARCHAR(50)
);

CREATE TABLE Employees (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50),
    gender ENUM('Male','Female','Other'),
    hire_date DATE NOT NULL,
    dept_id INT,
    basic_salary DECIMAL(10,2) CHECK (basic_salary > 0),
    FOREIGN KEY (dept_id) REFERENCES Departments(dept_id)
        ON DELETE SET NULL
);

CREATE TABLE Attendance (
    attendance_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_id INT,
    attendance_month VARCHAR(20),
    working_days INT CHECK (working_days >= 0),
    present_days INT CHECK (present_days >= 0),
    FOREIGN KEY (emp_id) REFERENCES Employees(emp_id)
        ON DELETE CASCADE
);

CREATE TABLE Salary (
    salary_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_id INT,
    salary_month VARCHAR(20),
    gross_salary DECIMAL(10,2),
    net_salary DECIMAL(10,2),
    generated_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (emp_id) REFERENCES Employees(emp_id)
        ON DELETE CASCADE
);

-- Insert 10 Records Each

-- Departments
INSERT INTO Departments (dept_name,location) VALUES
('HR','Bangalore'),
('IT','Hyderabad'),
('Finance','Mumbai'),
('Marketing','Delhi'),
('Sales','Chennai'),
('Admin','Pune'),
('Operations','Kolkata'),
('Support','Ahmedabad'),
('Logistics','Jaipur'),
('R&D','Kochi');

-- Employees
INSERT INTO Employees (first_name,last_name,gender,hire_date,dept_id,basic_salary) VALUES
('Naveen','Kumar','Male','2022-01-01',1,50000),
('Amit','Sharma','Male','2021-03-10',2,60000),
('Priya','Rao','Female','2020-05-15',3,55000),
('Rahul','Verma','Male','2019-07-20',4,45000),
('Sneha','Reddy','Female','2023-02-18',5,52000),
('Arjun','Mehta','Male','2021-09-25',6,48000),
('Kiran','Patel','Male','2018-11-30',7,70000),
('Divya','Singh','Female','2022-06-05',8,53000),
('Vikram','Das','Male','2020-08-14',9,62000),
('Anjali','Nair','Female','2023-01-22',10,58000);

-- Attendance
INSERT INTO Attendance (emp_id,attendance_month,working_days,present_days) VALUES
(1,'March',26,24),
(2,'March',26,25),
(3,'March',26,23),
(4,'March',26,20),
(5,'March',26,26),
(6,'March',26,22),
(7,'March',26,25),
(8,'March',26,24),
(9,'March',26,26),
(10,'March',26,23);

-- Salary (initial dummy records)
INSERT INTO Salary (emp_id,salary_month,gross_salary,net_salary) VALUES
(1,'March',0,0),
(2,'March',0,0),
(3,'March',0,0),
(4,'March',0,0),
(5,'March',0,0),
(6,'March',0,0),
(7,'March',0,0),
(8,'March',0,0),
(9,'March',0,0),
(10,'March',0,0);

-- Indexes
CREATE INDEX idx_emp_dept ON Employees(dept_id);
CREATE INDEX idx_attendance_emp ON Attendance(emp_id);
CREATE INDEX idx_salary_emp ON Salary(emp_id);
CREATE INDEX idx_dept_name ON Departments(dept_name);

-- View (Employee Salary Summary)

CREATE VIEW Employee_Salary_Summary AS
SELECT 
    e.emp_id,
    e.first_name,
    d.dept_name,
    e.basic_salary,
    a.present_days,
    a.working_days,
    ROUND((e.basic_salary / a.working_days) * a.present_days,2) AS calculated_salary
FROM Employees e
JOIN Departments d ON e.dept_id = d.dept_id
JOIN Attendance a ON e.emp_id = a.emp_id;

-- Stored Procedure (Generate Salary)

DELIMITER //

CREATE PROCEDURE GenerateSalary(
    IN empId INT,
    IN monthName VARCHAR(20)
)
BEGIN
    DECLARE basic DECIMAL(10,2);
    DECLARE working INT;
    DECLARE present INT;
    DECLARE gross DECIMAL(10,2);
    DECLARE net DECIMAL(10,2);

    SELECT e.basic_salary, a.working_days, a.present_days
    INTO basic, working, present
    FROM Employees e
    JOIN Attendance a ON e.emp_id = a.emp_id
    WHERE e.emp_id = empId;

    SET gross = (basic / working) * present;

    -- Deduction 10% if present days < 22
    SET net = CASE
        WHEN present < 22 THEN gross * 0.90
        ELSE gross
    END;

    UPDATE Salary
    SET gross_salary = gross,
        net_salary = net
    WHERE emp_id = empId
      AND salary_month = monthName;
END;
//

DELIMITER ;

-- Trigger (Auto Insert Salary Record After Attendance Insert)

DELIMITER //

CREATE TRIGGER trg_create_salary
AFTER INSERT ON Attendance
FOR EACH ROW
BEGIN
    INSERT INTO Salary(emp_id,salary_month,gross_salary,net_salary)
    VALUES(NEW.emp_id,NEW.attendance_month,0,0);
END;
//

DELIMITER ;

-- Sample CASE Statement Query (Employee Performance Category)

SELECT 
    emp_id,
    present_days,
    CASE
        WHEN present_days >= 25 THEN 'Excellent'
        WHEN present_days >= 22 THEN 'Good'
        ELSE 'Needs Improvement'
    END AS performance_status
FROM Attendance;

-- Department Wise Total Salary

SELECT 
    d.dept_name,
    SUM(s.net_salary) AS total_salary_paid
FROM Salary s
JOIN Employees e ON s.emp_id = e.emp_id
JOIN Departments d ON e.dept_id = d.dept_id
GROUP BY d.dept_name;