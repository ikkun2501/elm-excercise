require('./index.html');


const Elm = require('./App.elm');
const mountNode = document.getElementById('main');

const app = Elm.App.embed(mountNode);