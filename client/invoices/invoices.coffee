Template.invoices.helpers
  invoices: () ->
    Invoices.find({}, {sort: {date: 1}})
#  customerName: (_id) ->
#    customer = Customers.findOne {_id: _id}
#    customer?.name

Template.invoices.events
  'click .fa-plus': (event, template) ->
    FlowRouter.go '/invoice/new'
  'click .edit': (event, template) ->
    _id = event.currentTarget.parentNode.parentNode.getAttribute 'id'
    FlowRouter.go "/invoice/#{_id}"
  'click .remove': (event, template) ->
    _id = event.currentTarget.parentNode.parentNode.getAttribute 'id'
    Invoices.remove {_id: _id}


#Template.invoice.onRendered ->
#  $('#customer').select2()

Template.invoice.helpers
  invoice: () ->
    _id = FlowRouter.getParam('_id')
    if !_id || 'new' is _id then return {}
    Invoices.findOne {_id: _id}
  customers: -> Customers.find()
  isSelected: (customerId) -> 
    _id = FlowRouter.getParam('_id')
    customerId is _id
  isSelected: (customer) ->
    _id = FlowRouter.getParam('_id')
    project = Projects.findOne {_id: _id}
    LOGJ 'project', project
    project?.customer is customer
    
Template.invoice.events
  'click .save': (event, template) ->
    event.preventDefault()
    _id = template.find('#_id').value
    obj =
      userId: Meteor.userId()
      date: template.find('#date').value
      no: template.find('#no').value
#      customer: template.find('#customer').value
#    LOG 'customer', customer
#    LOGJ 'obj', obj
#    check obj.name, NonEmptyString
    Projects.upsert {_id: _id}, {$set: obj}
    Invoices.go '/invoice'
  'click .back': (event, template) ->
    event.preventDefault()
    Invoices.go '/invoice'


