/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const actionHandler = {};

const fs = require('fs');
const path = require('path');

const actionsPath = path.join(__dirname, '..', 'actions');
const actions = {};

const nodes = {};
let err_nodes = 0;

actionHandler.registerActions = function(config) {
  for (var action of Array.from(fs.readdirSync(actionsPath).sort())) {
    const action_name = action.replace(/\.js$/, '');
    actions[action_name] = require(path.join(actionsPath, action));
  }

  return (() => {
    const result = [];
    for (let interaction of Array.from(config.interactions)) {
      var name;
      ({ name, action } = interaction);
      nodes[name] = new (actions[action])(interaction);

      if (name.substr(0, 5) === "error") {
        result.push(err_nodes++);
      } else {
        result.push(undefined);
      }
    }
    return result;
  })();
};

actionHandler.errorNodesCount = () => err_nodes;

actionHandler.takeAction = (name, res) => nodes[name].process(res);

module.exports = actionHandler;
