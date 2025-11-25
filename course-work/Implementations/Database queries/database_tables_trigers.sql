  CREATE DATABASE GlovoFoodDeliveryDB;
USE GlovoFoodDeliveryDB;
GO

CREATE TABLE [User] (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    first_name NVARCHAR(50) NOT NULL,
    last_name NVARCHAR(50) NOT NULL,
    email NVARCHAR(100) NOT NULL UNIQUE,
    [password] NVARCHAR(255) NOT NULL,
    phone_num NVARCHAR(13) NOT NULL,
    [address] NVARCHAR(255) NULL
);
CREATE TABLE Restaurant (
    restaurant_id INT IDENTITY(1,1) PRIMARY KEY,
    [name] NVARCHAR(100) NOT NULL,
    [address] NVARCHAR(255) NOT NULL UNIQUE,
    phone_num NVARCHAR(13) NOT NULL,
    worktime_start TIME NOT NULL,
    worktime_end TIME NOT NULL,
    CHECK (worktime_start < worktime_end)
);
CREATE TABLE Menu_Item (
    menu_item_id INT IDENTITY(1,1) PRIMARY KEY,
    restaurant_id INT NOT NULL,
    name_of_dish NVARCHAR(100) NOT NULL,
    ingredients NVARCHAR(MAX) NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price > 0),

    CONSTRAINT FK_MenuItem_Restaurant
        FOREIGN KEY (restaurant_id) REFERENCES Restaurant(restaurant_id)
        ON DELETE CASCADE
);
CREATE TABLE Courier (
    courier_id INT IDENTITY(1,1) PRIMARY KEY,
    first_name NVARCHAR(50) NOT NULL,
    last_name NVARCHAR(50) NOT NULL,
    phone_number NVARCHAR(20) NOT NULL UNIQUE,
    vehicle_type NVARCHAR(20) NOT NULL CHECK (vehicle_type IN ('car','bike','scooter','walk')),
    delivery_tax DECIMAL(10,2) NOT NULL CHECK (delivery_tax >= 0)
);
CREATE TABLE [Order] (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    order_number NVARCHAR(50) NULL,
    restaurant_id INT NOT NULL,
    user_id INT NOT NULL,
    courier_id INT NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    total_sum DECIMAL(10,2) DEFAULT 0 CHECK (total_sum >= 0),
    delivery_time DATETIME NULL,
    delivery_address NVARCHAR(255) NOT NULL,

    CONSTRAINT FK_Order_User FOREIGN KEY (user_id) REFERENCES [User](user_id),
    CONSTRAINT FK_Order_Restaurant FOREIGN KEY (restaurant_id) REFERENCES Restaurant(restaurant_id),
    CONSTRAINT FK_Order_Courier FOREIGN KEY (courier_id) REFERENCES Courier(courier_id)
);

ALTER TABLE [Order]
ADD CONSTRAINT DF_Order_DeliveryTime
DEFAULT (DATEADD(MINUTE, 45, GETDATE())) FOR delivery_time;


CREATE TABLE Order_Item (
    order_id INT NOT NULL,
    menu_item_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    subtotal DECIMAL(10,2) DEFAULT 0 CHECK (subtotal >= 0),
    special_request NVARCHAR(255) NULL,

    CONSTRAINT PK_OrderItem PRIMARY KEY (order_id, menu_item_id),
    CONSTRAINT FK_OrderItem_Order FOREIGN KEY (order_id) REFERENCES [Order](order_id) ON DELETE CASCADE,
    CONSTRAINT FK_OrderItem_Menu FOREIGN KEY (menu_item_id) REFERENCES Menu_Item(menu_item_id)
  
);

CREATE TABLE Payment (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,
    payment_method NVARCHAR(20) NOT NULL CHECK (payment_method IN ('cash','card')),
    payment_status NVARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending','completed','failed')),
    payment_date_and_time DATETIME DEFAULT GETDATE(),
    payment_amount DECIMAL(10,2) NOT NULL CHECK (payment_amount >= 0),
	currency NVARCHAR(3) NOT NULL DEFAULT 'BGN',
    tip_amount DECIMAL(10,2) DEFAULT 0 CHECK (tip_amount >= 0),

    CONSTRAINT FK_Payment_Order FOREIGN KEY (order_id) REFERENCES [Order](order_id)
);






/*	Процедура за създаване на артикул в менюто*/
CREATE PROCEDURE sp_AddMenuItem
    @restaurant_id INT,
    @name_of_dish NVARCHAR(100),
    @ingredients NVARCHAR(MAX) = NULL,
    @price DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    -- Вмъкваме нов артикул
    INSERT INTO Menu_Item (restaurant_id, name_of_dish, ingredients, price)
    VALUES (@restaurant_id, @name_of_dish, @ingredients, @price);

    -- Връщаме ID на новия артикул
    SELECT SCOPE_IDENTITY() AS NewMenuItemID;
END;
GO




/* Функция*/
CREATE FUNCTION fn_GetMenuItemCount(@restaurant_id INT)
RETURNS INT
AS
BEGIN
    DECLARE @count INT;

    SELECT @count = COUNT(*)
    FROM Menu_Item
    WHERE restaurant_id = @restaurant_id;

    RETURN ISNULL(@count, 0);
END;
GO


/*Тригер*/

CREATE TRIGGER trg_update_subtotal
ON Order_Item
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE oi
    SET oi.subtotal = oi.quantity * mi.price
    FROM Order_Item oi
    INNER JOIN Menu_Item mi ON oi.menu_item_id = mi.menu_item_id
    INNER JOIN inserted i ON oi.order_id = i.order_id AND oi.menu_item_id = i.menu_item_id;
END;



CREATE TRIGGER trg_update_total_sum
ON Order_Item
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE o
    SET o.total_sum = 
        ISNULL((
            SELECT SUM(oi.subtotal)
            FROM Order_Item oi
            WHERE oi.order_id = o.order_id
        ), 0)
        + ISNULL((
            SELECT c.delivery_tax
            FROM Courier c
            WHERE c.courier_id = o.courier_id
        ), 0)
    FROM [Order] o
    WHERE o.order_id IN (
        SELECT DISTINCT order_id FROM inserted
        UNION
        SELECT DISTINCT order_id FROM deleted
    );
END;

 -- Обновяване на order_number за новите поръчки

CREATE TRIGGER trg_update_order_number
ON [Order]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;


    UPDATE o
    SET o.order_number = 'ORD-' + CAST(YEAR(o.created_at) AS NVARCHAR(4))
                             + '-' + RIGHT('0000' + CAST(o.order_id AS NVARCHAR(4)), 4)
    FROM [Order] o
    INNER JOIN inserted i ON o.order_id = i.order_id;
END;








--------------------------------------------------------
			--Тестове--
--------------------------------------------------------

SELECT * FROM Order_Item;  
SELECT * FROM [Order];   
SELECT * FROM Restaurant 
SELECT * FROM Menu_Item    


-- съхранена процедура пример
EXEC sp_AddMenuItem 
    @restaurant_id = 5,
    @name_of_dish = 'Pizza 4 cheese',
    @ingredients = 'blue cheese, mozzarella, cream cheese, cheddar',
    @price = 14.50;

-- пример за функцията, връщаща общия брой на арикулите в менюто на рестарант
SELECT dbo.fn_GetMenuItemCount(3) AS MenuItemCount;

--Пример за създаване на поръчка/ генериране на нейния номер / сумиране на общата стойност
INSERT INTO [Order] (order_number, restaurant_id, user_id, courier_id, delivery_address, total_sum)
VALUES
( 1, 5, 2, 5, 'Burgas, bul. Dame Gruev 15', 0);

INSERT INTO Order_Item (order_id, menu_item_id, quantity)
VALUES (18, 20, 2);


INSERT INTO Payment (order_id, payment_method, payment_status, payment_date_and_time, payment_amount, tip_amount, currency)
VALUES
(18, 'card', 'completed', GETDATE(), 30.50, 2.50, 'BGN'),