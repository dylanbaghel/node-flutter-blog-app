require('./db/db')();
// Third Party Modules
const express = require('express');
const app = express();
const cors = require('cors');

// Custom Module Files
const auth = require('./routes/auth');
const users = require('./routes/users');
const posts = require('./routes/posts');
const { errorMiddleware } = require('./middlewares/error');
// Middlwares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
// Routes
app.get('/', (req, res) => {
    return res.send('OK');
});
// Mounting Routes
app.use('/auth', auth);
app.use('/users', users);
app.use('/posts', posts);
app.use(errorMiddleware);
// Server Listen
const server = app.listen(process.env.PORT, console.log(`Server Up In Mode:${process.env.NODE_ENV} At PORT: ${process.env.PORT}`));

// Handle Unhandled Projection Error
process.on('unhandledRejection', (reason, promise) => {
    console.log(`Unhandled Error:__> ${reason.message}`);
    // server.close();
});