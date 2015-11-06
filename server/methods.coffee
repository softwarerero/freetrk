Meteor.methods

#  getTimezone: () ->
#    return Config.tz.server || jstz.determine().name()

  printTimesheet: () ->
    timetracks = Timetrack.find({}, {sort: {date: 1, from: 1}})
    createOdt timetracks

  saveTimesheetTemplate: (fileObj, original) ->
    console.log 'saveTimesheetTemplate: ' + JSON.stringify original
    Settings.upsert {userId: Meteor.userId()}, {$set: {userId: Meteor.userId(), timesheet: fileObj, timeSheetName: original.name}}
    
# refactor    
createOdt = (timetracks) ->
  console.log 'createOdt'

  odt = Meteor.npmRequire('odt-old-archiver')
  table = Meteor.npmRequire('odt-old-archiver/lib/handler').table
  fs = Meteor.npmRequire('fs')
  events = Meteor.npmRequire 'events'
  createWriteStream = fs.createWriteStream

  # TODO: continue here - have to write the stream to a temp file because odt with a stream is buggy
  doc = '/Users/sun/Downloads/suncom_timesheet.ott'
  settings = Settings.findOne {userId: Meteor.userId()}
  doc = settings.timesheet.getFileRecord().createReadStream()
  out = fs.createWriteStream '/Users/sun/Downloads/suncom_timesheet2.ott'
  doc.pipe out 
  console.log 'doc: ' + doc
  
  values =
    "customer": { "type": "string", "value": "A Customer" }
    "project": { "type": "string", "value": "hallo" }
    "invoice_period": { "type": "string", "value": "This month" }
    "hours_worked": { "type": "string", "value": "10" }
    "hours_non_billable": { "type": "string", "value": "20" }
    "datefield": 
      "type": "date",
      "value": new Date('Thu Jun 27 2013 12:00:00 GMT+0200 (CEST)')
    "currencyfield": 
      "type": "cent",
      "value": "999999999"

  console.log JSON.stringify values
  tableData = mongo2Table timetracks
  
  odtDone = Async.runSync (done) ->
    odt
      .template(doc)
      .apply(values)
      .apply(table(tableData))
      .on 'error', (err) ->
        console.log 'err: ' + err
        throw err
      .finalize (bytes) ->
        console.log('The document is ' + bytes + ' bytes large.')
      .pipe(createWriteStream('/Users/sun/Downloads/timesheet.odt'))
      .on 'close', () ->
        console.log('document written')

mongo2Table = (timetracks) ->
  rows = []
  for tt in timetracks.fetch()
    row =
      tt_date: {type: 'string', value: tt.date}
      tt_from: {type: 'string', value: tt.from}
      tt_to: {type: 'string', value: tt.to}
      tt_time: {type: 'string', value: tt.time}
      tt_feature: {type: 'string', value: tt.feature}
      tt_task: {type: 'string', value: tt.task}
    rows.push row
  {Tabelle1: rows}
