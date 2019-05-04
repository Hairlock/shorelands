const { db } = require('./database'),
    sm = require('sitemap');

const routeUrls = [
    { url: '', changefreq: 'yearly', priority: 0.8 },
    { url: '/properties/homes', changefreq: 'yearly', priority: 0.9 },
    { url: '/properties/land', changefreq: 'yearly', priority: 0.9 },
    { url: '/properties/all', changefreq: 'yearly', priority: 0.9 }
]

const propertyUrls = db.getData('/properties')
    .map(p => {
        return { url: `/property/${p.slug}`, changefreq: 'weekly', priority: 1 }
    });

const sitemap = sm.createSitemap({
    hostname: 'https://www.shorelandsrealestate.com',
    urls: routeUrls.concat(propertyUrls)
});

module.exports = {
    sitemap
}

