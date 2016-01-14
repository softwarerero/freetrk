#Template.settings.onCreated ->
  
Template.settings.helpers
  settings: () -> Settings.findOne {userId: Meteor.userId()}

Template.settings.events
  'change #timesheet': (event, template) ->
#    fileObj = TemplateFiles.update {userId: Meteor.userId()}, event.target.files[0]
    file = event.target.files[0]
    file.user = Meteor.userId()
    fileObj = TemplateFiles.insert event.target.files[0]
    console.log 'fileObj: ' + JSON.stringify fileObj
    Meteor.call 'saveTimesheetTemplate', fileObj, fileObj.original
  'change #invoice': (event, template) ->
    file = event.target.files[0]
    files = TemplateFiles.find()
#    LOG 'count', files.count()
#    for f in files.fetch()
#      LOG 'remove', f.remove()
#    console.log 'userId: ' + Meteor.userId()
    file.user = Meteor.userId()
    fileObj = TemplateFiles.insert event.target.files[0]
    Meteor.call 'saveInvoiceTemplate', fileObj, fileObj.original
  'click .save': (event, template) ->
    event.preventDefault()
    obj =
      currentNoPrefix: template.find('#currentNoPrefix').value
      currentNo: template.find('#currentNo').value
      currentNoPostfix: template.find('#currentNoPostfix').value
#    LOGJ 'obj', obj
    settings = Settings.findOne {userId: Meteor.userId()}
    Settings.update {_id: settings._id}, {$set: obj}
