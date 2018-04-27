// require('coffeescript/register');

const { loadConfigfile, getConfigFilePath } = require('./lib/common');
let chatbot = require('./bot/index');

try {
  global.config = loadConfigfile(getConfigFilePath());
} catch (err) {
  process.exit();
}

chatbot = chatbot.bind(null, global.config);

module.exports = chatbot;
