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
  stats: ->
    firstOfMonth = moment().startOf('month').toDate()
    lastOfMonth = moment().endOf('month').toDate()
    LOGJ 'firstOfMonth', firstOfMonth
    timetracks = Timetrack.find {$and: [from: {$gte: firstOfMonth}, to: {$lte: lastOfMonth}]}
    hoursBillable = 0
    hourNonBillable = 0
    billable = 0
    projects = {}
    timetracks.forEach (tt) ->
      project = Projects.findOne {_id: tt.projectId}
      unless projects[project.name]
        console.log projects[project.name]
        projects[project.name] =
          hoursBillable: 0
          hourNonBillable: 0
          billable: 0
      if tt.billable
        hoursBillable += tt.time
        LOGJ 'project', project
#        LOG 'time', tt.time
        LOG 'rate', project.rate
        billable += tt.time * project.rate || 0
        projects[project.name].hoursBillable += tt.time
        projects[project.name].billable += tt.time * project.rate || 0
      else
        hourNonBillable += tt.time
        projects[project.name].hourNonBillable += tt.time
    LOGJ 'projects', projects
    stats =
      hoursBillable: hoursBillable
      billable: billable
      hourNonBillable: hourNonBillable
      projects: projects
    
    
      