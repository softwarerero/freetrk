Template.timetracks.helpers
  timetracks: () ->
    Timetrack.find({}, {sort: {date: -1, from: -1}})
  projectName: (_id) ->
    project = Projects.findOne {_id: _id}
    project?.name

Template.timetracks.events
  'click .fa-plus': (event, template) ->
    FlowRouter.go '/timetrack/new'
  'click .edit': (event, template) ->
    _id = event.currentTarget.parentNode.parentNode.getAttribute 'id'
    FlowRouter.go "/timetrack/#{_id}"
  'click .remove': (event, template) ->
    _id = event.currentTarget.parentNode.parentNode.getAttribute 'id'
    Timetrack.remove {_id: _id}
  'click .odt': (event, template) ->
    event.preventDefault()
    Meteor.call 'printTimesheet'
#    FlowRouter.go '/timetrack/new'

Template.timetrack.onRendered ->
  $('#from').datetimepicker dateTimePickerOptions
  $('#to').datetimepicker dateTimePickerOptions
  _id = FlowRouter.getParam('_id')
  setDateAndTime _id
  
setDateAndTime = (_id) ->
  console.log 'setDateAndTime'
  if 'new' == _id
    now = new Date()
    $('#from').datetimepicker {value: now}
    $('#to').datetimepicker {value: now}
  else
    track = Timetrack.findOne {_id: _id}
    $('#from').datetimepicker {value: track.from}
    $('#to').datetimepicker {value: track.to}

Template.timetrack.helpers
  timetrack: () ->
    _id = FlowRouter.getParam('_id')
    setDateAndTime _id
    if 'new' == _id
      track =
        billable: 'checked'
        project: Session.get 'lastProject'
      return track
    Timetrack.findOne {_id: _id}
  projects: () ->
#    console.log Projects.find({}, {sort: {name: 1}})
    Projects.find({}, {sort: {name: 1}})
  isSelected: (project) ->
    _id = FlowRouter.getParam('_id')
    if 'new' is _id
      Session.get('lastProject') is project
    else
      timetrack = Timetrack.findOne {_id: _id}
      timetrack.project == project

Template.timetrack.events
  'change #from': (event, template) ->
    dateChanged template
  'change #to': (event, template) ->
    dateChanged template
  'change #time': (event, template) ->
    timeChanged template
  'click .save': (event, template) ->
    event.preventDefault()
    _id = template.find('#_id').value
    momentFrom = moment(from.value, Config.dateTimeFormat)
    momentTo = moment(to.value, Config.dateTimeFormat)
    time = momentTo.diff(momentFrom, 'hours', true)
    timetrack =
      from: momentFrom.toDate()
      to: momentTo.toDate()
      time: time
      project: template.find('#project').value
      feature: template.find('#feature').value
      task: template.find('#task').value
      billable: template.find('#billable').checked
      userId: Meteor.userId()
    try 
      check timetrack,
        from: Date
        to: Match.Optional(Date)
        time: Match.Optional(Number)
        project: NonEmptyString
        feature: Match.Optional(String)
        task: Match.Optional(String)
        billable: Boolean
        userId: String
#    console.log 'timetrack: ' + JSON.stringify timetrack
      SUCCESS 'You worked!'
      Timetrack.upsert {_id: _id}, timetrack
      FlowRouter.go '/timetrack/new'
    catch error
      ERROR error

dateChanged = (template) ->
  from = template.find('#from').value
  to = template.find('#to').value
  if from && to
    from = moment(from, Config.dateTimeFormat)
    to = moment(to, Config.dateTimeFormat)
    newTime = to.diff from, 'minutes'
    newTime = newTime / 60
    newTime = newTime.toFixed 2
    time = template.find '#time'
    time.value = newTime

timeChanged = (template) ->
  time = template.find('#time').value
  unless time then return
  from = template.find('#from').value
  to = template.find('#to').value
  if from
    from = moment(from, Config.dateTimeFormat)
    toValue = from.add time * 60, 'minutes'
    toValue = toValue.format Config.dateTimeFormat
    template.find('#to').value = toValue
  else if to
    to = moment(to, Config.dateTimeFormat)
    fromValue = to.subtract time * 60, 'minutes'
    fromValue = fromValue.format Config.dateTimeFormat
    template.find('#from').value = fromValue

  
#  'click .fa-plus': (event, template) ->
#    FlowRouter.go '/admin/project'
#  'click .edit': (event, template) ->
#    _id = event.currentTarget.parentNode.parentNode.getAttribute 'id'
#    FlowRouter.go "/admin/project/#{_id}"
#  'click .remove': (event, template) ->
#    _id = event.currentTarget.parentNode.parentNode.getAttribute 'id'
#    Projects.remove {_id: _id}

