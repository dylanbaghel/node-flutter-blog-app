const { asyncHandler } = require('./asyncHandler');

exports.advancedResults = (model, populate, condition = {}, auth = false) => asyncHandler(async (req, res, next) => {
    if (auth) {
        condition._creator = req.user._id;
    }
    let query = model.find(condition);

    if (populate) {
        query = query.populate(populate);
    }

    // Select
    if (req.query.select) {
        const fields = req.query.select.split(",").join(" ");
        query = query.select(fields);
    }

    // Sorting
    if (req.query.sortBy) {
        query = query.sort(req.query.sortBy);
    } else {
        query = query.sort('-createdAt');
    }

    // Pagination
    let page = Math.abs(parseInt(req.query.page)) || 1;
    let limit = Math.abs(parseInt(req.query.size)) || 10;
    let skip = (page - 1) * limit;
    const totalDocuments = await model.countDocuments(condition);
    const totalPages = Math.ceil(totalDocuments / limit);

    query = query.skip(skip).limit(limit);

    const data = await query;

    const pagination = {
        currentPage: page,
        totalDocuments,
        totalPages,
        count: data.length
    };

    if (totalPages > 1 && page < totalPages) {
        pagination.next = page + 1;
    }
    if (page > 1) {
        pagination.prev = page - 1;
    }
    res.advancedResults = {
        success: true,
        statusCode: 200,
        pagination,
        data
    };
    next();
});