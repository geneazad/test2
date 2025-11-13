// ########################################
// ########## SETUP

// Express
const express = require('express');
const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));

const PORT = 31231;

// Database
const db = require('./database/db-connector');

// Handlebars
const { engine } = require('express-handlebars'); // Import express-handlebars engine
app.engine('.hbs', engine({ extname: '.hbs' })); // Create instance of handlebars
app.set('view engine', '.hbs'); // Use handlebars engine for *.hbs files.

// ########################################
// ########## ROUTE HANDLERS

// READ ROUTES
app.get('/', async function (req, res) {
    try {
        res.render('home'); // Render the home.hbs file
    } catch (error) {
        console.error('Error rendering page:', error);
        // Send a generic error message to the browser
        res.status(500).send('An error occurred while rendering the page.');
    }
});


//############
//## CUSTOMERS

// READ
app.get('/customers', async (req, res) => {
    try {
        const [customers] = await db.query('SELECT * FROM customers;');
        res.render('customers', { customers });
    } catch (error) {
        console.error('Error executing queries:', error);
        res.status(500).send('An error occurred while executing database queries');
    }
});


//#############
//## CATEGORIES

// READ
app.get('/categories', async (req, res) => {
    try {
        const [categories] = await db.query('SELECT * FROM categories;');
        res.render('categories', { categories, error: req.query.error });
    } catch (error) {
        console.error('Error loading categories:', error);
        res.status(500).send('An error occurred while loading categories.');
    }
});

// CREATE
app.post('/categories', async (req, res) => {
    const { category_name, description } = req.body;

    try {
        await db.query(
            'INSERT INTO categories (category_name, description) VALUES (?, ?);',
            [category_name, description]
        );
        res.redirect('/categories');
    } catch (error) {
        console.error('Error adding category:', error);
        const message = encodeURIComponent('Failed to add category. Please try again.');
        res.redirect(`/categories?error=${message}`);
    }
});

// DELETE
app.post('/categories/delete/:id', async (req, res) => {
    const { id } = req.params;

    try {
        await db.query('DELETE FROM categories WHERE id_category = ?;', [id]);
        res.redirect('/categories');
    } catch (error) {
        console.error('Error deleting category:', error);
        let message = 'Failed to delete category. Please try again.';

        if (error.code === 'ER_ROW_IS_REFERENCED_2') {
            message = 'Cannot delete category because it is in use.';
        }

        res.redirect(`/categories?error=${encodeURIComponent(message)}`);
    }
});


//###########
//## PRODUCTS

// READ
app.get('/products', async (req, res) => {
  try {
    const [products] = await db.query(`
      SELECT p.id_product, p.product_name, p.price, p.inventory_quantity, c.category_name AS category
      FROM products p
      LEFT JOIN categories c ON p.category_id_category = c.id_category
    `);
    const [categories] = await db.query('SELECT * FROM categories');
    res.render('products', { products, categories });
  } catch (error) {
    console.error('Error executing queries:', error);
    res.status(500).send('An error occurred while executing database queries');
  }
});


// ########
//## ORDERS

// READ
app.get('/orders', async (req, res) => {
    try {
        const [orders] = await db.query(`
            SELECT o.id_order, o.order_date, o.total_amount,
                   c.cust_name AS customer
            FROM orders o
            JOIN customers c ON o.customers_id_customer = c.id_customer;
        `);
        const [customers] = await db.query('SELECT * FROM customers;');
        res.render('orders', { orders, customers });
    } catch (error) {
        console.error('Error executing queries:', error);
        res.status(500).send('An error occurred while executing database queries.');
    }
});


//#################
//## PRODUCT_ORDERS 

// READ
app.get('/product_orders', async (req, res) => {
    try {
        const [po] = await db.query(`
            SELECT po.products_id_product AS product_id,
                   p.product_name,
                   po.orders_id_order AS order_id,
                   o.order_date,
                   po.quantity
            FROM product_orders po
            JOIN products p ON po.products_id_product = p.id_product
            JOIN orders o ON po.orders_id_order = o.id_order;
        `);
        const [products] = await db.query('SELECT * FROM products;');
        const [orders] = await db.query('SELECT * FROM orders;');
        res.render('product_orders', { product_orders: po, products, orders });
    } catch (error) {
        console.error('Error executing queries:', error);
        res.status(500).send('Error loading product orders.');
    }
});


// ########################################
// ########## LISTENER

app.listen(PORT, function () {
    console.log(
        'Express started on http://localhost:' +
            PORT +
            '; press Ctrl-C to terminate.'
    );
});

