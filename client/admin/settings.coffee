Template.settings.helpers
  settings: () -> Settings.findOne {userId: Meteor.userId()}

Template.settings.events
  'change #timesheet': (event, template) ->
#    fileObj = TemplateFiles.update {userId: Meteor.userId()}, event.target.files[0]
    file = event.target.files[0]
    console.log 'userId: ' + Meteor.userId()
    file.user = Meteor.userId()
    fileObj = TemplateFiles.insert event.target.files[0]
    console.log 'fileObj: ' + JSON.stringify fileObj
    Meteor.call 'saveTimesheetTemplate', fileObj, fileObj.original
  'click .save': (event, template) ->
    event.preventDefault()
