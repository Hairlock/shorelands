const nodemailer = require('nodemailer'),
    { google } = require('googleapis'),
    { clientId, clientSecret, refreshToken } = require('./config');
OAuth2 = google.auth.OAuth2;


const oauth2Client = new OAuth2(
    clientId,
    clientSecret,
    "https://developers.google.com/oauthplayground"
);


oauth2Client.setCredentials({
    refresh_token: refreshToken
});

module.exports = {
    sendMail
}



function sendMail(title, email, message) {
    oauth2Client.getRequestHeaders()
        .then(h => {
            let accessToken = h.Authorization.split(' ').pop();

            if (accessToken == null) {
                console.err('Access token could not be fetched');
                return null;
            }

            const smtpTransport = nodemailer.createTransport({
                service: "gmail",
                auth: {
                    type: "OAuth2",
                    user: "shorelandsrealestate@gmail.com",
                    clientId: clientId,
                    clientSecret: clientSecret,
                    refreshToken: refreshToken,
                    accessToken: accessToken
                }
            });

            const mailOptions = (to) => {
                return {
                    from: "shorelandsrealestate@gmail.com",
                    to: to,
                    subject: title,
                    generateTextFromHTML: true,
                    html: `<h3>From: ${email}</h1><br /><p>Message: ${message}</p>`
                }
            };

            ["yannseal1@gmail.com"]
                .map(to => {
                    smtpTransport.sendMail(mailOptions(to), (err, res) => {
                        error ? console.log(err) : console.log(res);
                        smtpTransport.close();
                    });
                });
        });
}


