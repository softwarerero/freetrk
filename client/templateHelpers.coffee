Template.registerHelper 'appName', ->
  Config.appName

Template.registerHelper 'formatDateTime', (date) ->
  moment(date).format Config.dateTimeFormat

Template.registerHelper 'formatIndustrialTime', (number) ->
  number.toFixed 2

Template.registerHelper 'isUser', ->
  !!Meteor.user()


  
# Toastr
Meteor.startup ->
  toastr.options.positionClass = "toast-top-full-width"
  toastr.options.progressBar = true
  
@SUCCESS = (msg, title='') -> toastr.success(msg, title)
@INFO = (msg, title='') -> toastr.info(msg, title)
@WARN = (msg, title='') -> toastr.warning(msg, title)

@ERROR = (msg, title='') ->
#  console.log msg
  toastr.error(msg, title)


