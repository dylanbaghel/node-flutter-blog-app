const ErrorResponse = require('../utils/errorResponse');
const { asyncHandler } = require('../middlewares/asyncHandler');
const jwt = require('jsonwebtoken');

const User = require('../models/User');

exports.getUserId = asyncHandler(async (req, res, next) => {
    const authHeader = req.headers.authorization;

    if (authHeader && authHeader.startsWith('Bearer')) {
        const token = authHeader.split(" ")[1];
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        const foundUser = await User.findById(decoded.userId);
        console.log(decoded)
        req.user = foundUser;
    }
    next();
});

exports.authenticate = asyncHandler(async (req, res, next) => {
    const authHeader = req.headers.authorization;

    if (!authHeader) {
        return next(new ErrorResponse('Unauthenticated Users Not Allowed', 401));
    }

    if (!authHeader.startsWith('Bearer')) {
        return next(new ErrorResponse('Unauthenticated Users Not Allowed', 401));
    }

    const token = authHeader.split(" ")[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    const foundUser = await User.findById(decoded.userId);
    req.user = foundUser;
    next();
});

exports.authorize = (...roles) => {
    return (req, res, next) => {
        if (!roles.includes(req.user.role)) {
            return next(new ErrorResponse("Unauthorized Access", 401));
        }

        next();
    }
};