Template.timetracks.helpers
  timetracks: () ->
    Timetrack.find({}, {sort: {date: -1, from: -1}})
  projectName: (_id) ->
    project = Projects.findOne {_id: _id}
#    console.log 'project: ' + JSON.stringify project
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
  'click .pdf': (event, template) ->
    event.preventDefault()
    Meteor.call 'printTimesheet'
#    FlowRouter.go '/timetrack/new'

Template.timetrack.onRendered ->
  $('#date').datetimepicker datePickerOptions
  $('#from').datetimepicker timePickerOptions
  $('#to').datetimepicker timePickerOptions
  
Template.timetrack.helpers
  timetrack: () ->
    _id = FlowRouter.getParam('_id')
    if 'new' == _id
      now = moment()
      track =
        billable: 'checked'
        date: now.format(Config.dateFormat)
        from: now.format(Config.timeFormat)
        to: now.format(Config.timeFormat)
        project: Session.get 'lastProject'
#      console.log JSON.stringify track
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
  'click .save': (event, template) ->
    event.preventDefault()
    _id = template.find('#_id').value
    timetrack =
      date: template.find('#date').value
      from: template.find('#from').value
      to: template.find('#to').value
      project: template.find('#project').value
      feature: template.find('#feature').value
      task: template.find('#task').value
      billable: template.find('#billable').checked
    momentFrom = moment timetrack.to, Config.timeFormat
    momentTo = moment timetrack.from, Config.timeFormat
    console.log 'time: ' + momentTo.subtract(momentFrom).format(Config.timeFormat)
    timetrack.time = momentTo.subtract(momentFrom).format(Config.timeFormat)
#    console.log 'timetrack: ' + JSON.stringify timetrack
    check timetrack,
      date: NonEmptyString
      from: NonEmptyString
      to: Match.Optional(String)
      project: NonEmptyString
      feature: Match.Optional(String)
      task: Match.Optional(String)
      time: Match.Optional(String)
      billable: Boolean
    Timetrack.upsert {_id: _id}, timetrack
    FlowRouter.go '/timetrack/new'
#    FlowRouter.go '/admin/projects'

#  'click .fa-plus': (event, template) ->
#    FlowRouter.go '/admin/project'
#  'click .edit': (event, template) ->
#    _id = event.currentTarget.parentNode.parentNode.getAttribute 'id'
#    FlowRouter.go "/admin/project/#{_id}"
#  'click .remove': (event, template) ->
#    _id = event.currentTarget.parentNode.parentNode.getAttribute 'id'
#    Projects.remove {_id: _id}

