Tracker.autorun ->
  Meteor.subscribe 'all'


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


Template.home.helpers
  stats: -> [
    {name: 'Today', results: makeStatsPeriod 'day'}
    {name: 'This Week', results: makeStatsPeriod 'week'}
    {name: 'This Month', results: makeStatsPeriod 'month'}
    {name: 'Last Month', results: makeStatsPeriod 'month', -1}
    {name: 'This Year', results: makeStatsPeriod 'year'}
    {name: 'Last Year', results: makeStatsPeriod 'year', -1}
  ]

makeStatsPeriod = (period, offset) ->
  firstOfPeriod = moment().startOf(period)
  lastOfPeriod = moment().endOf(period)
  if offset
    firstOfPeriod.add offset, period
    lastOfPeriod.add offset, period
  timetracks = Timetrack.find {$and: [from: {$gte: firstOfPeriod.toDate()}, to: {$lte: lastOfPeriod.toDate()}]}
  makeStats timetracks
    
makeStats = (timetracks) ->
  hoursBillable = 0
  hourNonBillable = 0
  billable = 0
  projects = {}
  fixedPrice = 0
  timetracks.forEach (tt) ->
    project = Projects.findOne {_id: tt.projectId}
    if project
      unless projects[project?.name]
        projects[project.name] =
          name: project.name
          hoursBillable: 0
          hourNonBillable: 0
          billable: 0
      if tt.billable
        hoursBillable += tt.time
        billable += tt.time * project.rate || 0
        projects[project.name].hoursBillable += tt.time
        projects[project.name].billable += tt.time * project.rate || 0
      else
        hourNonBillable += tt.time
        projects[project.name].hourNonBillable += tt.time
  #    LOGJ 'projects', projects
  stats =
    hoursBillable: hoursBillable
    billable: billable
    hourNonBillable: hourNonBillable
    projects: (value for own prop, value of projects)
  