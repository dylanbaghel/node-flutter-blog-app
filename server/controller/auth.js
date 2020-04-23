const User = require('../models/User');
const ErrorResponse = require('../utils/errorResponse');
const { asyncHandler } = require('../middlewares/asyncHandler');
/**
 * @method - POST
 * @desc - Register a User
 * @param - fullName, username, password,
 * @access - PUBLIC
 */
exports.registerUser = asyncHandler(async (req, res, next) => {
    const newUser = await User.create({
        ...req.body
    });

    return res.status(200).json({
        success: true,
        statusCode: 200,
        data: newUser,
        token: newUser.generateAuthToken()
    });
});

/**
 * @method - POST
 * @desc - Login a User
 * @param - username, password,
 * @access - PUBLIC
 */
exports.loginUser = asyncHandler(async (req, res, next) => {
    const { username, password } = req.body;
    if (!username) {
        return next(new ErrorResponse('Username Is Required To Login', 400));
    }

    const foundUser = await User.findOne({ username: req.body.username });
    if (!foundUser) {
        return next(new ErrorResponse(`${username} is Not Registered With Us`, 404));
    }

    if (!password) {
        return next(new ErrorResponse('Password Is Required To Login', 400));
    }

    const isMatched = await foundUser.comparePassword(password);
    if (!isMatched) {
        return next(new ErrorResponse('Password Incorrect', 401));
    }

    return res.status(200).json({
        success: true,
        statusCode: 200,
        data: foundUser,
        token: foundUser.generateAuthToken()
    });
});

/**
 * @method - GET
 * @desc - Get Currently Logged In User
 * @access - PRIVATE
 */
exports.getMe = asyncHandler(async (req, res, next) => {
    const user = await User.findById(req.user._id);
    return res.status(200).json({
        success: true,
        statusCode: 200,
        data: user
    });
});