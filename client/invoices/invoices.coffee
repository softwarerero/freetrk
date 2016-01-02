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
  $('#customer').select2()
  $('#projects').select2()
  $('#from').datetimepicker dateTimePickerOptions
  $('#to').datetimepicker dateTimePickerOptions
#  momentFrom = moment(from.value, Config.dateTimeFormat)
  customer = FlowRouter.getQueryParam 'customer'
  if customer
# wait hack 
    Meteor.setTimeout (-> $('#customer').val(customer).trigger('change')), 200

Template.invoice.helpers
  invoice: () ->
    _id = FlowRouter.getParam('_id')
    if !_id || 'new' is _id then return {}
    invoice = Invoices.findOne {_id: _id}
    LOGJ 'invoice', invoice
    if invoice?.customer
      LOG 'customer', invoice.customer
      Meteor.setTimeout (-> $('#customer').val(invoice.customer).trigger('change')), 300
    invoice
  customers: -> Customers.find()
  projects: () -> Projects.find({}, {sort: {name: 1}})
  firstOfMonth: ->
    from = FlowRouter.getQueryParam 'from'
    if from
      from = moment from, 'X'
    else
      from = moment().startOf('month')
    from.format(Config.dateTimeFormat)      
  lastOfMonth: ->
    to = FlowRouter.getQueryParam 'to'
    if to
      to = moment to, 'X'
    else
      to = moment().endOf('month')
    to.format(Config.dateTimeFormat)
  invoiceNo: ->
    settings = Settings.findOne {userId: Meteor.userId()}
    if settings
      currentNo = parseInt (settings.currentNo || 0)
      settings.currentNoPrefix + ++currentNo + settings.currentNoPostfix
  date: -> moment().format Config.dateFormat
    
Template.invoice.events
  'change #customer': (event, template) ->
    customer = $('#customer').val()
    LOGJ 'customer', customer
    if customer
      FlowRouter.setQueryParams {customer: customer}
      projects = Projects.find {customer: customer}
      projects = (p._id for p in projects.fetch())
      LOGJ 'projects', projects
      $('#projects').val(projects).trigger('change')
  'change #projects': (event, template) ->
    projects = $('#projects').val()
    LOGJ 'projects', projects
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

  'click .write': (event, template) ->
    event.preventDefault()
    console.log 'write'
    _id = template.find('#_id').value || null
    LOGJ '_id', _id
    params =
      userId: Meteor.userId()
      invoiceNo: template.find('#invoiceNo').value
      customer: FlowRouter.getQueryParam 'customer'
      projects: FlowRouter.getQueryParam 'projects'
      from: FlowRouter.getQueryParam 'from'
      to: FlowRouter.getQueryParam 'to'
      date: template.find('#date').value
#    LOG 'customer', customer
    LOGJ 'params', params
#    check obj.name, NonEmptyString
#    Invoices.go '/invoice'
#    params =
#      projects: FlowRouter.getQueryParam 'projects'
#      from: FlowRouter.getQueryParam 'from'
#      to: FlowRouter.getQueryParam 'to'
    Meteor.call 'printInvoice', _id, params, (error, data) ->
      LOG 'error', error
      LOG 'data', data
#      if data
#        window.open(data.url)
#        window.open "data:application/vnd.oasis.opendocument.text;base64, " + data
  'click .invoices': (event, template) ->
    event.preventDefault()
    Invoices.go '/invoice'


