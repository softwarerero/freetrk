#Template.settings.onCreated ->
  
Template.settings.helpers
  settings: () -> Settings.findOne {userId: Meteor.userId()}

Template.settings.events
  'change #timesheet': (event, template) ->
#    fileObj = TemplateFiles.update {userId: Meteor.userId()}, event.target.files[0]
    file = event.target.files[0]
    file.user = Meteor.userId()
    fileObj = TemplateFiles.insert event.target.files[0]
    Meteor.call 'saveTimesheetTemplate', fileObj, fileObj.original
  'change #invoice': (event, template) ->
    file = event.target.files[0]
    file.user = Meteor.userId()
    fileObj = TemplateFiles.insert event.target.files[0]
    Meteor.call 'saveInvoiceTemplate', fileObj, fileObj.original
  'click .save': (event, template) ->
    event.preventDefault()
    obj =
      currentNoPrefix: template.find('#currentNoPrefix').value
      currentNo: template.find('#currentNo').value
      currentNoPostfix: template.find('#currentNoPostfix').value
    settings = Settings.findOne {userId: Meteor.userId()}
    Settings.update {_id: settings._id}, {$set: obj}

    
  