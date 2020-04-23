const ErrorResponse = require('../utils/errorResponse');

exports.errorMiddleware = (err, req, res, next) => {
    let error = { ...err };
    error.message = err.message;

    console.log('Here We Go Again Error -------->', err)

    if (err.name === 'ValidationError') {
        error = new ErrorResponse(Object.values(err.errors)[0].message, 404);
    }

    if (err.code === 11000) {
        if (Object.keys(err.keyValue)[0].includes('username')) {
            error = new ErrorResponse('User With This Username is Already Registered', 400);
        }
    }

    if (err.name === 'TokenExpiredError') {
        error = new ErrorResponse('Unauthenticated Users Not Allowed', 401);
    }


    return res.status(error.statusCode || 500).json({
        success: false,
        statusCode: error.statusCode || 500,
        message: error.message || 'Internal Server Error'
    });
}