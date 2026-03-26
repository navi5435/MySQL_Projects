
-- 13. Social Media Database


-- Create Database
CREATE DATABASE 13_SqlPrj_social_media_db;
USE 13_SqlPrj_social_media_db;

-- Create Tables

CREATE TABLE Users (
    UserID INT PRIMARY KEY,
    UserName VARCHAR(100),
    Email VARCHAR(100),
    JoinDate DATE
);

-- Followers table (Self Join Concept)
CREATE TABLE Followers (
    FollowerID INT,
    FollowingID INT,
    FollowDate DATE,
    PRIMARY KEY (FollowerID, FollowingID),
    FOREIGN KEY (FollowerID) REFERENCES Users(UserID),
    FOREIGN KEY (FollowingID) REFERENCES Users(UserID)
);

CREATE TABLE Posts (
    PostID INT PRIMARY KEY,
    UserID INT,
    Content VARCHAR(255),
    PostDate DATE,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

CREATE TABLE Comments (
    CommentID INT PRIMARY KEY,
    PostID INT,
    UserID INT,
    CommentText VARCHAR(255),
    CommentDate DATE,
    FOREIGN KEY (PostID) REFERENCES Posts(PostID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

CREATE TABLE Likes (
    LikeID INT PRIMARY KEY,
    PostID INT,
    UserID INT,
    LikeDate DATE,
    FOREIGN KEY (PostID) REFERENCES Posts(PostID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- Inserting Records To Each Tables

-- Users
INSERT INTO Users VALUES
(1,'Amit','amit@gmail.com','2024-01-01'),
(2,'Priya','priya@gmail.com','2024-01-02'),
(3,'Rahul','rahul@gmail.com','2024-01-03'),
(4,'Sneha','sneha@gmail.com','2024-01-04'),
(5,'Karan','karan@gmail.com','2024-01-05'),
(6,'Anita','anita@gmail.com','2024-01-06'),
(7,'Rohit','rohit@gmail.com','2024-01-07'),
(8,'Meera','meera@gmail.com','2024-01-08'),
(9,'Neha','neha@gmail.com','2024-01-09'),
(10,'Varun','varun@gmail.com','2024-01-10');

-- Followers (Self Join)
INSERT INTO Followers VALUES
(1,2,'2024-02-01'),
(2,3,'2024-02-02'),
(3,4,'2024-02-03'),
(4,5,'2024-02-04'),
(5,6,'2024-02-05'),
(6,7,'2024-02-06'),
(7,8,'2024-02-07'),
(8,9,'2024-02-08'),
(9,10,'2024-02-09'),
(10,1,'2024-02-10');

-- Posts
INSERT INTO Posts VALUES
(101,1,'Hello World!','2024-03-01'),
(102,2,'Learning SQL','2024-03-02'),
(103,3,'Window Functions are powerful','2024-03-03'),
(104,4,'Database Design Tips','2024-03-04'),
(105,5,'AI is the future','2024-03-05'),
(106,6,'Cloud Computing','2024-03-06'),
(107,7,'Data Analytics','2024-03-07'),
(108,8,'Machine Learning','2024-03-08'),
(109,9,'Cyber Security','2024-03-09'),
(110,10,'Full Stack Dev','2024-03-10');

-- Comments
INSERT INTO Comments VALUES
(1001,101,2,'Nice Post!','2024-03-11'),
(1002,102,3,'Very Informative','2024-03-12'),
(1003,103,4,'Great Explanation','2024-03-13'),
(1004,104,5,'Helpful','2024-03-14'),
(1005,105,6,'Awesome','2024-03-15'),
(1006,106,7,'Thanks for sharing','2024-03-16'),
(1007,107,8,'Good Read','2024-03-17'),
(1008,108,9,'Interesting','2024-03-18'),
(1009,109,10,'Well Written','2024-03-19'),
(1010,110,1,'Superb','2024-03-20');

-- Likes
INSERT INTO Likes VALUES
(2001,101,3,'2024-03-21'),
(2002,101,4,'2024-03-21'),
(2003,102,5,'2024-03-22'),
(2004,103,6,'2024-03-23'),
(2005,103,7,'2024-03-23'),
(2006,104,8,'2024-03-24'),
(2007,105,9,'2024-03-25'),
(2008,106,10,'2024-03-26'),
(2009,107,1,'2024-03-27'),
(2010,108,2,'2024-03-28');

-- Indexes

CREATE INDEX idx_username ON Users(UserName);
CREATE INDEX idx_post_date ON Posts(PostDate);
CREATE INDEX idx_like_post ON Likes(PostID);

-- View: Followers Self Join

CREATE VIEW User_Followers_View AS
SELECT 
    u1.UserName AS Follower,
    u2.UserName AS Following,
    f.FollowDate
FROM Followers f
JOIN Users u1 ON f.FollowerID = u1.UserID
JOIN Users u2 ON f.FollowingID = u2.UserID;

-- View: Trending Posts (Based on Like Count)

CREATE VIEW Trending_Posts AS
SELECT 
    p.PostID,
    u.UserName,
    p.Content,
    COUNT(l.LikeID) AS TotalLikes
FROM Posts p
LEFT JOIN Likes l ON p.PostID = l.PostID
JOIN Users u ON p.UserID = u.UserID
GROUP BY p.PostID, u.UserName, p.Content
HAVING COUNT(l.LikeID) >= 2;

-- Ranking Query View (Window Function)

CREATE VIEW Post_Ranking AS
SELECT 
    p.PostID,
    u.UserName,
    COUNT(l.LikeID) AS TotalLikes,
    RANK() OVER (ORDER BY COUNT(l.LikeID) DESC) AS RankPosition
FROM Posts p
LEFT JOIN Likes l ON p.PostID = l.PostID
JOIN Users u ON p.UserID = u.UserID
GROUP BY p.PostID, u.UserName;

-- Stored Procedure: Add New Post

DELIMITER //

CREATE PROCEDURE AddPost(
    IN p_PostID INT,
    IN p_UserID INT,
    IN p_Content VARCHAR(255),
    IN p_Date DATE
)
BEGIN
    INSERT INTO Posts VALUES(p_PostID, p_UserID, p_Content, p_Date);
END //

DELIMITER ;

-- Stored Procedure: Get User Followers Count

DELIMITER //

CREATE PROCEDURE GetFollowersCount(IN p_UserID INT)
BEGIN
    SELECT 
        u.UserName,
        COUNT(f.FollowerID) AS TotalFollowers
    FROM Users u
    LEFT JOIN Followers f ON u.UserID = f.FollowingID
    WHERE u.UserID = p_UserID
    GROUP BY u.UserName;
END //

DELIMITER ;

-- Sample Execution

-- SELECT * FROM User_Followers_View;
-- SELECT * FROM Trending_Posts;
-- SELECT * FROM Post_Ranking;
-- CALL GetFollowersCount(1);
