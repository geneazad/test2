-- =========================
-- Lord Renoux’s Arsenal, Online Store (DB-Backed Website)
-- Team members: Gene Azad, Antoine Brown
-- Group:  53
-- Course: CS340
-- =========================

SET FOREIGN_KEY_CHECKS = 0;
SET NAMES utf8mb4;

-- =========================
-- Tables
-- =========================

-- categories
DROP TABLE IF EXISTS categories;
CREATE TABLE categories (
  id_category INT NOT NULL AUTO_INCREMENT,
  category_name VARCHAR(145) NOT NULL,
  description VARCHAR(145) NULL,
  CONSTRAINT pk_categories PRIMARY KEY (id_category),
  CONSTRAINT uq_categories_name UNIQUE (category_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- customers
DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
  id_customer INT NOT NULL AUTO_INCREMENT,
  cust_name   VARCHAR(145) NOT NULL,
  cust_house  VARCHAR(145) NULL,
  CONSTRAINT pk_customers PRIMARY KEY (id_customer)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- products (M:1 categories)
DROP TABLE IF EXISTS products;
CREATE TABLE products (
  id_product          INT NOT NULL AUTO_INCREMENT,
  product_name        VARCHAR(145) NOT NULL,
  price               DECIMAL(10,2) NOT NULL,
  inventory_quantity  INT NOT NULL DEFAULT 0,
  category_id_category INT NOT NULL,
  CONSTRAINT pk_products PRIMARY KEY (id_product),
  CONSTRAINT fk_products_category
    FOREIGN KEY (category_id_category)
    REFERENCES categories (id_category)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX ix_products_category ON products (category_id_category);

-- orders (M:1 customers)
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
  id_order               INT NOT NULL AUTO_INCREMENT,
  order_date             DATETIME NOT NULL,
  total_amount           DECIMAL(10,2) NOT NULL,
  customers_id_customer  INT NOT NULL,
  CONSTRAINT pk_orders PRIMARY KEY (id_order),
  CONSTRAINT fk_orders_customer
    FOREIGN KEY (customers_id_customer)
    REFERENCES customers (id_customer)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX ix_orders_customer ON orders (customers_id_customer);
CREATE INDEX ix_orders_order_date ON orders (order_date);

-- product_orders (M:N orders-products)
DROP TABLE IF EXISTS product_orders;
CREATE TABLE product_orders (
  products_id_product INT NOT NULL,
  orders_id_order     INT NOT NULL,
  quantity            INT NOT NULL,
  -- Composite PK ensures each product appears once per order
  CONSTRAINT pk_product_orders PRIMARY KEY (products_id_product, orders_id_order),
  CONSTRAINT fk_po_product
    FOREIGN KEY (products_id_product)
    REFERENCES products (id_product)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_po_order
    FOREIGN KEY (orders_id_order)
    REFERENCES orders (id_order)
    ON UPDATE CASCADE
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Indexes for joins 
CREATE INDEX ix_po_order ON product_orders (orders_id_order);

SET FOREIGN_KEY_CHECKS = 1;
-- =========================
-- Deleting an ORDER will cascade delete its line items in product_orders.
-- Deleting a PRODUCT is restricted if referenced by product_orders.
-- Deleting a CUSTOMER or CATEGORY is restricted if referenced by orders / products.
-- =========================



SET FOREIGN_KEY_CHECKS = 0;
SET AUTOCOMMIT = 0;
START TRANSACTION;

-- =========================
-- Sample Data
-- =========================
INSERT INTO categories (category_name, description) VALUES
 ('blades',   'Swords, daggers, and knives'),
 ('armor',    'Protective gear and shields'),
 ('alchemical','Oils, acids, and explosive vials');

INSERT INTO customers (cust_name, cust_house) VALUES
 ('Kelsier',      'House Venture'),
 ('Vin',          'House Renoux'),
 ('Sazed',        'Independent'),
 ('Elend Venture','House Venture'),
 ('Ham',          'Independent');

INSERT INTO products (product_name, price, inventory_quantity, category_id_category) VALUES
 ('Dueling Sword',         120.00,  40, 1),
 ('Glass Dagger',           35.00,  60, 1),
 ('Koloss Blade',          250.00,  10, 1),
 ('Steel Breastplate',     180.00,  25, 2),
 ('Reinforced Shield',     150.00,  30, 2),
 ('Padded Gambeson',        80.00,  35, 2),
 ('Allomantic Oil Vial',    20.00,  50, 3),
 ('Acidic Flask',           28.00,  30, 3),
 ('Flashpowder Pouch',      45.00,  20, 3);

INSERT INTO orders (order_date, total_amount, customers_id_customer) VALUES
 ('2025-10-01 10:15:00',  395.00, 1),
 ('2025-10-03 14:22:00',  215.00, 2),
 ('2025-10-05 09:05:00',  395.00, 4),
 ('2025-10-06 16:45:00',  156.00, 3);

INSERT INTO product_orders (products_id_product, orders_id_order, quantity) VALUES
 (1, 1, 1),
 (5, 1, 1),
 (9, 1, 1),
 (7, 1, 4),
 (2, 2, 1),
 (6, 2, 1),
 (7, 2, 5),
 (4, 3, 1),
 (5, 3, 1),
 (7, 3, 1),
 (9, 3, 1),
 (8, 4, 2),
 (2, 4, 1),
 (7, 4, 1),
 (9, 4, 1);

SET FOREIGN_KEY_CHECKS = 1;
COMMIT;
