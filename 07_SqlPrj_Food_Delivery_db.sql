
 -- 7. Food Delivery App Database

-- Create Database
CREATE DATABASE IF NOT EXISTS 7_SqlPrj_food_delivery_db;
USE 7_SqlPrj_food_delivery_db;

-- Create Tables

CREATE TABLE Restaurants (
    restaurant_id INT PRIMARY KEY AUTO_INCREMENT,
    restaurant_name VARCHAR(100) NOT NULL,
    city VARCHAR(50),
    rating DECIMAL(2,1) CHECK (rating BETWEEN 0 AND 5),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Menu (
    menu_id INT PRIMARY KEY AUTO_INCREMENT,
    restaurant_id INT,
    item_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2) CHECK (price > 0),
    availability ENUM('Available','Out of Stock') DEFAULT 'Available',
    FOREIGN KEY (restaurant_id) REFERENCES Restaurants(restaurant_id)
        ON DELETE CASCADE
);

CREATE TABLE Delivery_Partners (
    partner_id INT PRIMARY KEY AUTO_INCREMENT,
    partner_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) UNIQUE,
    vehicle_type VARCHAR(50),
    status ENUM('Available','Busy','Offline') DEFAULT 'Available'
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    restaurant_id INT,
    partner_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2),
    order_status ENUM('Placed','Preparing','Out for Delivery','Delivered','Cancelled') DEFAULT 'Placed',
    FOREIGN KEY (restaurant_id) REFERENCES Restaurants(restaurant_id),
    FOREIGN KEY (partner_id) REFERENCES Delivery_Partners(partner_id)
);

-- Many-to-Many: Order Items Table
CREATE TABLE Order_Items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    menu_id INT,
    quantity INT CHECK (quantity > 0),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
        ON DELETE CASCADE,
    FOREIGN KEY (menu_id) REFERENCES Menu(menu_id)
        ON DELETE CASCADE
);

-- Insert Records To Each Tables

-- Restaurants
INSERT INTO Restaurants (restaurant_name,city,rating) VALUES
('Spice Hub','Bangalore',4.5),
('Food Palace','Delhi',4.2),
('Tasty Bites','Mumbai',4.0),
('Urban Kitchen','Hyderabad',4.3),
('Curry House','Chennai',4.1),
('Pizza World','Pune',4.6),
('Burger Point','Ahmedabad',4.0),
('BBQ Nation','Jaipur',4.7),
('South Delight','Kochi',4.4),
('North Feast','Kolkata',4.2);

-- Menu
INSERT INTO Menu (restaurant_id,item_name,category,price) VALUES
(1,'Paneer Biryani','Main Course',250),
(2,'Butter Chicken','Main Course',300),
(3,'Veg Pizza','Fast Food',200),
(4,'Masala Dosa','Breakfast',120),
(5,'Chicken Curry','Main Course',280),
(6,'Margherita Pizza','Fast Food',220),
(7,'Veg Burger','Fast Food',150),
(8,'Grilled Chicken','Main Course',350),
(9,'Idli Sambar','Breakfast',80),
(10,'Chole Bhature','Main Course',180);

-- Delivery Partners
INSERT INTO Delivery_Partners (partner_name,phone,vehicle_type) VALUES
('Ravi','9400000001','Bike'),
('Amit','9400000002','Scooter'),
('Kiran','9400000003','Bike'),
('Rahul','9400000004','Bike'),
('Vikram','9400000005','Scooter'),
('Arjun','9400000006','Bike'),
('Suresh','9400000007','Scooter'),
('Manoj','9400000008','Bike'),
('Deepak','9400000009','Bike'),
('Karthik','9400000010','Scooter');

-- Orders
INSERT INTO Orders (restaurant_id,partner_id,total_amount,order_status) VALUES
(1,1,500,'Delivered'),
(2,2,300,'Out for Delivery'),
(3,3,200,'Preparing'),
(4,4,120,'Delivered'),
(5,5,280,'Cancelled'),
(6,6,220,'Placed'),
(7,7,150,'Delivered'),
(8,8,350,'Out for Delivery'),
(9,9,80,'Preparing'),
(10,10,180,'Placed');

-- Order_Items (Many-to-Many)
INSERT INTO Order_Items (order_id,menu_id,quantity) VALUES
(1,1,2),
(2,2,1),
(3,3,1),
(4,4,1),
(5,5,1),
(6,6,1),
(7,7,1),
(8,8,1),
(9,9,1),
(10,10,1);

-- Indexes
CREATE INDEX idx_restaurant_city ON Restaurants(city);
CREATE INDEX idx_menu_restaurant ON Menu(restaurant_id);
CREATE INDEX idx_order_status ON Orders(order_status);
CREATE INDEX idx_partner_status ON Delivery_Partners(status);

-- View (Order Summary View)

CREATE VIEW Order_Summary AS
SELECT 
    o.order_id,
    r.restaurant_name,
    d.partner_name,
    o.total_amount,
    o.order_status,
    o.order_date
FROM Orders o
JOIN Restaurants r ON o.restaurant_id = r.restaurant_id
LEFT JOIN Delivery_Partners d ON o.partner_id = d.partner_id;

-- View (Restaurant Revenue)

CREATE VIEW Restaurant_Revenue AS
SELECT 
    r.restaurant_name,
    SUM(o.total_amount) AS total_revenue
FROM Restaurants r
LEFT JOIN Orders o ON r.restaurant_id = o.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY r.restaurant_id;

-- Stored Procedure (Place Order)

DELIMITER //

CREATE PROCEDURE PlaceOrder(
    IN restId INT,
    IN partnerId INT,
    IN amount DECIMAL(10,2)
)
BEGIN
    INSERT INTO Orders (restaurant_id,partner_id,total_amount,order_status)
    VALUES(restId,partnerId,amount,'Placed');

    UPDATE Delivery_Partners
    SET status = 'Busy'
    WHERE partner_id = partnerId;
END;
//

DELIMITER ;

-- Trigger (Update Delivery Partner Status After Delivery)

DELIMITER //

CREATE TRIGGER trg_update_partner_status
AFTER UPDATE ON Orders
FOR EACH ROW
BEGIN
    IF NEW.order_status = 'Delivered' THEN
        UPDATE Delivery_Partners
        SET status = 'Available'
        WHERE partner_id = NEW.partner_id;
    END IF;
END;
//

DELIMITER ;

-- Status Tracking Query
SELECT 
    order_id,
    order_status,
    CASE
        WHEN order_status = 'Placed' THEN 'Waiting for Restaurant'
        WHEN order_status = 'Preparing' THEN 'Food is being prepared'
        WHEN order_status = 'Out for Delivery' THEN 'On the way'
        WHEN order_status = 'Delivered' THEN 'Completed'
        WHEN order_status = 'Cancelled' THEN 'Order Cancelled'
    END AS status_description
FROM Orders;

-- Top 3 Restaurants by Revenue
SELECT 
    r.restaurant_name,
    SUM(o.total_amount) AS revenue
FROM Orders o
JOIN Restaurants r ON o.restaurant_id = r.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY r.restaurant_name
ORDER BY revenue DESC
LIMIT 3;