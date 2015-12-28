Meteor.methods

#  getTimezone: () ->
#    return Config.tz.server || jstz.determine().name()

  printTimesheet: (params) ->
    query = queryFromParams params
    timetracks = Timetrack.find query, {sort: {from: 1}}
#    Meteor.wrapAsync createOdt timetracks
    createOdt timetracks, 'timesheet'

  printInoice: (params) ->
    query = queryFromParams params
    timetracks = Timetrack.find query, {sort: {from: 1}}
    createOdt timetracks, 'invoice'

  saveTimesheetTemplate: (fileObj, original) ->
    console.log 'saveTimesheetTemplate: ' + JSON.stringify original
    Settings.upsert {userId: Meteor.userId()}, {$set: {userId: Meteor.userId(), timesheet: fileObj, timeSheetName: original.name}}

  saveInvoiceTemplate: (fileObj, original) ->
    console.log 'saveInvoiceTemplate: ' + JSON.stringify original
    Settings.upsert {userId: Meteor.userId()}, {$set: {userId: Meteor.userId(), invoice: fileObj, invoiceName: original.name}}

queryFromParams = (params) ->
  #    LOGJ 'printTimesheet', params
  query = {}
  if params.projects
    query.projectId = {$in: params.projects}
  if params.from
    query.from = {$gte: unixTimestamp2Date params.from}
  if params.to
    query.to = {$lte: unixTimestamp2Date params.to}
  ret =
    projectId: {$in: params.projects}
    from: {$gte: unixTimestamp2Date params.from}
    to: {$lte: unixTimestamp2Date params.to}
    
    
#TODO: refactor    
createOdt = (timetracks, type) ->
  odt = Meteor.npmRequire('odt-old-archiver')
  table = Meteor.npmRequire('odt-old-archiver/lib/handler').table
  fs = Meteor.npmRequire 'fs'
#  stream = Meteor.npmRequire 'stream'

#  odtFileName = Config.tmpPath + '/' + 'timesheet_' + Meteor.userId() + '-' + Date.now() + '.odt'
  odtFileName = "#{Config.tmpPath}/#{type}_#{Meteor.userId()}-#{Date.now()}.odt"
  LOG 'odtFileName', odtFileName
  settings = Settings.findOne {userId: Meteor.userId()}
  fileObj = TemplateFiles.findOne {_id: settings[type]._id}
  LOGJ 'fileObj', fileObj
  if !fileObj
    throw new Meteor.Error "no-#{type}", "You must upload a #{type} under settings first!"
  doc = fileObj.getFileRecord().createReadStream()
  return
  
  #TODO: create data on client
  values =
    customer_name: { "type": "string", "value": "Name" }
    customer_address1: { "type": "string", "value": "Address1" }
    customer_address2: { "type": "string", "value": "Address2" }
    customer_address3: { "type": "string", "value": "Address3" }
    customer_address4: { "type": "string", "value": "Address4" }
    customer_no: { "type": "string", "value": "1234" }
    invoice_date: { "type": "string", "value": "18.11.2015" }
    invoice_no: { "type": "string", "value": "1234" }
    net_sum: { "type": "string", "value": "10" }
    vat: { "type": "string", "value": "1" }
    total: { "type": "string", "value": "11" }
    payable: { "type": "string", "value": "Payable within 15 days via Western Union, Bank Transfer or Paypal." }
    
    "customer": { "type": "string", "value": "A Customer\n\nwhat happen's with many\nlines?" }
    "project": { "type": "string", "value": "hallo2" }
    "invoice_period": { "type": "string", "value": "This month" }
    "hours_billable": { "type": "string", "value": "10" }
    "hours_non_billable": { "type": "string", "value": "20" }
    "datefield": 
      "type": "date",
      "value": new Date('Thu Jun 27 2013 12:00:00 GMT+0200 (CEST)')
    "currencyfield": 
      "type": "cent",
      "value": "999999999"

  positions = {Positions: [{
    pos_no: { "type": "string", "value": "1" }
    pos_quantity: { "type": "string", "value": "2" }
    pos_text: { "type": "string", "value": "Irgendwas" }
    pos_price: { "type": "string", "value": "5" }
    pos_sum: { "type": "string", "value": "10" }
  }]}
      

#  console.log JSON.stringify values
  timetable = mongo2Table timetracks
#  LOGJ 'timetable', timetable
#  LOGJ 'positions', positions
  
#  outStream = new stream.Writable()
#  outBuffer = buffer
  Future = Npm.require 'fibers/future'
  fut = new Future()
  MemoryStream = Meteor.npmRequire 'memorystream'
  memStream = new MemoryStream()
  
#  odtDone = Async.runSync (done) ->
  odt
    .template(doc)
    .apply(values)
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
  for tt in timetracks.fetch()
    row =
      tt_from: {type: 'string', value: moment(tt.from).format(Config.dateTimeFormatShort)}
      tt_to: {type: 'string', value: moment(tt.to).format(Config.dateTimeFormatShort)}
      tt_time: {type: 'string', value: tt.time.toFixed(2)}
      tt_feature: {type: 'string', value: tt.feature}
      tt_task: {type: 'string', value: tt.task}
    rows.push row
  {Timetable: rows}
