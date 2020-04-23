const mongoose = require('mongoose');

exports.ImageSchema = new mongoose.Schema({
    imagePath: {
        type: String,
        required: [true, "Image Url Is Required"]
    },
    publicId: {
        type: String,
        required: [true, "Image Id is Required"]
    }
});