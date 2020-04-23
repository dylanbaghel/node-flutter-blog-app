// Third Party Modules
const router = require('express').Router();

// Custom Module Files
const { uploadProfileImage, updateUser } = require('../controller/users');
const { authenticate } = require('../middlewares/authenticate');
const { profileImageUpload } = require('../utils/multer-cloudinary');
// Routes
router.patch('/profile', authenticate, profileImageUpload.single('profileImage'), uploadProfileImage);
router.patch('/update', authenticate, updateUser);
// Export Router
module.exports = router;