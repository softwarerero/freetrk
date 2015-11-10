#Template.projects.helpers
#  projects: () -> Projects.find({}, {sort: {name: 1}})
#menu
Template.menu.onRendered () ->
  login = document.getElementById 'login-buttons'
  login?.className += " signIn"

Template.ifLoggedIn.helpers
  authInProcess: -> Meteor.loggingIn()
  canShow: -> !!Meteor.user()

#Template.login.helpers
#  defaultCredentials: -> Config.defaultCredentials

Template.login.events
  'click .signIn': (event, template) ->
    event.preventDefault()
    email = template.find '.email'
    password = template.find '.password'
    Meteor.loginWithPassword email.value, password.value, (error) ->
      FlowRouter.go '/'
  