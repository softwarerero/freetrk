Meteor.methods

#  getTimezone: () ->
#    return Config.tz.server || jstz.determine().name()

  printTimesheet: () ->
    timetracks = Timetrack.find({}, {sort: {date: 1, from: 1}})
    Meteor.wrapAsync createOdt timetracks

  saveTimesheetTemplate: (fileObj, original) ->
    console.log 'saveTimesheetTemplate: ' + JSON.stringify original
    Settings.upsert {userId: Meteor.userId()}, {$set: {userId: Meteor.userId(), timesheet: fileObj, timeSheetName: original.name}}
    
# refactor    
createOdt = (timetracks) ->
  odt = Meteor.npmRequire('odt-old-archiver')
  table = Meteor.npmRequire('odt-old-archiver/lib/handler').table
  fs = Meteor.npmRequire('fs')

  odtFileName = Config.tmpPath + '/' + 'timesheet_' + Meteor.userId() + '-' + Date.now() + '.odt'
  settings = Settings.findOne {userId: Meteor.userId()}
  fileObj = TemplateFiles.findOne {_id: settings.timesheet._id}
  if !fileObj
    throw new Meteor.Error 'no-timesheet', 'You must upload a timesheet under settings first!'
  doc = fileObj.getFileRecord().createReadStream()
  
  values =
    "customer": { "type": "string", "value": "A Customer" }
    "project": { "type": "string", "value": "hallo2" }
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
      .pipe(fs.createWriteStream(odtFileName))
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
