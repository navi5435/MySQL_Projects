
-- 8. Online Course Management System

DROP DATABASE IF EXISTS 8_SqlPrj_course_db;
CREATE DATABASE 8_SqlPrj_course_db;
USE 8_SqlPrj_course_db;

-- TABLE CREATION

CREATE TABLE Students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    student_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    join_date DATE NOT NULL
);

CREATE TABLE Courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(100) NOT NULL,
    instructor_name VARCHAR(100) NOT NULL,
    total_modules INT NOT NULL CHECK (total_modules > 0)
);

CREATE TABLE Enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    course_id INT,
    enrollment_date DATE,
    progress_percent DECIMAL(5,2) DEFAULT 0 CHECK (progress_percent BETWEEN 0 AND 100),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
        ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
        ON DELETE CASCADE
);

CREATE TABLE Certificates (
    certificate_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    course_id INT,
    issue_date DATE,
    grade VARCHAR(10),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

-- INDEXES

CREATE INDEX idx_student_name ON Students(student_name);
CREATE INDEX idx_course_name ON Courses(course_name);
CREATE INDEX idx_enrollment_student ON Enrollments(student_id);
CREATE INDEX idx_enrollment_course ON Enrollments(course_id);

-- INSERT RECORDS TO EACH TABLES

-- Students (10)
INSERT INTO Students (student_name, email, join_date) VALUES
('Rahul Sharma', 'rahul@gmail.com', '2025-01-10'),
('Priya Verma', 'priya@gmail.com', '2025-01-12'),
('Arjun Kumar', 'arjun@gmail.com', '2025-01-15'),
('Sneha Reddy', 'sneha@gmail.com', '2025-01-18'),
('Vikram Singh', 'vikram@gmail.com', '2025-01-20'),
('Anjali Mehta', 'anjali@gmail.com', '2025-01-25'),
('Rohit Das', 'rohit@gmail.com', '2025-01-28'),
('Kavya Nair', 'kavya@gmail.com', '2025-02-01'),
('Manoj Patel', 'manoj@gmail.com', '2025-02-05'),
('Divya Iyer', 'divya@gmail.com', '2025-02-10');

-- Courses (10)
INSERT INTO Courses (course_name, instructor_name, total_modules) VALUES
('MySQL Mastery', 'Vasanth', 12),
('Python Programming', 'Arun', 15),
('Data Analytics', 'Meena', 10),
('Web Development', 'Kiran', 20),
('Machine Learning', 'Sathish', 18),
('Power BI', 'Lakshmi', 8),
('Excel Advanced', 'Ravi', 6),
('Java Programming', 'Naveen', 14),
('Cloud Computing', 'Anand', 16),
('Cyber Security', 'Deepak', 11);

-- Enrollments (10)
INSERT INTO Enrollments (student_id, course_id, enrollment_date, progress_percent) VALUES
(1,1,'2025-02-01',80),
(2,1,'2025-02-01',95),
(3,2,'2025-02-02',60),
(4,3,'2025-02-03',75),
(5,4,'2025-02-05',40),
(6,5,'2025-02-06',90),
(7,6,'2025-02-08',55),
(8,7,'2025-02-09',100),
(9,8,'2025-02-10',30),
(10,9,'2025-02-12',85);

-- Certificates (10)
INSERT INTO Certificates (student_id, course_id, issue_date, grade) VALUES
(1,1,'2025-03-01','A'),
(2,1,'2025-03-01','A+'),
(3,2,'2025-03-02','B'),
(4,3,'2025-03-03','A'),
(5,4,'2025-03-04','C'),
(6,5,'2025-03-05','A'),
(7,6,'2025-03-06','B+'),
(8,7,'2025-03-07','A+'),
(9,8,'2025-03-08','B'),
(10,9,'2025-03-09','A');

-- STORED PROCEDURE

DELIMITER //

CREATE PROCEDURE UpdateProgress(
    IN p_student INT,
    IN p_course INT,
    IN p_progress DECIMAL(5,2)
)
BEGIN
    UPDATE Enrollments
    SET progress_percent = p_progress
    WHERE student_id = p_student
    AND course_id = p_course;
END //

DELIMITER ;

-- Example Call
-- CALL UpdateProgress(1,1,100);

-- =====================================================
-- 5️⃣ STORED FUNCTION (Progress Status)
-- =====================================================

DELIMITER //

CREATE FUNCTION GetProgressStatus(p_progress DECIMAL(5,2))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE status VARCHAR(20);
    IF p_progress = 100 THEN
        SET status = 'Completed';
    ELSEIF p_progress >= 70 THEN
        SET status = 'Almost Complete';
    ELSE
        SET status = 'In Progress';
    END IF;
    RETURN status;
END //

DELIMITER ;

-- VIEW CREATION

CREATE VIEW StudentCourseProgress AS
SELECT 
    s.student_name,
    c.course_name,
    e.progress_percent,
    GetProgressStatus(e.progress_percent) AS progress_status
FROM Enrollments e
JOIN Students s ON e.student_id = s.student_id
JOIN Courses c ON e.course_id = c.course_id;


-- RANKING STUDENTS (Window Function)

CREATE VIEW CourseRanking AS
SELECT 
    c.course_name,
    s.student_name,
    e.progress_percent,
    RANK() OVER (PARTITION BY c.course_id 
                 ORDER BY e.progress_percent DESC) AS course_rank
FROM Enrollments e
JOIN Students s ON e.student_id = s.student_id
JOIN Courses c ON e.course_id = c.course_id;


-- PROGRESS TRACKING QUERY
SELECT 
    s.student_name,
    c.course_name,
    e.progress_percent,
    GetProgressStatus(e.progress_percent) AS status
FROM Enrollments e
JOIN Students s ON s.student_id = e.student_id
JOIN Courses c ON c.course_id = e.course_id;
