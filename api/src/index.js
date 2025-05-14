const express = require('express');
const cors = require('cors');
const expenseRoutes = require('./routes/expenses');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.use('/expenses', expenseRoutes);

app.get('/test', (req, res) => res.json({ message: 'Server is up' }));

app.listen(port, ()=>{
    console.log(`Server running on http://localhost:${port}`)
});