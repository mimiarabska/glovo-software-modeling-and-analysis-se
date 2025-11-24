INSERT INTO [User] (first_name, last_name, email, [password], phone_num, [address])
VALUES
('Atanas', 'Ninov', 'atanas.ninov@gmail.com', 'naskopass123', '0888123456', 'Plovdiv, ul. Bogomil 10'),
('Maria', 'Arabska', 'maria.arabska@gmail.com', 'mimipass123', '0888234567', 'Plovdiv, bul. Bulgaria 256'),
('Ivelina', 'Mircheva', 'ivelina.mircheva@gmail.com', 'ivkapass123', '0888345678', 'Klisura, ul. Nezabravka 12'),
('Nadejda', 'Kuneva', 'nadejda.kuneva@gmail.com', 'nadqpass123', '0888456789', 'Sopot, ul. Slavyanska 7'),
('Teodora', 'Petkova', 'tedy.petkova@gmail.com', 'tedypass123', '0888567890', 'Qmbol, ul. Vitosha 21'),
('Mariyana', 'Natova', 'mariyana.natova@gmail.com', 'mariyanapass123', '0888678901', 'Radilovo, ul. Knyaz Boris 15');

INSERT INTO Restaurant ([name], [address], phone_num, worktime_start, worktime_end)
VALUES
('Pizza House', 'Sofia, ul. Rakovski 20', '0888123001', '10:00', '22:00'),
('Burger King', 'Plovdiv, ul. Tsar Simeon 5', '0888123002', '09:00', '23:00'),
('Sushi World', 'Varna, ul. Primorska 12', '0888123003', '11:00', '22:30'),
('Tandoori Express', 'Burgas, ul. Slavyanska 7', '0888123004', '12:00', '21:00'),
('Pasta Fresca', 'Sofia, ul. Vitosha 21', '0888123005', '10:00', '20:00'),
('BBQ Corner', 'Plovdiv, ul. Knyaz Boris 15', '0888123006', '11:00', '23:00');

INSERT INTO Menu_Item (restaurant_id, name_of_dish, ingredients, price)
VALUES
(1, 'Margherita Pizza', 'Tomato, Cheese, Basil', 8.50),
(1, 'Pepperoni Pizza', 'Tomato, Cheese, Pepperoni', 9.50),
(2, 'Classic Burger', 'Beef, Lettuce, Tomato, Cheese', 7.00),
(2, 'Double Cheeseburger', 'Beef, Cheese, Pickles', 8.50),
(3, 'California Roll', 'Rice, Crab, Avocado', 6.50),
(3, 'Salmon Nigiri', 'Salmon, Rice', 5.50);

INSERT INTO Courier (first_name, last_name, phone_number, vehicle_type, delivery_tax)
VALUES
('Dimitar', 'Stoyanov', '0888999001', 'bike', 1.50),
('Nikolay', 'Petrov', '0888999002', 'car', 3.00),
('Kristina', 'Georgieva', '0888999003', 'scooter', 2.00),
('Radoslav', 'Ivanov', '0888999004', 'walk', 1.00),
('Vesela', 'Dimitrova', '0888999005', 'bike', 1.50),
('Petko', 'Nikolov', '0888999006', 'car', 3.50);
INSERT INTO [Order] (order_number, restaurant_id, user_id, courier_id, delivery_address, total_sum, delivery_time)
VALUES
('ORD-2025-0001', 1, 1, 1, 'Sofia, ul. Rakovski 10', 0, DATEADD(MINUTE, 45, GETDATE())),
('ORD-2025-0002', 2, 2, 2, 'Plovdiv, ul. Tsar Asen 5', 0, DATEADD(MINUTE, 30, GETDATE())),
('ORD-2025-0003', 3, 3, 3, 'Varna, ul. Nezabravka 12', 0, DATEADD(MINUTE, 50, GETDATE())),
('ORD-2025-0004', 4, 4, 4, 'Burgas, ul. Slavyanska 7', 0, DATEADD(MINUTE, 40, GETDATE())),
('ORD-2025-0005', 5, 5, 5, 'Sofia, ul. Vitosha 21', 0, DATEADD(MINUTE, 35, GETDATE())),
('ORD-2025-0006', 6, 6, 6, 'Plovdiv, ul. Knyaz Boris 15', 0, DATEADD(MINUTE, 60, GETDATE()));

INSERT INTO Order_Item (order_id, menu_item_id, quantity)
VALUES
(1, 1, 2),
(1, 2, 1),
(2, 3, 3),
(2, 4, 1),
(3, 5, 2),
(3, 6, 3),
(4, 1, 2);

INSERT INTO Payment (order_id, payment_method, payment_status, payment_amount, tip_amount, currency)
VALUES
(1, 'card', 'completed', 25.50, 2.00, 'BGN'),
(2, 'cash', 'pending', 30.00, 0.00, 'BGN'),
(3, 'card', 'completed', 22.00, 1.50, 'BGN'),
(4, 'cash', 'completed', 18.00, 2.00, 'BGN'),
(5, 'card', 'failed', 28.00, 0.00, 'BGN'),
(6, 'cash', 'completed', 35.00, 3.00, 'BGN');


