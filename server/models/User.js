const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { isEmail } = require('validator');

const { ImageSchema } = require('./sub-schema/Image');

const UserSchema = new mongoose.Schema({
    fullName: {
        type: String,
        required: [true, "Full Name is Required"]
    },
    username: {
        type: String,
        required: [true, "Username is Required"],
        minlength: [6, "Username Must Be More Than 6 Characters"],
        unique: true
    },
    password: {
        type: String,
        required: [true, "Password Is Required"],
        minlength: [6, "Password Must Be More Than 6 Characters"]
    },
    email: {
        type: String,
        validate: {
            validator: (value) => {
                return isEmail(value);
            },
            message: props => `${props.value} is not a valid email.`
        },
    },
    profile: ImageSchema,
    createdAt: {
        type: Date,
        default: Date.now
    },
    role: {
        type: String,
        default: 'reader',
        enum: ['reader']
    }
}, {
    toJSON: { virtuals: true },
    toObject: { virtuals: true }
});

UserSchema.virtual('id').get(function () {
    return this._id.toString();
});

UserSchema.methods.toJSON = function () {
    const obj = { ...this.toObject() };
    delete obj.password;

    return {
        ...obj
    };
}

UserSchema.methods.generateAuthToken = function () {
    const payload = {
        userId: this._id,
        username: this.username
    };
    return jwt.sign(payload, process.env.JWT_SECRET, {
        expiresIn: process.env.JWT_EXPIRES_IN
    });
}

UserSchema.methods.comparePassword = async function (password) {
    return await bcrypt.compare(password, this.password);
}

UserSchema.pre('save', async function () {
    if (this.isModified('password')) {
        this.password = await bcrypt.hash(this.password, 10);
    }
});

module.exports = mongoose.model('User', UserSchema);