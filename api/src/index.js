const express = require('express');
const cors = require('cors');
const expenseRoutes = require('./routes/expenses');
require('dotenv').config();
const client = require('prom-client');

const app = express();
const port = process.env.PORT || 3000;

// Enable metrics collection
const collectDefaultMetrics = client.collectDefaultMetrics;
collectDefaultMetrics({ timeout: 5000 });

// Create a counter for API requests
const requestCounter = new client.Counter({
    name: 'api_requests_total',
    help: 'Total number of API requests',
    labelNames: ['method', 'route', 'status']
});

app.use(cors());
app.use(express.json());

// Middleware to count requests
app.use((req, res, next) => {
    res.on('finish', () => {
        requestCounter.inc({
            method: req.method,
            route: req.path,
            status: res.statusCode
        });
    });
    next();
});

app.use('/api/expenses', expenseRoutes);

app.get('/test', (req, res) => {
    console.log('Server is up and running');
    res.json({ message: 'Server is up' });
});

// Metrics endpoint
app.get('/metrics', async (req, res) => {
    res.set('Content-Type', client.register.contentType);
    res.end(await client.register.metrics());
});

app.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`)
});