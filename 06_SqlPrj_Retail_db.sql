
-- 6. Retail Sales Analysis

-- Create Database
CREATE DATABASE IF NOT EXISTS 6_SqlPrj_retail_db;
USE 6_SqlPrj_retail_db;

-- Create Tables

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50),
    gender ENUM('Male','Female','Other'),
    city VARCHAR(50),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Sales (
    sale_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    category_id INT,
    sale_date DATE NOT NULL,
    quantity INT CHECK (quantity > 0),
    unit_price DECIMAL(10,2) CHECK (unit_price > 0),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
        ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
        ON DELETE CASCADE
);

-- Insert 10 Records To Each Tables

-- Customers
INSERT INTO Customers (first_name,last_name,gender,city) VALUES
('Naveen','Kumar','Male','Bangalore'),
('Amit','Sharma','Male','Delhi'),
('Priya','Rao','Female','Hyderabad'),
('Rahul','Verma','Male','Mumbai'),
('Sneha','Reddy','Female','Chennai'),
('Arjun','Mehta','Male','Pune'),
('Kiran','Patel','Male','Ahmedabad'),
('Divya','Singh','Female','Jaipur'),
('Vikram','Das','Male','Kolkata'),
('Anjali','Nair','Female','Kochi');

-- Categories
INSERT INTO Categories (category_name) VALUES
('Electronics'),
('Clothing'),
('Furniture'),
('Groceries'),
('Toys'),
('Beauty'),
('Sports'),
('Books'),
('Footwear'),
('Accessories');

-- Sales (spread across months)
INSERT INTO Sales (customer_id,category_id,sale_date,quantity,unit_price) VALUES
(1,1,'2026-01-10',2,20000),
(2,2,'2026-01-15',3,1500),
(3,3,'2026-02-05',1,10000),
(4,4,'2026-02-18',5,500),
(5,5,'2026-03-02',2,800),
(6,6,'2026-03-10',4,700),
(7,7,'2026-04-05',1,3000),
(8,8,'2026-04-12',6,600),
(9,9,'2026-05-01',2,2500),
(10,10,'2026-05-15',3,1200);

-- Indexes
CREATE INDEX idx_sales_customer ON Sales(customer_id);
CREATE INDEX idx_sales_category ON Sales(category_id);
CREATE INDEX idx_sales_date ON Sales(sale_date);
CREATE INDEX idx_category_name ON Categories(category_name);

-- View (Detailed Sales Report)

CREATE VIEW Sales_Report AS
SELECT 
    s.sale_id,
    c.first_name,
    cat.category_name,
    s.sale_date,
    s.quantity,
    s.unit_price,
    (s.quantity * s.unit_price) AS total_amount
FROM Sales s
JOIN Customers c ON s.customer_id = c.customer_id
JOIN Categories cat ON s.category_id = cat.category_id;

-- View (Monthly Revenue Trend)

CREATE VIEW Monthly_Sales_Trend AS
SELECT 
    DATE_FORMAT(sale_date,'%Y-%m') AS month,
    SUM(quantity * unit_price) AS total_revenue
FROM Sales
GROUP BY DATE_FORMAT(sale_date,'%Y-%m');

-- Stored Procedure (Category Wise Revenue)

DELIMITER //

CREATE PROCEDURE GetCategoryRevenue(IN catId INT)
BEGIN
    SELECT 
        cat.category_name,
        SUM(s.quantity * s.unit_price) AS total_revenue
    FROM Sales s
    JOIN Categories cat ON s.category_id = cat.category_id
    WHERE s.category_id = catId
    GROUP BY cat.category_name;
END;
//

DELIMITER ;

-- GROUP BY & HAVING Example
-- Categories generating revenue more than 5000

SELECT 
    cat.category_name,
    SUM(s.quantity * s.unit_price) AS revenue
FROM Sales s
JOIN Categories cat ON s.category_id = cat.category_id
GROUP BY cat.category_name
HAVING SUM(s.quantity * s.unit_price) > 5000;

-- Window Functions

-- 1. Rank Categories by Revenue
SELECT 
    cat.category_name,
    SUM(s.quantity * s.unit_price) AS revenue,
    RANK() OVER (ORDER BY SUM(s.quantity * s.unit_price) DESC) AS revenue_rank
FROM Sales s
JOIN Categories cat ON s.category_id = cat.category_id
GROUP BY cat.category_name;

-- 2. Running Monthly Revenue
SELECT 
    DATE_FORMAT(sale_date,'%Y-%m') AS month,
    SUM(quantity * unit_price) AS monthly_revenue,
    SUM(SUM(quantity * unit_price)) OVER (ORDER BY DATE_FORMAT(sale_date,'%Y-%m')) AS running_total
FROM Sales
GROUP BY DATE_FORMAT(sale_date,'%Y-%m');

-- 3. Monthly Trend Analysis Query

SELECT 
    DATE_FORMAT(sale_date,'%M %Y') AS month_name,
    COUNT(sale_id) AS total_sales,
    SUM(quantity * unit_price) AS total_revenue,
    AVG(quantity * unit_price) AS avg_sale_value
FROM Sales
GROUP BY DATE_FORMAT(sale_date,'%Y-%m')
ORDER BY DATE_FORMAT(sale_date,'%Y-%m');