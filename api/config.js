const devConf = require('./dev.config');

const clientId = process.env.CLIENT_ID || devConf.clientId;
const clientSecret = process.env.CLIENT_SECRET || devConf.clientSecret;
const refreshToken = process.env.REFRESH_TOKEN || devConf.refreshToken;

module.exports = {
    clientId,
    clientSecret,
    refreshToken
};