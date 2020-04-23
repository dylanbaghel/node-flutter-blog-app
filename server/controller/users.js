const User = require('../models/User');
const ErrorResponse = require('../utils/errorResponse');
const { asyncHandler } = require('../middlewares/asyncHandler');

/**
 * @method - PATCH
 * @desc - Upload Profile of a User
 * @param - profileImage (Multipart Data)
 * @access - PRIVATE
 */
exports.uploadProfileImage = asyncHandler(async (req, res, next) => {
    if (!req.file) {
        return next(new ErrorResponse("Please Enter Profile Image", 400));
    }
    const user = await User.findByIdAndUpdate(req.user._id, {
        $set: {
            profile: {
                imagePath: req.file.url,
                publicId: req.file.public_id
            }
        }
    }, { new: true })
    res.json({
        success: true,
        statusCode: 200,
        data: user
    });
});

/**
 * @method - PATCH
 * @desc - Update a User
 * @param - fullName, email
 * @access - PRIVATE
 */
exports.updateUser = asyncHandler(async (req, res, next) => {
    const { fullName, email } = req.body;
    const updateData = {};
    if (fullName) updateData.fullName = fullName;
    if (email) updateData.email = email;

    const user = await User.findByIdAndUpdate(req.user._id, {
        $set: updateData
    }, { new: true, runValidators: true });

    return res.status(200).json({
        success: true,
        statusCode: 200,
        data: user
    });

});