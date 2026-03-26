
-- 1. E-Commerce Order Management System

-- Create Database 1_SqlPrj_ecommerce_db;

CREATE DATABASE IF NOT EXISTS 1_SqlPrj_ecommerce_db;
Use 1_SqlPrj_ecommerce_db;

-- Create Tables
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    city VARCHAR(50)
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    stock INT
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(30),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE Order_Items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT,
    price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

CREATE TABLE Payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10,2),
    payment_method VARCHAR(30),
    payment_status VARCHAR(30),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

-- Inserting Records to each table

-- Customers
INSERT INTO Customers (first_name, last_name, email, phone, city) VALUES
('Naveen','Kumar','naveen1@gmail.com','9000000001','Bangalore'),
('Amit','Sharma','amit@gmail.com','9000000002','Delhi'),
('Priya','Rao','priya@gmail.com','9000000003','Hyderabad'),
('Rahul','Verma','rahul@gmail.com','9000000004','Mumbai'),
('Sneha','Reddy','sneha@gmail.com','9000000005','Chennai'),
('Arjun','Mehta','arjun@gmail.com','9000000006','Pune'),
('Kiran','Patel','kiran@gmail.com','9000000007','Ahmedabad'),
('Divya','Singh','divya@gmail.com','9000000008','Jaipur'),
('Vikram','Das','vikram@gmail.com','9000000009','Kolkata'),
('Anjali','Nair','anjali@gmail.com','9000000010','Kochi');

SELECT  * FROM Customers;
-- Products
INSERT INTO Products (product_name, category, price, stock) VALUES
('Laptop','Electronics',60000,50),
('Mobile','Electronics',20000,100),
('Headphones','Electronics',2000,200),
('Keyboard','Electronics',1500,150),
('Mouse','Electronics',800,180),
('Chair','Furniture',5000,40),
('Table','Furniture',7000,30),
('Shoes','Fashion',3000,120),
('Watch','Fashion',4000,90),
('Backpack','Fashion',2500,110);

SELECT * FROM Products;

-- Orders
INSERT INTO Orders (customer_id, status) VALUES
(1,'Delivered'),(2,'Shipped'),(3,'Pending'),
(4,'Delivered'),(5,'Cancelled'),
(6,'Shipped'),(7,'Delivered'),
(8,'Pending'),(9,'Delivered'),(10,'Shipped');

SELECT * FROM Orders;

-- Order_Items
INSERT INTO Order_Items (order_id, product_id, quantity, price) VALUES
(1,1,1,60000),
(2,2,2,20000),
(3,3,1,2000),
(4,4,1,1500),
(5,5,3,800),
(6,6,1,5000),
(7,7,1,7000),
(8,8,2,3000),
(9,9,1,4000),
(10,10,2,2500);

SELECT * FROM Order_Items;
-- Payments
INSERT INTO Payments (order_id, amount, payment_method, payment_status) VALUES
(1,60000,'UPI','Completed'),
(2,40000,'Card','Completed'),
(3,2000,'Cash','Pending'),
(4,1500,'Card','Completed'),
(5,2400,'UPI','Refunded'),
(6,5000,'NetBanking','Completed'),
(7,7000,'Card','Completed'),
(8,6000,'UPI','Pending'),
(9,4000,'Cash','Completed'),
(10,5000,'Card','Completed');
SELECT * FROM Payments;

-- Indexes
CREATE INDEX idx_customer_email ON Customers(email);
CREATE INDEX idx_product_category ON Products(category);
CREATE INDEX idx_order_customer ON Orders(customer_id);
CREATE INDEX idx_payment_status ON Payments(payment_status);

-- Trigger (Reduce Stock After Order Item Insert)

DELIMITER //

CREATE TRIGGER trg_update_stock
AFTER INSERT ON Order_Items
FOR EACH ROW
BEGIN
   UPDATE Products
   SET stock = stock - NEW.quantity
   WHERE product_id = NEW.product_id;
END;
//

DELIMITER ;

-- View (Order Summary View)

CREATE VIEW Order_Summary AS
SELECT 
    o.order_id,
    c.first_name,
    c.city,
    SUM(oi.quantity * oi.price) AS total_amount,
    o.status
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Order_Items oi ON o.order_id = oi.order_id
GROUP BY o.order_id;

-- Stored Procedure (Customer Total Spending)

DELIMITER //

CREATE PROCEDURE GetCustomerSpending(IN cust_id INT)
BEGIN
    SELECT 
        c.customer_id,
        c.first_name,
        SUM(p.amount) AS total_spent
    FROM Customers c
    JOIN Orders o ON c.customer_id = o.customer_id
    JOIN Payments p ON o.order_id = p.order_id
    WHERE c.customer_id = cust_id
    GROUP BY c.customer_id;
END;
//

DELIMITER ;


-- Queries

-- 1. Top 3 Highest Revenue Orders
SELECT order_id, SUM(quantity*price) AS total
FROM Order_Items
GROUP BY order_id
ORDER BY total DESC
LIMIT 3;

-- 2. Customers Who Spent More Than Average
SELECT o.customer_id
FROM Payments p
JOIN Orders o ON p.order_id = o.order_id
GROUP BY o.customer_id
HAVING SUM(p.amount) > (
    SELECT AVG(amount) FROM Payments
);
-- 3. Category Wise Revenue
SELECT p.category, SUM(oi.quantity * oi.price) AS revenue
FROM Order_Items oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY p.category;