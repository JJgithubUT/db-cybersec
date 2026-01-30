-- Base de datos para un punto de venta random

DROP TABLE IF EXISTS order_item CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS product CASCADE;
DROP TABLE IF EXISTS customer CASCADE;
DROP TABLE IF EXISTS company CASCADE;

CREATE TABLE company (
    id_company SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    address     TEXT NOT NULL
);

CREATE TABLE customer (
    ci          VARCHAR(20) PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    birthdate  DATE,
    address     TEXT,
    phone       VARCHAR(20)
);

CREATE TABLE product (
    code        VARCHAR(20) PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    price       NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    id_company  INTEGER NOT NULL,

    CONSTRAINT fk_product_company
        FOREIGN KEY (id_company)
        REFERENCES company(id_company)
        ON DELETE RESTRICT
);

CREATE TABLE orders (
    id_order    SERIAL PRIMARY KEY,
    order_date  DATE NOT NULL,
    total       NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (total >= 0),
    ci_customer VARCHAR(20) NOT NULL,
    id_company  INTEGER NOT NULL,

    CONSTRAINT fk_order_customer
        FOREIGN KEY (ci_customer)
        REFERENCES customer(ci)
        ON DELETE RESTRICT,

    CONSTRAINT fk_order_company
        FOREIGN KEY (id_company)
        REFERENCES company(id_company)
        ON DELETE RESTRICT
);

CREATE TABLE order_item (
    id_order_item SERIAL PRIMARY KEY,
    units         INTEGER NOT NULL CHECK (units > 0),
    price         NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    id_order      INTEGER NOT NULL,
    product_code  VARCHAR(20) NOT NULL,

    CONSTRAINT fk_item_order
        FOREIGN KEY (id_order)
        REFERENCES orders(id_order)
        ON DELETE CASCADE,

    CONSTRAINT fk_item_product
        FOREIGN KEY (product_code)
        REFERENCES product(code)
        ON DELETE RESTRICT,

    CONSTRAINT uq_order_product
        UNIQUE (id_order, product_code)
);

CREATE INDEX idx_product_company ON product(id_company);
CREATE INDEX idx_orders_customer ON orders(ci_customer);
CREATE INDEX idx_orders_company ON orders(id_company);
CREATE INDEX idx_item_order ON order_item(id_order);
CREATE INDEX idx_item_product ON order_item(product_code);

CREATE OR REPLACE FUNCTION update_order_total()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE orders
    SET total = COALESCE((
        SELECT SUM(units * price)
        FROM order_item
        WHERE id_order = COALESCE(NEW.id_order, OLD.id_order)
    ), 0)
    WHERE id_order = COALESCE(NEW.id_order, OLD.id_order);

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- TRIGGERS
-- ============================================
CREATE TRIGGER trg_item_insert
AFTER INSERT ON order_item
FOR EACH ROW
EXECUTE FUNCTION update_order_total();

CREATE TRIGGER trg_item_update
AFTER UPDATE ON order_item
FOR EACH ROW
EXECUTE FUNCTION update_order_total();

CREATE TRIGGER trg_item_delete
AFTER DELETE ON order_item
FOR EACH ROW
EXECUTE FUNCTION update_order_total();

INSERT INTO company (name, address) VALUES
('TechNova', 'Av. Reforma 123, CDMX'),
('GreenFoods', 'Calle 5 #45, Guadalajara');

INSERT INTO customer (ci, name, birthdate, address, phone) VALUES
('CI001', 'Juan Pérez', '1995-04-10', 'Col. Centro, CDMX', '5512345678'),
('CI002', 'María López', '1990-08-22', 'Zapopan, Jalisco', '3311122233');

INSERT INTO product (code, name, price, id_company) VALUES
('P001', 'Laptop Gamer', 25000.00, 1),
('P002', 'Mouse Inalámbrico', 450.00, 1),
('P003', 'Café Orgánico 1kg', 320.00, 2),
('P004', 'Miel Natural 500g', 180.00, 2);

INSERT INTO orders (order_date, ci_customer, id_company) VALUES
('2026-01-20', 'CI001', 1),
('2026-01-21', 'CI002', 2);

-- Pedido 1 (TechNova)
INSERT INTO order_item (units, price, id_order, product_code) VALUES
(1, 25000.00, 1, 'P001'),
(2, 450.00, 1, 'P002');

-- Pedido 2 (GreenFoods)
INSERT INTO order_item (units, price, id_order, product_code) VALUES
(3, 320.00, 2, 'P003'),
(1, 180.00, 2, 'P004');

SELECT
    o.id_order,
    o.order_date,
    c.name AS customer,
    co.name AS company,
    p.name AS product,
    oi.units,
    oi.price,
    (oi.units * oi.price) AS subtotal
FROM orders o
JOIN customer c ON c.ci = o.ci_customer
JOIN company co ON co.id_company = o.id_company
JOIN order_item oi ON oi.id_order = o.id_order
JOIN product p ON p.code = oi.product_code
ORDER BY o.id_order;
