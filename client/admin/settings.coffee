Template.settings.helpers
  settings: () -> Settings.findOne {userId: Meteor.userId()}

Template.settings.events
  'change #timesheet': (event, template) ->
    fileObj = TemplateFiles.insert event.target.files[0]
    console.log 'fileObj: ' + JSON.stringify fileObj
    Meteor.call 'saveTimesheetTemplate', fileObj, fileObj.original
  'click .save': (event, template) ->
    event.preventDefault()
