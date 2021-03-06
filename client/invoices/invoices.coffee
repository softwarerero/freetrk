Template.invoices.helpers
  invoices: () -> Invoices.find({}, {sort: {date: 1}})
  customerName: (customer) -> Customers.findOne({_id: customer})?.name

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
    _id = FlowRouter.getParam('_id')
    if _id? isnt 'new'
      invoice = Invoices.findOne {_id: _id}
      if invoice then return invoice.invoiceNo
    settings = Settings.findOne {userId: Meteor.userId()}
    if settings
      invoiceNo = parseInt (settings.invoiceNo || 0)
      settings.invoiceNoPrefix + ++invoiceNo + settings.invoiceNoPostfix
    
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
    momentFrom = moment.utc(from.value, Config.dateTimeFormat)
    momentTo = moment(to.value, Config.dateTimeFormat)
    LOG 'from', from.value
    LOG 'momentFrom', momentFrom.utc().format()
    params =
      userId: Meteor.userId()
      invoiceNo: template.find('#invoiceNo').value
      customer: FlowRouter.getQueryParam 'customer'
      projects: FlowRouter.getQueryParam 'projects'
      from: momentFrom.unix()
      to: momentTo.unix()
      date: template.find('#date').value
    Meteor.call 'printInvoice', _id, params, (error, data) ->
      if error then return ERROR error
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
    params = merge params, invoiceData(timetracks(params), customer(params))
    if _id
      Invoices.update {_id: _id}, {$set: params}
    else
      _id = Invoices.insert params
      template.find('#_id').value = _id
    invoiceNo = template.find('#invoiceNo').value
    LOG 'invoiceNo', invoiceNo
    settings = Settings.findOne {userId: Meteor.userId()}
    Settings.update {_id: settings._id}, {$set: {invoiceNo: invoiceNo}}
  'click .invoices': (event, template) ->
    event.preventDefault()
    FlowRouter.go '/invoice'

timetracks = (params) ->
  query = {}
  if params.projects
    query.projectId = {$in: params.projects}
  if params.from
    query.from = {$gte: params.from}
  if params.to
    query.to = {$lte: params.to}
  tracks = Timetrack.find query, {sort: {from: 1}}
  tracks.fetch()
  
customer = (params) -> Customers.findOne {_id: params.customer}

invoiceData = (timetracks, customer) ->
  hours_billable = 0
  hours_non_billable = 0
  net_sum = 0
  for t in timetracks
    project = Projects.findOne {_id: t.projectId}
    if t.billable
      hours_billable += t.time
      net_sum += t.time * (project.rate || 0)
    else
      hours_non_billable += t.time
  vat = 0
  total = net_sum
  if customer
    vat = net_sum / 100 * (customer.vat || 0)
    total += vat
  net_sum: net_sum.toFixed(2)
  vat: vat.toFixed(2)
  total: total.toFixed(2)
  payable: customer?.payable || ''
  hours_billable: hours_billable.toFixed(2)
  hours_non_billable: hours_non_billable.toFixed(2)
    