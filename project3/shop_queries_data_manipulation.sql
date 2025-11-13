
/* CUSTOMERS */

-- Get all customers for the Customers page
SELECT * FROM customers;

-- Add a new customer
INSERT INTO customers (cust_name, cust_house)
VALUES (:cust_name_input, :cust_house_input);

-- Delete a customer by ID
DELETE FROM customers
WHERE id_customer = :customer_id_selected;

/* PRODUCTS */

-- Get all products and their category names for the Products page
SELECT products.id_product,
       products.product_name,
       products.price,
       products.inventory_quantity,
       categories.category_name AS category
FROM products
LEFT JOIN categories
    ON products.category_id_category = categories.id_category;

-- Get all categories for the product category dropdown
SELECT * FROM categories;

-- Add a new product
INSERT INTO products (product_name, price, inventory_quantity, category_id_category)
VALUES (:product_name_input, :price_input, :inventory_quantity_input, :category_id_input);

-- Delete a product by ID
DELETE FROM products
WHERE id_product = :product_id_selected;

-- Update an existing product's details
UPDATE products
SET product_name = :product_name_input,
    price = :price_input,
    inventory_quantity = :inventory_quantity_input,
    category_id_category = :category_id_input
WHERE id_product = :product_id_selected;

/* ORDERS */

-- Get all orders and their associated customer names
SELECT orders.id_order,
       orders.order_date,
       orders.total_amount,
       customers.cust_name AS customer
FROM orders
JOIN customers
    ON orders.customers_id_customer = customers.id_customer;

-- Get all customers for the Order creation dropdown
SELECT * FROM customers;

-- Add a new order
INSERT INTO orders (order_date, total_amount, customers_id_customer)
VALUES (:order_date_input, :total_amount_input, :customer_id_input);

-- Delete an order by ID
DELETE FROM orders
WHERE id_order = :order_id_selected;

-- Update an existing order's details
UPDATE orders
SET order_date = :order_date_input,
    total_amount = :total_amount_input,
    customers_id_customer = :customer_id_input
WHERE id_order = :order_id_selected;


/* PRODUCT_ORDERS */

-- Get all product-order relationships with product and order details
SELECT product_orders.products_id_product AS product_id,
       products.product_name,
       product_orders.orders_id_order AS order_id,
       orders.order_date,
       product_orders.quantity
FROM product_orders
JOIN products
    ON product_orders.products_id_product = products.id_product
JOIN orders
    ON product_orders.orders_id_order = orders.id_order;

-- Get all products for the Product dropdown
SELECT * FROM products;

-- Get all orders for the Order dropdown
SELECT * FROM orders;

-- Add a product to an order
INSERT INTO product_orders (products_id_product, orders_id_order, quantity)
VALUES (:product_id_input, :order_id_input, :quantity_input);

-- Delete a product-order relationship
DELETE FROM product_orders
WHERE products_id_product = :product_id_selected
  AND orders_id_order = :order_id_selected;

-- Update the quantity of a product within an order
UPDATE product_orders
SET quantity = :quantity_input
WHERE products_id_product = :product_id_selected
  AND orders_id_order = :order_id_selected;