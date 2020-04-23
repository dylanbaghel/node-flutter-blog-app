const mongoose = require('mongoose');

module.exports = async () => {
    const conn = await mongoose.connect(process.env.MONGO_URI, {
        useCreateIndex: true,
        useFindAndModify: false,
        useNewUrlParser: true,
        useUnifiedTopology: true
    });
    console.log(`Mongo UP In Mode: ${conn.connection.host} - At PORT: ${conn.connection.port}`);
}