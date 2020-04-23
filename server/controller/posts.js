const Post = require('../models/Post');
const ErrorResponse = require('../utils/errorResponse');
const { asyncHandler } = require('../middlewares/asyncHandler');
const pluck = require('../utils/pluck');
const { cloudinary } = require('../utils/multer-cloudinary');
/**
 * @method - POST
 * @desc - Create A New Post
 * @param - title, body, published (Optional, defaults to true)
 * @access - PRIVATE
 */
exports.createPost = asyncHandler(async (req, res, next) => {
    if (!req.file) {
        return next(new ErrorResponse('Please Provide A Image For This Post', 400));
    }
    const post = await Post.create({
        ...req.body,
        image: {
            imagePath: req.file.url,
            publicId: req.file.public_id
        },
        _creator: req.user._id
    });

    return res.status(200).json({
        success: true,
        statusCode: 200,
        data: post
    });
});

/**
 * @method - GET
 * @desc - Get All Posts
 * @access - PUBLIC
 */
exports.getAllPosts = asyncHandler(async (req, res, next) => {
    return res.status(200).json(res.advancedResults);
});

/**
 * @method - GET
 * @desc - Get Single Post
 * @access - PUBLIC / PRIVATE
 */
exports.getSinglePost = asyncHandler(async (req, res, next) => {
    console.log(req.user)
    const { id } = req.params;
    const post = await Post.findOne({
        _id: id,
        $or: [
            { published: true },
            { _creator: req.user ? req.user._id : undefined }
        ]
    }).populate('_creator');

    if (!post) {
        return next(new ErrorResponse('Post Not Found With The Given Id', 404));
    }

    return res.status(200).json({
        success: true,
        statusCode: 200,
        data: post
    });
});

/**
 * @method - PATCH
 * @desc - Update Post
 * @access - PRIVATE
 */
exports.updatePost = asyncHandler(async (req, res, next) => {
    const { id } = req.params;

    const updates = pluck(req.body, 'title', 'body', 'published');
    if (req.file) {
        updates.image = {
            imagePath: req.file.url,
            publicId: req.file.public_id
        };
    }

    try {
        const foundPost = await Post.findOne({
            _id: id,
            _creator: req.user._id
        });

        if (!foundPost) {
            throw new ErrorResponse(`Unable To Update Post, Post Not Found With This Id`, 404);
        }

        const post = await Post.findOneAndUpdate({
            _id: id,
            _creator: req.user._id
        }, {
            $set: {
                ...updates
            }
        }, { new: true, runValidators: true });

        if (req.file) {
            cloudinary.v2.uploader.destroy(foundPost.image.publicId, {}, (err, result) => {
                console.log(err, result);
            });
        }

        return res.status(200).json({
            success: true,
            statusCode: 200,
            data: post
        });
    } catch (err) {
        cloudinary.v2.uploader.destroy(req.file.public_id, {}, (err, result) => {
            throw new ErrorResponse(err.message, 500);
        });
        throw err;
    }
});

/**
 * @method - DELETE 
 * @desc - DELETE Post
 * @access - PRIVATE
 */
exports.deletePost = asyncHandler(async (req, res, next) => {
    const { id } = req.params;

    const foundPost = await Post.findOne({
        _id: id,
        _creator: req.user._id
    });

    if (!foundPost) {
        return next(new ErrorResponse('Unable To Delete Post, Not Found With This Id', 404));
    }

    await foundPost.remove();

    cloudinary.v2.uploader.destroy(foundPost.image.publicId);

    return res.status(200).json({
        success: true,
        statusCode: 200,
        data: {}
    });
});


/**
 * @method - PUT
 * @desc - toggle Like Status of a post
 * @access - PRIVATE
 */
exports.toggleLikePost = asyncHandler(async (req, res, next) => {
    const { id } = req.params;
    const foundPost = await Post.findById(id);

    if (!foundPost) {
        return next(new ErrorResponse('Unable To Like Post, Invalid Id', 400));
    }
    await foundPost.toggleLike(req.user._id);
    return res.status(200).json({
        success: true,
        statusCode: 200
    });
});

/**
 * @method - GET
 * @desc - Get All Favourited Post
 * @access - PRIVATE
 */
exports.favPosts = asyncHandler(async (req, res, next) => {
    const posts = await Post.find({
        likes: {
            $elemMatch: { $eq: req.user._id }
        }
    }).populate('_creator');

    return res.status(200).json({
        success: true,
        statusCode: 200,
        data: posts
    });
});

/**
 * @method - GET
 * @desc - Get All Self Created Posts
 * @access - PRIVATE
 */
exports.getMyPosts = asyncHandler(async (req, res, next) => {
    return res.status(200).json(res.advancedResults);
});