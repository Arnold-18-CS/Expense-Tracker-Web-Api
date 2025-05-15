const { Pool } = require('pg');

// Initialize the PostgreSQL connection pool with a retry mechanism
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 20, // Maximum number of clients in the pool
});

// Function to wait for database connection
const waitForDatabase = async (retries = 10, delayMs = 5000) => {
  for (let attempt = 1; attempt <= retries; attempt++) {
    try {
      const client = await pool.connect();
      await client.query('SELECT 1');
      client.release();
      console.log('Database connection established');
      return true;
    } catch (err) {
      console.log(`Attempt ${attempt} failed to connect to database: ${err.message}. Retrying in ${delayMs / 1000} seconds...`);
      if (attempt === retries) {
        console.error(`All ${retries} attempts failed to connect to database: ${err.stack}`);
        throw err;
      }
      await new Promise(resolve => setTimeout(resolve, delayMs));
    }
  }
};

// Function to initialize the expenses table and add a sample expense
const initializeDatabase = async () => {
  try {
    // Wait for the database to be ready
    await waitForDatabase();

    // Check if the expenses table exists
    const tableCheckQuery = `
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'expenses'
      );
    `;
    const { rows } = await pool.query(tableCheckQuery);
    const tableExists = rows[0].exists;

    if (!tableExists) {
      // Create the expenses table if it doesn't exist
      const createTableQuery = `
        CREATE TABLE expenses (
          id SERIAL PRIMARY KEY,
          description TEXT NOT NULL,
          amount NUMERIC(10, 2) NOT NULL,
          category TEXT,
          date DATE NOT NULL
        );
      `;
      await pool.query(createTableQuery);
      console.log('Expenses table created successfully');

      // Insert a sample expense
      const insertSampleExpenseQuery = `
        INSERT INTO expenses (description, amount, category, date)
        VALUES ($1, $2, $3, $4)
        RETURNING *;
      `;
      const sampleExpense = [
        'Sample Coffee',
        5.00,
        'Food',
        '2025-05-15'
      ];
      const { rows: insertedRows } = await pool.query(insertSampleExpenseQuery, sampleExpense);
      console.log('Sample expense inserted:', insertedRows[0]);
    } else {
      console.log('Expenses table already exists');
    }
  } catch (err) {
    console.error('Error initializing database:', err.stack);
    throw err;
  }
};

// Call the initialization function when the module is loaded
initializeDatabase().catch(err => {
  console.error('Failed to initialize database:', err);
  process.exit(1);
});

module.exports = pool;