fs = Npm.require('fs')

Meteor.startup ->

#  console.log 'remove: ' + TemplateFiles.remove {}
#  console.log 'remove: ' + Timetrack.remove {}


  #Meteor.users.remove {}
  if !Meteor.users.find().count()
    for u in Config.users
      user =
        username: u.name
        emails: [
          { address: u.email, verified: true }
        ]
        createdAt: new Date()
  
      Meteor.users.insert user, (error, id) ->
        Accounts.setPassword id, u.password
  
  
  if Config.smtp
    process.env.MAIL_URL = Config.smtp


#  Timetrack.remove {}
#  if !Timetrack.find().count()
#    project = Projects.findOne {name: '+1 Math'}
#    csv = '/Users/sun/Downloads/privat.csv'
#    lines = fs.readFileSync(csv).toString().split('\n')
#    lines.splice(0, 1) # skip header
#    line2Fields = (line) -> line.split ';'
#    line2Data = (fields) ->
#      date: fields[0]
#      from: fields[1]
#      to: fields[2]
#      time: fields[3]
#      feature: fields[4]
#      project: project._id
#    for line in lines
#      if line.length
##        console.log 'line: ' + JSON.stringify line2Data line2Fields line
#        Timetrack.insert line2Data line2Fields line
