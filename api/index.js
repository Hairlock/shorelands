const express = require('express');
const { check, validationResult }
    = require('express-validator/check');
const bodyParser = require('body-parser');
const cors = require('cors');
const jsonDB = require('node-json-db');
const fs = require('fs');

const db = new jsonDB("properties", true, false);
const port = process.env.PORT || 5000;

const app = express();
app.use(cors());
app.use(bodyParser.json());
app.use(express.static('public'));


app.get('/api/properties', (req, res) => {
    let category = req.query.category;
    let data = db.getData('/properties');
    if (category == null || category === 'all')
        res.send(data.map(setImagesOnProp));
    else
        res.send(data
            .filter(p => p.category === category)
            .map(setImagesOnProp));
});

function setImagesOnProp(prop) {
    try {
        prop.images = fs.readdirSync(`./public/images/${prop.slug}`);
    } catch (err) {
        prop.images = [];
    }

    return prop;
}

app.get('/api/property', (req, res) => {
    let slug = req.query.slug;
    let data = db.getData('/properties');
    if (slug == null)
        res.status(400).send('Provide slug parameter');
    else {
        let prop = data.find(p => p.slug === slug);
        if (prop == null)
            res.status(400).send('Invalid slug parameter')
        else {
            res.send(setImagesOnProp(prop));
        }
    }
});

app.get('/api/slugs', (req, res) => {
    let slugs = db.getData('/properties').map(p => ({ slug: p.slug, category: p.category }));
    res.send(slugs);
});

app.post('/api/enquiry', [
    check('email').isEmail().normalizeEmail(),
    check('title').trim().escape(),
    check('message').trim().escape()
], (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty())
        return res.send(422).json({ errors: errors.array() })

    let title = req.body.title,
        email = req.body.email,
        message = req.body.message;

    console.log(title);
    console.log(email);
    console.log(message);

    res.send({ success: true });

});

app.listen(port, err => {
    if (err)
        console.log(`error: ${err}`);

    console.log(`Listening on port: ${port}`);
});