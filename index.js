const express = require('express');
const app = express();
const PORT = 3000;

// Middleware để parse JSON
app.use(express.json());

// Route chính
app.get('/', (req, res) => {
  res.send('Chào mừng đến với Express!');
});

// Route API đơn giản
app.get('/api', (req, res) => {
  res.json({ message: 'Đây là API endpoint' });
});

// Khởi động server
app.listen(PORT, () => {
  console.log(`Server đang chạy tại http://localhost:${PORT}`);
});
