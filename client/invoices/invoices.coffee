Template.invoices.helpers
  invoices: () -> Invoices.find({}, {sort: {date: 1}})

Template.invoices.events
  'click .fa-plus': (event, template) ->
    FlowRouter.go '/invoice/new'
  'click .edit': (event, template) ->
    _id = event.currentTarget.parentNode.parentNode.getAttribute 'id'
    FlowRouter.go "/invoice/#{_id}"
  'click .remove': (event, template) ->
    _id = event.currentTarget.parentNode.parentNode.getAttribute 'id'
    Invoices.remove {_id: _id}


Template.invoice.onRendered ->
  # wait hack 
  initUI = ->
    $('#customer').select2()
    $('#projects').select2()
    $('#from').datetimepicker dateTimePickerOptions
    $('#to').datetimepicker dateTimePickerOptions
    $('#date').datetimepicker datePickerOptions
    customer = FlowRouter.getQueryParam 'customer'
    if customer
      Meteor.setTimeout (-> $('#customer').val(customer).trigger('change')), 200
  Meteor.setTimeout initUI, 200

Template.invoice.helpers
  invoice: () ->
    _id = FlowRouter.getParam('_id')
    if !_id || 'new' is _id then return {}
    invoice = Invoices.findOne {_id: _id}
    if invoice?.customer
      Meteor.setTimeout (-> $('#customer').val(invoice.customer).trigger('change')), 300
    invoice
  customers: -> Customers.find()
  projects: () -> Projects.find({}, {sort: {name: 1}})
  invoiceNo: ->
    settings = Settings.findOne {userId: Meteor.userId()}
    if settings
      currentNo = parseInt (settings.currentNo || 0)
      settings.currentNoPrefix + ++currentNo + settings.currentNoPostfix
    
Template.invoice.events
  'change #customer': (event, template) ->
    customer = $('#customer').val()
    if customer
      FlowRouter.setQueryParams {customer: customer}
      projects = Projects.find {customer: customer}
      projects = (p._id for p in projects.fetch())
      $('#projects').val(projects).trigger('change')
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

  'click .printInvoice': (event, template) ->
    event.preventDefault()
    _id = template.find('#_id').value || null
    momentFrom = moment(from.value, Config.dateTimeFormat)
    momentTo = moment(to.value, Config.dateTimeFormat)
    params =
      userId: Meteor.userId()
      invoiceNo: template.find('#invoiceNo').value
      customer: FlowRouter.getQueryParam 'customer'
      projects: FlowRouter.getQueryParam 'projects'
      from: momentFrom.toDate()
      to: momentTo.toDate()
      date: template.find('#date').value
    Meteor.call 'printInvoice', _id, params, (error, data) ->
      LOG 'error', error
      LOG 'data', data
#      if data
#        window.open(data.url)
#        window.open "data:application/vnd.oasis.opendocument.text;base64, " + data
  'click .save': (event, template) ->
    _id = template.find('#_id').value || null
    momentFrom = moment(from.value, Config.dateTimeFormat)
    momentTo = moment(to.value, Config.dateTimeFormat)
    dateValue = moment(date.value, Config.dateFormat)
    params =
      userId: Meteor.userId()
      invoiceNo: template.find('#invoiceNo').value
      customer: FlowRouter.getQueryParam 'customer'
      projects: FlowRouter.getQueryParam 'projects'
      from: momentFrom.toDate()
      to: momentTo.toDate()
      date: dateValue.toDate()
    if _id
      Invoices.update {_id: _id}, {$set: params}
    else
      Invoices.insert params
  'click .invoices': (event, template) ->
    event.preventDefault()
    Invoices.go '/invoice'
