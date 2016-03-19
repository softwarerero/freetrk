Template.projects.helpers
  projects: () ->
    Projects.find({}, {sort: {name: 1}})
  customerName: (_id) ->
    customer = Customers.findOne {_id: _id}
    customer?.name

Template.projects.events
  'click .fa-plus': (event, template) ->
    FlowRouter.go '/admin/project'
  'click .edit': (event, template) ->
    _id = event.currentTarget.parentNode.parentNode.getAttribute 'id'
    FlowRouter.go "/admin/project/#{_id}"
  'click .remove': (event, template) ->
    _id = event.currentTarget.parentNode.parentNode.getAttribute 'id'
    Projects.remove {_id: _id}


Template.project.onRendered ->
  $('#customer').select2()

Template.project.helpers
  customers: () -> Customers.find({}, {sort: {name: 1}})
  project: () ->
    _id = FlowRouter.getParam('_id')
    if !_id then return {}
#    console.log '_id: ' + _id
#    console.log JSON.stringify Projects.findOne {_id: _id}
    Projects.findOne {_id: _id}
  isSelected: (customer) -> 
    _id = FlowRouter.getParam('_id')
    project = Projects.findOne {_id: _id}
    LOGJ 'project', project
    project?.customer is customer
    
Template.project.events
  'click .save': (event, template) ->
    event.preventDefault()
    _id = template.find('#_id').value
    obj =
      user: Meteor.userId()
      name: template.find('#name').value
      rate: parseFloat template.find('#rate').value
      fixedPrice: parseFloat template.find('#fixedPrice').value
      customer: template.find('#customer').value
    check obj.name, NonEmptyString
    if _id
      Projects.update {_id: _id}, {$set: obj}
    else
      Projects.insert obj
    FlowRouter.go '/admin/projects'
  'click .back': (event, template) ->
    event.preventDefault()
    FlowRouter.go '/admin/projects'


