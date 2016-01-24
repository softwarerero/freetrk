Template.registerHelper 'appName', ->
  Config.appName

Template.registerHelper 'formatDate', (date) ->
#  console.log 'formatDate'
  unless date then return ''
  moment(date).format Config.dateFormat

Template.registerHelper 'formatDateTime', (date) ->
#  console.log 'formatDateTime'
  unless date then return ''
  moment(date).format Config.dateTimeFormat

Template.registerHelper 'formatIndustrialTime', (number) ->
#  console.log 'formatIndustrialTime: ' + typeof number
  if number
    number.toFixed 2

Template.registerHelper 'formatMoney', (number) ->
#  console.log 'formatMoney'
  if number
    '$' + number.toFixed 2

Template.registerHelper 'isUser', ->
#  console.log 'isUser'
  !!Meteor.user()

  
# Toastr
Meteor.startup ->
  toastr.options.positionClass = "toast-top-right"
  toastr.options.progressBar = true
  
@SUCCESS = (msg, title='') -> toastr.success(msg, title)
@INFO = (msg, title='') -> toastr.info(msg, title)
@WARN = (msg, title='') -> toastr.warning(msg, title)

@ERROR = (msg, title='') ->
#  console.log msg
  toastr.error(msg, title)


#@tdateToMoment = (tdate) -> moment tdate + ' +0000', Config.dateTimeFormat + ' Z'
@tdateToMoment = (tdate) -> moment tdate, Config.dateTimeFormat + ' Z'
  