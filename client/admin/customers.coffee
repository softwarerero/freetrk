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
        vat: template.find('#vat').value
        address: template.find('#address').value
        payable: template.find('#payable').value
      check obj.name, NonEmptyString
      if _id
        Customers.update {_id: _id}, {$set: obj}
      else
        Customers.insert obj
#      Customers.upsert {_id: _id}, obj
      FlowRouter.go '/admin/customers'
      SUCCESS 'Customer saved!'
    catch error
      ERROR error
  'click .back': (event, template) ->
    event.preventDefault()
    FlowRouter.go '/admin/customers'


