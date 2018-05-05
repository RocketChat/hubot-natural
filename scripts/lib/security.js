const security = {};

security.getUserRoles = async function(robot) {
  const usersAndRoles = {};
  try {
    const users = await robot.adapter.callMethod('getUserRoles');
    users.forEach(function(user) {
      user.roles.forEach(function(role) {
        if (typeof usersAndRoles[role] === 'undefined') {
          usersAndRoles[role] = [];
        }
        usersAndRoles[role].push(user.username);
      })
    })
  }catch(err){
    console.log(err);
  }
  return usersAndRoles;
};


security.checkRole = function(msg, role) {
  if (typeof global.usersAndRoles[role] !== 'undefined') {
    if (global.usersAndRoles[role].indexOf(msg.envelope.user.name) === -1) {
      return false;
    } else {
      return true;
    }
  } else {
    msg.robot.logger.info(`Role ${role} not found`);
    return false;
  }
};

module.exports = security;
