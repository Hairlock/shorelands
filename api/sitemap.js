const { db } = require('./database'),
    sm = require('sitemap');

const lastMod = new Date().toISOString().split('T')[0];

const routeUrls = [
    { url: '', changefreq: 'yearly', priority: 0.8, lastmod: lastMod },
    { url: '/properties/homes', changefreq: 'yearly', priority: 0.9, lastmod: lastMod },
    { url: '/properties/land', changefreq: 'yearly', priority: 0.9, lastmod: lastMod },
    { url: '/properties/all', changefreq: 'yearly', priority: 0.9, lastmod: lastMod }
]

const propertyUrls = db.getData('/properties')
    .map(p => {
        return {
            url: `/property/${p.slug}`,
            changefreq: 'weekly',
            priority: 1,
            lastmod: lastMod
        }
    });

const sitemap = sm.createSitemap({
    hostname: 'https://www.shorelandsrealestate.com',
    urls: routeUrls.concat(propertyUrls)
});

module.exports = {
    sitemap
}

