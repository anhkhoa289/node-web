const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Welcome to Node.js Express API',
    version: '1.0.0'
  });
});

// Start server
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
