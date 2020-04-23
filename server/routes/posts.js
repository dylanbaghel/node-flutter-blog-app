// Third Party Modules
const router = require('express').Router();

// Custom Module Files
const {
    createPost,
    getAllPosts,
    updatePost,
    deletePost,
    getSinglePost,
    toggleLikePost,
    favPosts,
    getMyPosts
} = require('../controller/posts');
const { authenticate, getUserId } = require('../middlewares/authenticate');
const { advancedResults } = require('../middlewares/advancedResults');
const { postImageUpload } = require('../utils/multer-cloudinary');
const Post = require('../models/Post');
// Routes
router
    .route('/')
    .post(authenticate, postImageUpload.single('image'), createPost)
    .get(advancedResults(Post, '_creator', { published: true }), getAllPosts);
router
    .get('/fav', authenticate, favPosts);
router.get('/my', authenticate, advancedResults(Post, '_creator', {}, true), getMyPosts);
router
    .route('/:id')
    .patch(authenticate, postImageUpload.single('image'), updatePost)
    .delete(authenticate, deletePost)
    .get(getUserId, getSinglePost);
router
    .put('/:id/like', authenticate, toggleLikePost);
// Export Router
module.exports = router;