/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// require('coffeescript/register');

const classifier = require('../bot/classifier');
const security = require('../lib/security');
const { msgVariables, stringElseRandomKey,
  loadConfigfile, getConfigFilePath } = require('../lib/common');

class Configure {
  constructor(interaction) {
    this.process = this.process.bind(this);
    this.interaction = interaction;
  }

  process(msg) {
    if (this.interaction.role != null) {
      if (security.checkRole(msg, this.interaction.role)) {
        return this.act(msg);
      } else {
        return msg.sendWithNaturalDelay(
          `*Acces Denied* Action requires role ${this.interaction.role}`
        );
      }
    } else {
      return this.act(msg);
    }
  }

  setVariable(msg) {
    const raw_message = msg.message.text.replace(msg.robot.name + ' ', '');
    const configurationBlock = raw_message.split(' ').slice(-1).toString();

    const configKeyValue = configurationBlock.split('=');
    const configKey = configKeyValue[0];
    const configValue = configKeyValue[1];

    const key = `configure_${configKey}_${msg.envelope.room}`;
    msg.robot.brain.set(key, configValue);

    const type = (this.interaction.type != null ? this.interaction.type.toLowerCase() : undefined) || 'random';

    switch (type) {
      case 'block':
        var messages = this.interaction.answer.map(line => msgVariables(line, msg, { key: configKey, value: configValue }));
        msg.sendWithNaturalDelay(messages);
        break;
      case 'random':
        var message = stringElseRandomKey(this.interaction.answer);
        message = msgVariables(message, msg, {
          key:   configKey,
          value: configValue
        });
        msg.sendWithNaturalDelay(message);
        break;
    }
  }

  retrain(msg) {
    global.config = loadConfigfile(getConfigFilePath());
    classifier.train();

    const type = (this.interaction.type != null ? this.interaction.type.toLowerCase() : undefined) || 'random';
    switch (type) {
      case 'block':
        var messages = this.interaction.answer.map(line => msgVariables(line, msg));
        msg.sendWithNaturalDelay(messages);
        break;
      case 'random':
        var message = stringElseRandomKey(this.interaction.answer);
        message = msgVariables(message, msg);
        msg.sendWithNaturalDelay(message);
        break;
    }
  }

  act(msg) {
    const command = this.interaction.command || 'setVariable';
    console.log(command);
    switch (command) {
      case 'setVariable':
        this.setVariable(msg);
        break;
      case 'train':
        this.retrain(msg);
        break;
    }
  }
}

module.exports = Configure;
