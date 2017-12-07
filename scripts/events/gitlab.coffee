path = require 'path'
natural = require 'natural'

GITLAB_URL =  msg.robot.brain.get('configure_gitlab-url_'+msg.envelope.room) ? (process.env.GITLAB_URL || 'https://gitlab.com')
GITLAB_TOKEN = msg.robot.brain.get('configure_gitlab-token_'+msg.envelope.room) ? (process.env.GITLAB_TOKEN || null )

msg.robot.logger.debug "GITLAB_URL=" + GITLAB_URL
msg.robot.logger.debug "GITLAB_TOKEN=" + GITLAB_TOKEN

gitlab = {}
gitlab[msg.envelope.room] = require('gitlab')(
  url: GITLAB_URL,
  token: GITLAB_TOKEN)

GITLAB_PROJECT =  msg.robot.brain.get('configure_gitlab-project_'+msg.envelope.room) ? (process.env.GITLAB_PROJECT || null)

{msgVariables, stringElseRandomKey} = require path.join '..', 'lib', 'common.coffee'
answers = {}

class gitlab
  constructor: (@interaction) ->
  process: (msg) =>
    # check for permission role

    if msg.robot.brain.get('configure_role_'+msg.envelope.room) !== null
			if checkRole(robot.brain.get('configure_role_'+msg.envelope.room), msg.message.user.name) || checkRole('admin', msg.message.user.name)
				msg.robot.logger.debug "ACCESS GRANTED"
			else
				msg.robot.logger.debug "ACCESS DENIED"
				return msg.reply "`Access Denied!`"

    # Check for gitlab_token gitlab_url in room
    if !msg.robot.brain.get('configure_gitlab-token_' + msg.envelope.room)
      return msg.reply setGitlabToken()

    # Check action and call specified method
    action = @interaction.action?.toLowerCase() or 'project-list'
    switch action
      when 'project-list'
        # call method to render response
        result = renderProjects()
      when 'milestone-list'
        # call method to render response
        if GITLAB_PROJECT then result = renderMilestones() else msg.reply setGitlabProject()
      when 'issue-list'
        # call method to render response
        if GITLAB_PROJECT then result = renderIssues() else msg.reply setGitlabProject()
      when 'pipeline-list'
        # call method to render response
        if GITLAB_PROJECT then result = renderPipelines() else msg.reply setGitlabProject()
      when 'build-list'
        # call method to render response
        if GITLAB_PROJECT then result = renderBuilds() else msg.reply setGitlabProject()
      when 'user-list'
        # call method to render response
        if GITLAB_PROJECT then result = renderUsers() else msg.reply setGitlabProject()
      when 'variable-list'
        # call method to render response
        if GITLAB_PROJECT then result = renderVariables() else msg.reply setGitlabProject()

    # Returns messages
        type = @interaction.type?.toLowerCase() or 'random'
        switch type
          when 'block'
            messages = @interaction.answer.map (line) ->
              return msgVariables line, msg, {result:result}
            msg.sendWithNaturalDelay messages
          when 'random'
            message = stringElseRandomKey @interaction.answer
            message = msgVariables message, msg, {result:result}
            msg.sendWithNaturalDelay message

  # limitResult = (msg, result) ->
  #   if res.params.limit > 0
  #     return result.slice(0, res.params.limit)
  #   result

  setGitlabProject = ->
    robot_name = msg.robot.alias or msg.robot.name
    'Use `#{robot_name} config gitlab-project=PROJECT_ID` to set default project'

  setGitlabToken = ->
    robot_name = msg.robot.alias or msg.robot.name
    'Use `#{robot_name} config gitlab-token=GITLAB_ACCESS_KEY` to set gitlab\'s access key'

  setGitlabUrl = ->
    robot_name = msg.robot.alias or msg.robot.name
    'Use `#{robot_name} config gitlab-url=https://gitlab.mydomain.com` to set gitlab\'s server URL'

  # Renders

  renderProjects = () ->
    found = false
    gitlab[msg.envelope.room].projects.all -> (records)
      records.forEach (item) ->
        result += '\n#{item.id} - #{item.path_with_namespace}'
        if String(item.id) == String(GITLAB_PROJECT)
          found = true
          result += ' - **default**'
      if found == false
        result += '\n\n' + setGitlabProject()
      return result

  renderUsers = (res, msg, records) ->
    initialLength = msg.length
    found = false
    _.forEach limitResult(res, records), (item) ->
      msg += '\n#{item.id} - #{item.username} - #{item.name}'
      return
    if msg.length <= initialLength
      msg += '\n **No users found in this project**'
    msg

  renderMilestones = (res, msg, records) ->
    initialLength = msg.length
    _.forEach limitResult(res, records), (item) ->
      msg += '\n#{item.iid} - #{item.title}'
      if item.state == 'closed'
        msg += ' **CLOSED**'
      return
    if msg.length <= initialLength
      msg += '\n **No milestones found in this project**'
    msg

  renderIssues = (res, msg, records) ->
    initialLength = msg.length
    _.forEach limitResult(res, records), (item) ->
      msg += '\n#{item.iid} - #{item.title}'
      if item.state == 'closed'
        msg += ' **CLOSED**'
      return
    if msg.length <= initialLength
      msg += '\n **No issues found in this project**'
    msg

  renderPipelines = (res, msg, records) ->
    initialLength = msg.length
    _.forEach limitResult(res, records), (item) ->
      msg += '\n- #{item.id} - #{item.ref} - **#{item.status}**'
      return
    if msg.length <= initialLength
      msg += '\n **No pipelines found in this project**'
    msg

  renderBuilds = (res, msg, records) ->
    initialLength = msg.length
    _.forEach limitResult(res, records), (item) ->
      msg += '\n- #{item.id} - #{item.name} (stage: #{item.stage}, branch: #{item.ref}) - **#{item.status}**'
      return
    robot.logger.info '[DEBUG] renderBuilds On! msg= ' + msg + ' length:' + msg.length
    if msg.length <= initialLength
      msg += '\n **No builds found in this project**'
    msg

  renderVariables = (res, msg, records) ->
    initialLength = msg.length
    _.forEach limitResult(res, records), (item) ->
      msg += '\n- #{item.id} - #{item.name} (stage: #{item.stage}, branch: #{item.ref}) - **#{item.status}**'
      return
    robot.logger.info '[DEBUG] renderBuilds On! msg= ' + msg + ' length:' + msg.length
    if msg.length <= initialLength
      msg += '\n **No builds found in this project**'
    msg




module.exports = configure
