'use strict';

require("./assets/styles/index.scss");

const { Elm } = require('./Main');

var app = Elm.Main.init({ flags: 6 });

// app.ports.toJs.subscribe(data => {
//     console.log(data);
// })
