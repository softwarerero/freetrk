#customer_name: { "type": "string", "value": "Name" }
#customer_address1: { "type": "string", "value": "Address1" }
#customer_address2: { "type": "string", "value": "Address2" }
#customer_address3: { "type": "string", "value": "Address3" }
#customer_address4: { "type": "string", "value": "Address4" }
#customer_no: { "type": "string", "value": "1234" }
#
Template.customers.helpers
  customers: () ->
    Customers.find({}, {sort: {name: 1}})

Template.customers.events
  'click .fa-plus': (event, template) ->
    FlowRouter.go '/admin/customer'
  'click .edit': (event, template) ->
    _id = event.currentTarget.parentNode.parentNode.getAttribute 'id'
    FlowRouter.go "/admin/customer/#{_id}"
  'click .remove': (event, template) ->
    _id = event.currentTarget.parentNode.parentNode.getAttribute 'id'
    Customers.remove {_id: _id}

Template.customer.helpers
  customer: () ->
    _id = FlowRouter.getParam('_id')
    if !_id then return {}
    Customers.findOne {_id: _id}

Template.customer.events
  'click .save': (event, template) ->
    event.preventDefault()
    try
      _id = template.find('#_id').value
      obj =
        user: Meteor.userId()
        name: template.find('#name').value
        no: template.find('#no').value
        address: template.find('#address').value
      check obj.name, NonEmptyString
      SUCCESS 'Customer saved!'
      Customers.upsert {_id: _id}, obj
      FlowRouter.go '/admin/customers'
    catch error
      ERROR error
  'click .back': (event, template) ->
    event.preventDefault()
    FlowRouter.go '/admin/customers'


