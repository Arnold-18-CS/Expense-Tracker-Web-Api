const express = require('express');
const pool = require('../db')
const router = express.Router();

// GET all expenses
router.get('/', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM expenses');
        console.log('Fetched all expenses successfully');
        res.json(result.rows);
    } catch (err) {
        console.error(err.stack);
        res.status(500).json({ error: `Internal server error: ${err.stack}` });
    }
});

// GET total expenses
router.get('/total', async (req, res) => {
    try {
        const result = await pool.query('SELECT SUM(amount) AS total FROM expenses');
        console.log('Fetched total expenses successfully');
        res.status(200).json({ total: result.rows[0].total });
    } catch (err) {
        console.error(err.stack);
        res.status(500).json({ error: `Internal server error: ${err.stack}` });
    }
});

// POST a new expense
router.post('/', async (req, res) => {
    const { amount, category, description, date } = req.body;
    try {
        const result = await pool.query(
            'INSERT INTO expenses (amount, category, description, date) VALUES ($1, $2, $3, $4) RETURNING *',
            [amount, category, description, date]
        );
        console.log('Added new expense successfully');
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err.stack);
        res.status(500).json({ error: `Internal server error: ${err.stack}` });
    }
});

// PUT (update) an expense
router.put('/:id', async (req, res) => {
    const { id } = req.params;
    const { amount, category, description, date } = req.body;
    try {
        const result = await pool.query(
            'UPDATE expenses SET amount = $1, category = $2, description = $3, date = $4 WHERE id = $5 RETURNING *',
            [amount, category, description, date, id]
        );
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Expense not found' });
        }
        console.log('Updated expense successfully');
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err.stack);
        res.status(500).json({ error: `Internal server error: ${err.stack}` });
    }
});

// DELETE an expense
router.delete('/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const result = await pool.query('DELETE FROM expenses WHERE id = $1 RETURNING *', [id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Expense not found' });
        }
        console.log('Expense deleted successfully');
        res.json({ message: 'Expense deleted' });
    } catch (err) {
        console.error(err.stack);
        res.status(500).json({ error: `Internal server error: ${err.stack}`});
    }
});

module.exports = router;