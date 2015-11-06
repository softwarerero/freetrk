Template.projects.helpers
  projects: () ->
    Projects.find({}, {sort: {name: 1}})

Template.projects.events
  'click .fa-plus': (event, template) ->
    FlowRouter.go '/admin/project'
  'click .edit': (event, template) ->
    _id = event.currentTarget.parentNode.parentNode.getAttribute 'id'
    FlowRouter.go "/admin/project/#{_id}"
  'click .remove': (event, template) ->
    _id = event.currentTarget.parentNode.parentNode.getAttribute 'id'
    Projects.remove {_id: _id}

Template.project.helpers
  project: () ->
    _id = FlowRouter.getParam('_id')
    if !_id then return {}
#    console.log '_id: ' + _id
#    console.log JSON.stringify Projects.findOne {_id: _id}
    Projects.findOne {_id: _id}

Template.project.events
  'click .save': (event, template) ->
    event.preventDefault()
    _id = template.find('#_id').value
    name = template.find('#name').value
    rate = template.find('#rate').value
    check name, NonEmptyString
    Projects.upsert {_id: _id}, {user: Meteor.userId(), name: name, rate: rate}
    FlowRouter.go '/admin/projects'
  'click .back': (event, template) ->
    event.preventDefault()
    FlowRouter.go '/admin/projects'


@NonEmptyString = Match.Where (x) ->
  check(x, String)
  x.length > 0