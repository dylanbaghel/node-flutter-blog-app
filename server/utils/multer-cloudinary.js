const cloudinary = require('cloudinary');
const cloudinaryStorage = require('multer-storage-cloudinary');
const multer = require('multer');

cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET
});

const profileStorage = cloudinaryStorage({
    cloudinary: cloudinary,
    folder: 'flutter_blog_app/profile',
    allowedFormats: ['jpg', 'png'],
    filename: function (req, file, cb) {
        cb(undefined, `${req.user._id}`);
    }
});

const postStorage = cloudinaryStorage({
    cloudinary: cloudinary,
    folder: 'flutter_blog_app/posts',
    allowedFormats: ['jpg', 'png'],
    filename: function (req, file, cb) {
        cb(undefined, `${Date.now()}+blog+posts`);
    }
});

exports.cloudinary = cloudinary;
exports.profileImageUpload = multer({ storage: profileStorage });
exports.postImageUpload = multer({ storage: postStorage });