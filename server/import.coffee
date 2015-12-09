fs = Npm.require('fs')

#Meteor.startup ->
#  Timetrack.remove {}
#  Import.csv 'Scryent'
#  Import.csv 'Carlypso'

  
class Import
  
  @path: Config.tmpPath + '/'
  @findCustomer: (name) -> Customers.findOne {name: name}
  @projectId: (name) -> (Projects.findOne {name: name})._id    
  @readCSV: (name) -> fs.readFileSync "#{@path}#{name.toLowerCase()}.csv"

  @csv: (customerName, projectName) ->
    customer = @findCustomer customerName
    csv = @readCSV customerName.toLowerCase()
    lines = csv.toString().split('\n')
    lines.splice(0, 2) # skip headers
    line2Fields = (line) -> line.split ';'
    line2Data = (fields) =>
      from = moment fields[0], Config.dateFormat
      to = moment fields[0], Config.dateFormat
      fromRaw = fields[1].split ':'
      from.set('hour', fromRaw[0]).set('minute', fromRaw[1])
      toRaw = fields[2].split ':'
      to.set('hour', toRaw[0]).set('minute', toRaw[1])
      
      from: from.toDate()
      to: to.toDate()
      time: to.diff from, 'hours', true
      projectId: @projectId fields[4]
      feature: fields[5]
      billable: !!fields[6]
      userId: Config.importUserId

    for line in lines
      if line.length
        console.log JSON.stringify line2Data line2Fields line
        Timetrack.insert line2Data line2Fields line

