Template.timetracks.onRendered ->
  $('#projects').select2()
  $('#from').datetimepicker dateTimePickerOptions
  $('#to').datetimepicker dateTimePickerOptions
  momentFrom = moment(from.value, Config.dateTimeFormat)
  Session.set 'timetracks', null
  Session.set 'timetracksSum', null
  Meteor.call 'getTimetracks', getTimetrackQuery(), (error, timetracks) ->
    if error then return LOGJ 'error', error
    Session.set 'timetracks', timetracks
    sum = _.reduce timetracks, ((memo, tt) -> memo + tt.time), 0
    sum = Math.round(sum * 100) / 100
    if sum then Session.set 'timetracksSum', "(#{sum})"


getTimetrackQuery = ->
  projects = FlowRouter.getQueryParam 'projects'
  query = if projects then {projectId: {$in: projects}} else {}
  from = FlowRouter.getQueryParam 'from'
  if from
    from = moment from, 'X'
    query.from = {$gte: from.toDate()}
  to = FlowRouter.getQueryParam 'to'
  if to
    to = moment to, 'X'
    query.to = {$lte: to.toDate()}
  query
  
Template.timetracks.helpers
  timetracks: () -> Session.get 'timetracks' 
  sum: () -> Session.get 'timetracksSum'
  projectName: (_id) ->
    project = Projects.findOne {_id: _id}
    project?.name
  projects: () -> Projects.find({}, {sort: {name: 1}})
  isSelected: (projectId) ->
    projects = FlowRouter.getQueryParam 'projects'
    projects && (projectId in projects)
  firstOfMonth: ->
    from = FlowRouter.getQueryParam 'from'
    if from
      from = moment from, 'X'
      from.format(Config.dateTimeFormat)
  lastOfMonth: ->
    to = FlowRouter.getQueryParam 'to'
    if to
      to = moment to, 'X'
      to.format(Config.dateTimeFormat)

Template.timetracks.events
  'click .fa-plus': (event, template) ->
    FlowRouter.go '/timetrack/new'
  'click .edit': (event, template) ->
    _id = event.currentTarget.parentNode.parentNode.getAttribute 'id'
    FlowRouter.go "/timetrack/#{_id}"
  'click .remove': (event, template) ->
    if confirm "Are you sure?"
      _id = event.currentTarget.parentNode.parentNode.getAttribute 'id'
    Timetrack.remove {_id: _id}
  'click .printTimesheet': (event, template) ->
    event.preventDefault()
    moment(from.value, Config.dateTimeFormat)
    params =
      projects: FlowRouter.getQueryParam 'projects'
      from: FlowRouter.getQueryParam 'from'
      to: FlowRouter.getQueryParam 'to'
    Meteor.call 'printTimesheet', params, (error, data) ->
#      if data
#        window.open(data.url)
#        window.open "data:application/vnd.oasis.opendocument.text;base64, " + data
  'click .exportCSV': (event, template) ->
    event.preventDefault()
    moment(from.value, Config.dateTimeFormat)
    params =
      projects: FlowRouter.getQueryParam 'projects'
      from: FlowRouter.getQueryParam 'from'
      to: FlowRouter.getQueryParam 'to'
    Meteor.call 'exportCSV', params, (error, data) ->
  'change #projects': (event, template) ->
    projects = $('#projects').val()
    FlowRouter.setQueryParams {projects: projects}
  'change #from': (event, template) ->
    from = template.find('#from').value
    if from
      from = tdateToMoment from
      FlowRouter.setQueryParams {from: from.format 'X'}
  'change #to': (event, template) ->
    to = template.find('#to').value
    if to
      to = tdateToMoment to
      FlowRouter.setQueryParams {to: to.format 'X'}
  'click #none': (event, template) ->
    FlowRouter.setQueryParams {from: null, to: null}
  'click #month': (event, template) ->
    FlowRouter.setQueryParams {from: moment().startOf('month').format 'X'}
    FlowRouter.setQueryParams {to: moment().endOf('month').format 'X'}
  'click #last-month': (event, template) ->
    FlowRouter.setQueryParams {from: moment().subtract(1,'months').startOf('month').format 'X'}
    FlowRouter.setQueryParams {to: moment().subtract(1,'months').endOf('month').format 'X'}    
  'click #week': (event, template) ->
    FlowRouter.setQueryParams {from: moment().startOf('week').format 'X'}
    FlowRouter.setQueryParams {to: moment().endOf('week').format 'X'}
  'click #day': (event, template) ->
    FlowRouter.setQueryParams {from: moment().startOf('day').format 'X'}
    FlowRouter.setQueryParams {to: moment().endOf('day').format 'X'}
  'click #year': (event, template) ->
    FlowRouter.setQueryParams {from: moment().startOf('year').format 'X'}
    FlowRouter.setQueryParams {to: moment().endOf('year').format 'X'}

Template.timetrack.onRendered ->
  initUI = ->
    $('#from').datetimepicker dateTimePickerOptions
    $('#to').datetimepicker dateTimePickerOptions
  Meteor.setTimeout initUI, 200
#  $('#from').datetimepicker dateTimePickerOptions
#  $('#to').datetimepicker dateTimePickerOptions
  setDateAndTime()

setDateAndTime = ->
  _id = FlowRouter.getParam('_id')
  if 'new' is _id
    now = new Date()
    $('#from').datetimepicker {value: now}
    $('#to').datetimepicker {value: now}

Template.timetrack.helpers
  timetrack: () ->
    setDateAndTime()
    _id = FlowRouter.getParam('_id')
    if 'new' is _id
      track =
        billable: 'checked'
        project: Session.get 'lastProject'
      return track
    Timetrack.findOne {_id: _id}
  projects: () -> Projects.find({}, {sort: {name: 1}})
  isSelected: (projectId) ->
    _id = FlowRouter.getParam('_id')
    if 'new' is _id
      Session.get('lastProject') is projectId
    else
      timetrack = Timetrack.findOne {_id: _id}
      timetrack.projectId == projectId

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
      projectId: template.find('#projectId').value
      feature: template.find('#feature').value
      task: template.find('#task').value
      billable: template.find('#billable').checked
      userId: Meteor.userId()
    try 
      check timetrack,
        from: Date
        to: Match.Optional(Date)
        time: Match.Optional(Number)
        projectId: NonEmptyString
        feature: Match.Optional(String)
        task: Match.Optional(String)
        billable: Boolean
        userId: String
      if _id
        Timetrack.update {_id: _id}, {$set: timetrack}
        FlowRouter.go '/timetrack'
      else
        id = Timetrack.insert timetrack        
        FlowRouter.go "/timetrack/#{id}"
      SUCCESS 'You worked!'
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
