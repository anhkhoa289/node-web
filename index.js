const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

// Middleware để parse JSON
app.use(express.json());

// Route chính
app.get('/', (req, res) => {
  res.json({
    message: 'Chào mừng đến với Node.js Express API',
    version: '1.0.0'
  });
});

// Route API đơn giản
app.get('/api', (req, res) => {
  res.json({ message: 'Đây là API endpoint' });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

// Khởi động server
app.listen(port, () => {
  console.log(`Server đang chạy tại http://localhost:${port}`);
});
