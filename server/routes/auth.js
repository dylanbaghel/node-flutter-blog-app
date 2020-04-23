// Third Party Modules
const router = require('express').Router();

// Custom Module Files
const { registerUser, loginUser, getMe } = require('../controller/auth');
const { authenticate } = require('../middlewares/authenticate');
// Routes
router.post('/register', registerUser);
router.post('/login', loginUser);
router.get('/me', authenticate, getMe)
// Export Router
module.exports = router;