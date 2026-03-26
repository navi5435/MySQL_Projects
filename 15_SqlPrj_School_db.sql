
-- 15. School Management System


-- Create Database
CREATE DATABASE 15_SqlPrj_school_db;
USE 15_SqlPrj_school_db;

-- Create Tables

CREATE TABLE Teachers (
    TeacherID INT PRIMARY KEY,
    TeacherName VARCHAR(100),
    Subject VARCHAR(50)
);

CREATE TABLE Students (
    StudentID INT PRIMARY KEY,
    StudentName VARCHAR(100),
    Class VARCHAR(20),
    Section VARCHAR(10),
    TeacherID INT,
    FOREIGN KEY (TeacherID) REFERENCES Teachers(TeacherID)
);

CREATE TABLE Exams (
    ExamID INT PRIMARY KEY,
    Subject VARCHAR(50),
    ExamDate DATE
);

CREATE TABLE Marks (
    MarkID INT PRIMARY KEY,
    StudentID INT,
    ExamID INT,
    MarksObtained INT,
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (ExamID) REFERENCES Exams(ExamID)
);

-- Inserting Records To Each Tables

-- Teachers
INSERT INTO Teachers VALUES
(1,'Mr. Sharma','Math'),
(2,'Ms. Priya','Science'),
(3,'Mr. Rahul','English'),
(4,'Ms. Sneha','Social'),
(5,'Mr. Karan','Physics'),
(6,'Ms. Anita','Chemistry'),
(7,'Mr. Rohit','Biology'),
(8,'Ms. Meera','History'),
(9,'Mr. Neha','Geography'),
(10,'Mr. Varun','Computer');

-- Students
INSERT INTO Students VALUES
(101,'Amit','10','A',1),
(102,'Priya','10','A',1),
(103,'Rahul','10','B',2),
(104,'Sneha','10','B',2),
(105,'Karan','9','A',3),
(106,'Anita','9','A',3),
(107,'Rohit','9','B',4),
(108,'Meera','9','B',4),
(109,'Neha','8','A',5),
(110,'Varun','8','B',6);

-- Exams
INSERT INTO Exams VALUES
(201,'Math','2024-03-01'),
(202,'Science','2024-03-02'),
(203,'English','2024-03-03'),
(204,'Social','2024-03-04'),
(205,'Physics','2024-03-05'),
(206,'Chemistry','2024-03-06'),
(207,'Biology','2024-03-07'),
(208,'History','2024-03-08'),
(209,'Geography','2024-03-09'),
(210,'Computer','2024-03-10');

-- Marks
INSERT INTO Marks VALUES
(1,101,201,85),
(2,102,201,92),
(3,103,202,78),
(4,104,202,88),
(5,105,203,60),
(6,106,203,45),
(7,107,204,73),
(8,108,204,95),
(9,109,205,55),
(10,110,206,40);

-- Indexes

CREATE INDEX idx_student_class ON Students(Class);
CREATE INDEX idx_marks_student ON Marks(StudentID);
CREATE INDEX idx_exam_subject ON Exams(Subject);

-- View: Pass / Fail Logic

-- Pass if Marks >= 50

CREATE VIEW Student_Result_View AS
SELECT 
    s.StudentID,
    s.StudentName,
    s.Class,
    e.Subject,
    m.MarksObtained,
    CASE 
        WHEN m.MarksObtained >= 50 THEN 'Pass'
        ELSE 'Fail'
    END AS ResultStatus
FROM Marks m
JOIN Students s ON m.StudentID = s.StudentID
JOIN Exams e ON m.ExamID = e.ExamID;

-- View: Rank Students (Window Function)

CREATE VIEW Student_Rank_View AS
SELECT 
    s.StudentID,
    s.StudentName,
    s.Class,
    m.MarksObtained,
    RANK() OVER (PARTITION BY s.Class ORDER BY m.MarksObtained DESC) AS ClassRank
FROM Marks m
JOIN Students s ON m.StudentID = s.StudentID;

-- View: Top Scorer Per Class

CREATE VIEW Top_Scorer_Per_Class AS
SELECT *
FROM (
    SELECT 
        s.Class,
        s.StudentName,
        m.MarksObtained,
        RANK() OVER (PARTITION BY s.Class ORDER BY m.MarksObtained DESC) AS RankPosition
    FROM Marks m
    JOIN Students s ON m.StudentID = s.StudentID
) ranked
WHERE RankPosition = 1;

-- Stored Procedure: Add Marks

DELIMITER //

CREATE PROCEDURE AddMarks(
    IN p_MarkID INT,
    IN p_StudentID INT,
    IN p_ExamID INT,
    IN p_Marks INT
)
BEGIN
    INSERT INTO Marks VALUES(p_MarkID, p_StudentID, p_ExamID, p_Marks);
END //

DELIMITER ;

-- Stored Procedure: Get Student Performance

DELIMITER //

CREATE PROCEDURE GetStudentPerformance(IN p_StudentID INT)
BEGIN
    SELECT 
        s.StudentName,
        s.Class,
        AVG(m.MarksObtained) AS AverageMarks,
        CASE 
            WHEN AVG(m.MarksObtained) >= 50 THEN 'Overall Pass'
            ELSE 'Overall Fail'
        END AS FinalResult
    FROM Students s
    JOIN Marks m ON s.StudentID = m.StudentID
    WHERE s.StudentID = p_StudentID
    GROUP BY s.StudentName, s.Class;
END //

DELIMITER ;

-- Sample Execution

-- SELECT * FROM Student_Result_View;
-- SELECT * FROM Student_Rank_View;
-- SELECT * FROM Top_Scorer_Per_Class;
-- CALL GetStudentPerformance(101);