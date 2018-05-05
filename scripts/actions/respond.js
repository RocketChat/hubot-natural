/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// require('coffeescript/register');

const { msgVariables, stringElseRandomKey } = require('../lib/common');

const livechat_department = (process.env.LIVECHAT_DEPARTMENT_ID || null);

class Respond {
  constructor(interaction) {
    this.process = this.process.bind(this);
    this.interaction = interaction;
  }
  process(msg) {
    const lc_dept = this.interaction.department || livechat_department;
    const offline_message = (
      this.interaction.offline || 'Sorry, there is no online agents to transfer to.'
    );
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

    const command = (this.interaction.command != null ? this.interaction.command.toLowerCase() : undefined) || false;
    switch (command) {
      case 'transfer':
        return this.livechatTransfer(msg, 3000, lc_dept, offline_message, type);
    }
  }

  livechatTransfer(msg, delay, lc_dept, offline_message, type) {
    if (delay == null) { delay = 3000; }
    async function getResult() {
      try {
        let result = await msg.robot.adapter.callMethod('livechat:transfer', {
          roomId: msg.envelope.room,
          department: lc_dept
        });
      } catch (err) {
        console.log(err);
      }
      if (result === true) {
        return console.log('livechatTransfer executed!');
      } else {
        switch (type) {
          case 'block':
            var messages = offline_message.map(line => msgVariables(line, msg));
            return msg.sendWithNaturalDelay(messages);
          case 'random':
            var messages = offline_message.map(line => msgVariables(line, msg));
            var message = stringElseRandomKey(offline_message);
            message = msgVariables(message, msg);
            return msg.sendWithNaturalDelay(message);
        }
      }
    }
    return setTimeout(getResult(), delay);
  }
}

module.exports = Respond;
