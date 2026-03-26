
-- 4. Library Management System

-- Create Database
CREATE DATABASE IF NOT EXISTS 4_SqlPrj_library_db;
USE 4_SqlPrj_library_db;

-- Create Tables

CREATE TABLE Books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL,
    author VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    total_copies INT CHECK (total_copies >= 0),
    available_copies INT CHECK (available_copies >= 0),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50),
    phone VARCHAR(15) UNIQUE,
    email VARCHAR(100) UNIQUE,
    join_date DATE NOT NULL
);

CREATE TABLE Issue_Return (
    issue_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT,
    member_id INT,
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    status ENUM('Issued','Returned','Overdue') DEFAULT 'Issued',
    FOREIGN KEY (book_id) REFERENCES Books(book_id)
        ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES Members(member_id)
        ON DELETE CASCADE
);

-- Inserting Records To Each Table

-- Books
INSERT INTO Books (title,author,category,total_copies,available_copies) VALUES
('SQL Basics','John Smith','Education',10,7),
('Advanced MySQL','David Lee','Education',8,5),
('Data Structures','Mark Allen','Education',6,4),
('Python Programming','Emily Clark','Programming',12,9),
('Machine Learning','Andrew Ng','AI',5,3),
('Deep Learning','Ian Goodfellow','AI',4,2),
('Business Analytics','James Hall','Business',7,6),
('Finance 101','Robert Brown','Finance',9,8),
('Cloud Computing','Michael Scott','Technology',6,4),
('Cyber Security','Kevin Mitnick','Technology',5,3);

-- Members
INSERT INTO Members (first_name,last_name,phone,email,join_date) VALUES
('Naveen','Kumar','9300000001','naveen@lib.com','2025-01-01'),
('Amit','Sharma','9300000002','amit@lib.com','2025-02-01'),
('Priya','Rao','9300000003','priya@lib.com','2025-03-01'),
('Rahul','Verma','9300000004','rahul@lib.com','2025-04-01'),
('Sneha','Reddy','9300000005','sneha@lib.com','2025-05-01'),
('Arjun','Mehta','9300000006','arjun@lib.com','2025-06-01'),
('Kiran','Patel','9300000007','kiran@lib.com','2025-07-01'),
('Divya','Singh','9300000008','divya@lib.com','2025-08-01'),
('Vikram','Das','9300000009','vikram@lib.com','2025-09-01'),
('Anjali','Nair','9300000010','anjali@lib.com','2025-10-01');

-- Issue_Return (Due date = Issue date + 7 days)
INSERT INTO Issue_Return (book_id,member_id,issue_date,due_date,return_date,status) VALUES
(1,1,'2026-02-01','2026-02-08','2026-02-07','Returned'),
(2,2,'2026-02-05','2026-02-12','2026-02-15','Returned'),
(3,3,'2026-02-10','2026-02-17',NULL,'Overdue'),
(4,4,'2026-02-12','2026-02-19','2026-02-18','Returned'),
(5,5,'2026-02-15','2026-02-22',NULL,'Issued'),
(6,6,'2026-02-18','2026-02-25','2026-02-28','Returned'),
(7,7,'2026-02-20','2026-02-27',NULL,'Overdue'),
(8,8,'2026-02-22','2026-03-01','2026-02-28','Returned'),
(9,9,'2026-02-25','2026-03-04',NULL,'Issued'),
(10,10,'2026-02-27','2026-03-06','2026-03-05','Returned');

-- Indexes
CREATE INDEX idx_book_title ON Books(title);
CREATE INDEX idx_member_email ON Members(email);
CREATE INDEX idx_issue_status ON Issue_Return(status);
CREATE INDEX idx_due_date ON Issue_Return(due_date);

-- 5️⃣ Stored Function (Fine Calculation)
-- Fine = ₹10 per day after due date

DELIMITER //

CREATE FUNCTION CalculateFine(due DATE, returned DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE fine INT;
    IF returned IS NULL THEN
        SET fine = DATEDIFF(CURDATE(), due) * 10;
    ELSE
        SET fine = DATEDIFF(returned, due) * 10;
    END IF;

    IF fine < 0 THEN
        SET fine = 0;
    END IF;

    RETURN fine;
END;
//

DELIMITER ;

-- View (Issue Summary with Fine)

CREATE VIEW Issue_Summary AS
SELECT 
    i.issue_id,
    b.title,
    m.first_name,
    i.issue_date,
    i.due_date,
    i.return_date,
    CalculateFine(i.due_date, i.return_date) AS fine_amount,
    i.status
FROM Issue_Return i
JOIN Books b ON i.book_id = b.book_id
JOIN Members m ON i.member_id = m.member_id;

-- Stored Procedure (Issue Book)

DELIMITER //

CREATE PROCEDURE IssueBook(
    IN b_id INT,
    IN m_id INT
)
BEGIN
    DECLARE copies INT;

    SELECT available_copies INTO copies
    FROM Books
    WHERE book_id = b_id;

    IF copies > 0 THEN
        INSERT INTO Issue_Return(book_id,member_id,issue_date,due_date,status)
        VALUES(b_id,m_id,CURDATE(),DATE_ADD(CURDATE(), INTERVAL 7 DAY),'Issued');

        UPDATE Books
        SET available_copies = available_copies - 1
        WHERE book_id = b_id;
    END IF;
END;
//

DELIMITER ;

-- Stored Procedure (Return Book)

DELIMITER //

CREATE PROCEDURE ReturnBook(
    IN issueId INT
)
BEGIN
    DECLARE b_id INT;

    SELECT book_id INTO b_id
    FROM Issue_Return
    WHERE issue_id = issueId;

    UPDATE Issue_Return
    SET return_date = CURDATE(),
        status = 'Returned'
    WHERE issue_id = issueId;

    UPDATE Books
    SET available_copies = available_copies + 1
    WHERE book_id = b_id;
END;
//

DELIMITER ;

-- Sample Fine Calculation Query
SELECT 
    issue_id,
    CalculateFine(due_date, return_date) AS fine_amount
FROM Issue_Return;

-- Overdue Books Query
SELECT *
FROM Issue_Summary
WHERE fine_amount > 0;