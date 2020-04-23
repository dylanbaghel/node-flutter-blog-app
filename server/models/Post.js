const mongoose = require('mongoose');
const slugify = require('slugify');

const { ImageSchema } = require('./sub-schema/Image');

const PostSchema = new mongoose.Schema({
    title: {
        type: String,
        required: [true, "Title is Required"],
        minlength: [6, "Title is Too Short"],
        maxlength: [150, "Title is Too Long"]
    },
    body: {
        type: String,
        required: [true, "Post Body is Required"],
        minlength: [20, "Post Body is Too Short"]
    },
    image: {
        type: ImageSchema,
        required: true
    },
    published: {
        type: Boolean,
        default: true
    },
    slug: String,
    createdAt: {
        type: Date,
        default: Date.now
    },
    likes: [
        { type: mongoose.Schema.Types.ObjectId, ref: 'User' }
    ],
    _creator: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
    }
}, {
    toJSON: { virtuals: true },
    toObject: { virtuals: true }
});

PostSchema.virtual('id', function () {
    this._id.toString();
});

PostSchema.methods.toggleLike = async function (userId) {
    const isAlreadyLikedIndex = this.likes.findIndex((like) => like.toString() === userId.toString());

    if (isAlreadyLikedIndex > -1) {
        this.likes.splice(isAlreadyLikedIndex, 1);
    } else {
        this.likes.push(userId);
    }

    await this.save();
}


PostSchema.pre('save', function () {
    if (this.isModified('title')) {
        this.slug = slugify(this.title, {
            replacement: '-',
            lower: true,
            strict: true
        });
    }
});

module.exports = mongoose.model('Post', PostSchema);