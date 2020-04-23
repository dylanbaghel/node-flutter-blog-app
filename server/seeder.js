const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');

const User = require('./models/User');
const Post = require('./models/Post');

(async () => {
    await mongoose.connect(process.env.MONGO_URI, {
        useCreateIndex: true,
        useFindAndModify: false,
        useNewUrlParser: true,
        useUnifiedTopology: true
    });
})();

const users = JSON.parse(fs.readFileSync(path.join(__dirname, '_data', 'users.json')));
const posts = JSON.parse(fs.readFileSync(path.join(__dirname, '_data', 'posts.json')));

const importData = async () => {
    await User.create(users);
    await Post.create(posts);
    console.log('Data Imported....');
    process.exit();
}

const destroyData = async () => {
    await User.deleteMany();
    await Post.deleteMany();
    console.log('Data Destroyed......');
    process.exit();
};

if (process.argv[2] === 'i') {
    importData();
} else if (process.argv[2] === 'd') {
    destroyData();
} else {
    console.log('Invalid Parameter');
    process.exit();
}

