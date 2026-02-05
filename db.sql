CREATE TABLE company (
    company_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE address (
    address_id SERIAL PRIMARY KEY,
    street VARCHAR(150),
    city VARCHAR(100),
    state VARCHAR(100),
    zip_code VARCHAR(20)
);

CREATE TABLE customer (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    birth_date DATE,
    phone VARCHAR(30),
    address_id INT,
    CONSTRAINT fk_customer_address
        FOREIGN KEY (address_id)
        REFERENCES address(address_id)
);

CREATE TABLE product (
    product_id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    current_price NUMERIC(10,2) NOT NULL,
    company_id INT NOT NULL,
    CONSTRAINT fk_product_company
        FOREIGN KEY (company_id)
        REFERENCES company(company_id)
);

CREATE TABLE "order" (
    order_id SERIAL PRIMARY KEY,
    order_date DATE NOT NULL,
    customer_id INT NOT NULL,
    CONSTRAINT fk_order_customer
        FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id)
);

CREATE TABLE order_item (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    units INT NOT NULL CHECK (units > 0),
    unit_price NUMERIC(10,2) NOT NULL,
    CONSTRAINT fk_orderitem_order
        FOREIGN KEY (order_id)
        REFERENCES "order"(order_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_orderitem_product
        FOREIGN KEY (product_id)
        REFERENCES product(product_id)
);

ALTER TABLE order_item
ADD CONSTRAINT uq_order_product UNIQUE (order_id, product_id);

CREATE VIEW order_total AS
SELECT 
    o.order_id,
    SUM(oi.units * oi.unit_price) AS total
FROM "order" o
JOIN order_item oi ON o.order_id = oi.order_id
GROUP BY o.order_id;

INSERT INTO address (street, city, state, zip_code) VALUES
('Av. Siempre Viva 742', 'Springfield', 'IL', '62701'),
('Calle Falsa 123', 'Buenos Aires', 'BA', '1000'),
('Gran Via 45', 'Madrid', 'MD', '28013'),
('Rua Augusta 99', 'São Paulo', 'SP', '01305'),
('Main St 10', 'New York', 'NY', '10001'),
('Queen St 50', 'Toronto', 'ON', 'M5H'),
('Oxford St 200', 'London', 'LDN', 'W1D'),
('Champs Elysees 1', 'Paris', 'IDF', '75008'),
('Via Roma 15', 'Rome', 'RM', '00100'),
('Alexanderplatz 3', 'Berlin', 'BE', '10178');

INSERT INTO company (name) VALUES
('TechCorp'),
('Foodies SA'),
('GlobalSoft'),
('AutoParts Ltd'),
('HealthPlus'),
('EduSmart'),
('HomeDesign'),
('FashionHub'),
('SportPro'),
('GreenEnergy');

INSERT INTO customer (name, birth_date, phone, address_id) VALUES
('Juan Perez', '1990-05-12', '111-1111', 1),
('Maria Gomez', '1985-08-23', '222-2222', 2),
('Carlos Lopez', '1978-03-10', '333-3333', 3),
('Ana Torres', '1995-11-01', '444-4444', 4),
('Luis Fernandez', '1982-07-19', '555-5555', 5),
('Sofia Martinez', '1998-01-30', '666-6666', 6),
('Pedro Sanchez', '1975-09-14', '777-7777', 7),
('Laura Diaz', '1988-06-25', '888-8888', 8),
('Diego Romero', '1992-04-18', '999-9999', 9),
('Valentina Ruiz', '2000-12-05', '000-0000', 10);

INSERT INTO product (code, name, current_price, company_id) VALUES
('P001', 'Laptop', 1200.00, 1),
('P002', 'Mouse', 25.00, 1),
('P003', 'Hamburger', 8.50, 2),
('P004', 'ERP Software', 5000.00, 3),
('P005', 'Brake Pads', 150.00, 4),
('P006', 'Vitamins', 30.00, 5),
('P007', 'Online Course', 200.00, 6),
('P008', 'Sofa', 900.00, 7),
('P009', 'Jacket', 120.00, 8),
('P010', 'Football Ball', 45.00, 9);

INSERT INTO "order" (order_date, customer_id) VALUES
('2024-01-10', 1),
('2024-01-11', 2),
('2024-01-12', 3),
('2024-01-13', 4),
('2024-01-14', 5),
('2024-01-15', 6),
('2024-01-16', 7),
('2024-01-17', 8),
('2024-01-18', 9),
('2024-01-19', 10);

INSERT INTO order_item (order_id, product_id, units, unit_price) VALUES
(1, 1, 1, 1200.00),
(2, 2, 2, 25.00),
(3, 3, 3, 8.50),
(4, 4, 1, 5000.00),
(5, 5, 2, 150.00),
(6, 6, 4, 30.00),
(7, 7, 1, 200.00),
(8, 8, 1, 900.00),
(9, 9, 2, 120.00),
(10, 10, 3, 45.00);

SELECT * FROM order_total;
