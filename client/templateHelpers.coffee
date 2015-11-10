Template.registerHelper 'appName', ->
  Config.appName

Template.registerHelper 'formatDate', (date) ->
  moment(date).format 'MM/DD/YYYY'

Template.registerHelper 'isUser', ->
  !!Meteor.user()