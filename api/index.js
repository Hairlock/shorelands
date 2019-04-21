const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const jsonDB = require('node-json-db');
const path = require('path');

const db = new jsonDB("properties", true, false);
const port = process.env.PORT || 5000;

const app = express();
app.use(cors());
app.use(bodyParser.json());
app.set('view engine', 'pug');
app.set('views', path.join(__dirname, 'dist/views'))

app.get('/', (req, res) => {
    const props = db.getData('/properties');
    var property = props[0];

    res.render('homepage', {
        property: property
    });
});

app.get('/api/properties', (req, res) => {
    res.send(db.getData('/properties'));
});

app.get('/api/slugs', (req, res) => {
    let slugs = db.getData('/properties').map(p => ({ slug: p.slug, category: p.category }));
    res.send(slugs);
})

app.listen(port, err => {
    if (err)
        console.log(`error: ${err}`);

    console.log(`Listening on port: ${port}`);
});