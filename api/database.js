const jsonDb = require('node-json-db');

const db = new jsonDb("properties", true, false);

module.exports = {
    db
}