const pluck = (obj, ...keys) => {
    let newObj = {};
    keys.forEach((key) => {
        if (obj[key]) {
            newObj[key] = obj[key];
        }
    });
    return newObj;
};

module.exports = pluck;