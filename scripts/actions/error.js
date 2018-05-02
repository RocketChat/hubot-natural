/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// require('coffeescript/register');

const { msgVariables, stringElseRandomKey } = require('../lib/common');

class Error {
  constructor(interaction) {
    this.process = this.process.bind(this);
    this.interaction = interaction;
  }
  process(msg) {
    const type = (this.interaction.type != null ? this.interaction.type.toLowerCase() : undefined) || 'random';
    switch (type) {
      case 'block':
        var messages = this.interaction.answer.map(line => msgVariables(line, msg));
        return msg.sendWithNaturalDelay(messages);
      case 'random':
        var message = stringElseRandomKey(this.interaction.answer);
        message = msgVariables(message, msg);
        return msg.sendWithNaturalDelay(message);
    }
  }
}

module.exports = Error;
