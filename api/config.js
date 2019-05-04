const clientId = process.env.CLIENT_ID || '';
const clientSecret = process.env.CLIENT_SECRET || '';
const refreshToken = process.env.REFRESH_TOKEN || '';

module.exports = {
    clientId,
    clientSecret,
    refreshToken
};