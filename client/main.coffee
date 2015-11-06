#Template.projects.helpers
#  projects: () -> Projects.find({}, {sort: {name: 1}})
#menu
Template.menu.onRendered () ->
  login = document.getElementById 'login-buttons'
  login?.className += " signIn"