Meteor.methods

  printTimesheet: (params) ->
    LOGJ 'params', params
    query = queryFromParams params
    LOGJ 'query', query
    timetracks = Timetrack.find query, {sort: {from: 1}}
    timetracks = timetracks.fetch()
    LOGJ 'timetracks', timetracks.length
#    Meteor.wrapAsync createOdt timetracks
    data = {}
    projects = params?.projects || []
    pos = positions(projects, timetracks)
    createOdt data, mongo2Table(timetracks), pos, 'timesheet'

  printInvoice: (invoiceId, params) ->
    query = queryFromParams params
#    Invoices.upsert {_id: invoiceId}, {$set: params}
    LOGJ 'query', query
    timetracks = Timetrack.find query, {sort: {from: 1}}
    timetracks = timetracks.fetch()
    LOG 'timetracks', timetracks.length
    customer = Customers.findOne {_id: params.customer}
    data = customerData customer
    data = merge data, invoiceHeader invoiceId
    data = merge data, invoiceData timetracks, customer, params
#    LOGJ 'data', data
    pos = positions params.projects, timetracks
    createOdt data, mongo2Table(timetracks), pos, 'invoice'

  saveTimesheetTemplate: (fileObj, original) ->
    Settings.upsert {userId: Meteor.userId()}, {$set: {userId: Meteor.userId(), timesheet: fileObj, timeSheetName: original.name}}

  saveInvoiceTemplate: (fileObj, original) ->
    Settings.upsert {userId: Meteor.userId()}, {$set: {userId: Meteor.userId(), invoice: fileObj, invoiceName: original.name}}

  exportCSV: (params) ->
#    LOGJ 'params', params
    query = queryFromParams params
#    query.billable = true
#    LOGJ 'query', query
    timetracks = Timetrack.find(query, {sort: {from: -1}}).fetch()
    exportCSV timetracks


fs = Meteor.npmRequire 'fs'
    
customerData = (customer) ->
  customerAddress = (i) ->
    lines = customer.address.split('\n')
    if lines.length > i then lines[i] else ''
  customer_name: { "type": "string", "value": customer.name }
  customer_address1: { "type": "string", "value": customerAddress(0) }
  customer_address2: { "type": "string", "value": customerAddress(1) }
  customer_address3: { "type": "string", "value": customerAddress(2) }
  customer_address4: { "type": "string", "value": customerAddress(3) }
  customer_no: { "type": "string", "value": customer.no }
    
    
invoiceHeader = (invoiceId) ->
  invoice = Invoices.findOne {_id: invoiceId}
  invoice_period = "#{invoice.from} - #{invoice.to}"
  invoice_date: { "type": "string", "value": invoice.date }
  invoice_no: { "type": "string", "value": invoice.invoiceNo }
  invoice_period: { "type": "string", "value": invoice_period }

positions = (projectIds, timetracks) ->
  rows = []
  for projectId, i in projectIds
    project = Projects.findOne {_id: projectId}
    pos = {pos_no: stringField i+1}
    pos_quantity = 0
    for t in timetracks
      if t.projectId is projectId
        pos_quantity += t.time
    pos.pos_quantity = stringField pos_quantity.toFixed(2)
    pos.pos_text = stringField project.name
    pos.pos_price = stringField project.rate
    pos_sum = pos_quantity * project.rate
    pos.pos_sum = stringField pos_sum.toFixed(2)
    rows.push pos
  {Positions: rows}

invoiceData = (timetracks, customer) ->
  hours_billable = 0
  hours_non_billable = 0
  net_sum = 0
  LOG 'tracks', timetracks.length
  for t in timetracks
    project = Projects.findOne {_id: t.projectId}
    if t.billable
      hours_billable += t.time
      net_sum += t.time * project.rate
    else
      hours_non_billable += t.time
  vat = net_sum / 100 * customer.vat
  total = net_sum + vat
  net_sum: { "type": "string", "value": net_sum.toFixed(2) }
  vat: { "type": "string", "value": vat.toFixed(2) }
  total: { "type": "string", "value": total.toFixed(2) }
#  payable: { "type": "string", "value": "Payable within 15 days via Western Union, Bank Transfer or Paypal." }
#  "customer": { "type": "string", "value": "A Customer\n\nwhat happen's with many\nlines?" }
#  "project": { "type": "string", "value": "hallo2" }
  hours_billable: { "type": "string", "value": hours_billable.toFixed(2) }
  hours_non_billable: { "type": "string", "value": hours_non_billable.toFixed(2) }
#  "datefield":
#    "type": "date",
#    "value": new Date('Thu Jun 27 2013 12:00:00 GMT+0200 (CEST)')
#  "currencyfield":
#    "type": "cent",
#    "value": "999999999"
    
queryFromParams = (params) ->
  query = {}
  if params.projects
    query.projectId = {$in: params.projects}
  if params.from
    query.from = {$gte: unixTimestamp2Date params.from}
  if params.to
    query.to = {$lte: unixTimestamp2Date params.to}
  return query    
#  ret =
#    projectId: {$in: params.projects}
##    from: {$gte: unixTimestamp2Date params.from}
##    to: {$lte: unixTimestamp2Date params.to}
#    from: {$gte: params.from}
#    to: {$lte: params.to}
    
createOdt = (data, timetable, positions, type) ->
  odt = Meteor.npmRequire('odt-old-archiver')
  table = Meteor.npmRequire('odt-old-archiver/lib/handler').table
#  stream = Meteor.npmRequire 'stream'

  odtFileName = "#{Config.tmpPath}/#{type}_#{Meteor.userId()}-#{Date.now()}.odt"
  LOG 'odtFileName', odtFileName
#  settings = Settings.findOne {userId: Meteor.userId()}
#  fileObj = TemplateFiles.findOne {_id: settings[type]._id}
#  if !fileObj
#    throw new Meteor.Error "no-#{type}", "You must upload a #{type} under settings first!"
#  doc = fileObj.getFileRecord().createReadStream()
  doc = fs.createReadStream "#{Config.tmpPath}/suncom_invoice.ott"
  
  Future = Npm.require 'fibers/future'
  fut = new Future()
  MemoryStream = Meteor.npmRequire 'memorystream'
  memStream = new MemoryStream()
  
#  odtDone = Async.runSync (done) ->
  odt
    .template(doc)
    .apply(data)
    .apply(table(positions))
    .apply(table(timetable))
    .on 'error', (err) ->
      console.log 'err: ' + err
      throw err
    .finalize (bytes) ->
      console.log('The document is ' + bytes + ' bytes large.')
#      LOG 'memStream', memStream
      fut.return odtFileName
    .pipe(fs.createWriteStream(odtFileName))
#    .pipe(memStream)
#    .on 'close', (d) ->
#      console.log('document written: ' + d)
#      fut.return(d)
#    .on 'end', (a, b) ->
#      console.log('end.a: ' + a)
#      console.log('end.b: ' + b)
#      fut.return(d)
#    .end (data) -> LOG 'end', data
#    .done (err, data) -> LOG 'done', data
#      done(null, 'document written')
#  return odtDone
  fut.wait()
  {url: odtFileName}
#  LOGJ 'data', data
#  return data
#  base64String = new Buffer(data).toString('base64')
        
mongo2Table = (timetracks) ->
  rows = []
  for tt in timetracks
    row =
      tt_from: stringField moment(tt.from).format(Config.dateTimeFormatShort)
      tt_to: stringField moment(tt.to).format(Config.dateTimeFormatShort)
      tt_time: stringField tt.time.toFixed(2)
      tt_feature: stringField tt.feature
      tt_task: stringField tt.task
    rows.push row
  {Timetable: rows}

stringField = (value) -> {type: 'string', value: value?.toString()}

exportCSV = (timetracks) ->
  date = formatDate Date.now()
  outFileName = "#{Config.tmpPath}/timesheet_#{Meteor.userId()}-#{date}.csv"
  out = fs.createWriteStream(outFileName)
  writeAttr = (attr) -> out.write '"' + attr + '"'
  writeAttrDelim = (attr) -> writeAttr attr; out.write ','
  for tt in timetracks
    project = Projects.findOne {_id: tt.projectId}
    writeAttrDelim project.name
    writeAttrDelim formatDateTime tt.from
    writeAttrDelim formatDateTime tt.to
    writeAttrDelim formatIndustrialTime tt.time
    writeAttrDelim tt.feature
    writeAttr tt.billable
    out.write '\n'
  out.end() 