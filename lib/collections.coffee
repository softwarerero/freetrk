@Projects = new Mongo.Collection("projects")
@Timetrack = new Mongo.Collection("timetrack")
@Settings = new Mongo.Collection("settings")

#templateStore = new FS.Store.GridFS "templateFiles"
#  mongoUrl: 'mongodb:#127.0.0.1:27017/test/', # optional, defaults to Meteor's local MongoDB
#  mongoOptions: {...},  # optional, see note below
#  transformWrite: myTransformWriteFunction, #optional
#  transformRead: myTransformReadFunction, #optional
#  maxTries: 1, # optional, default 5
#  chunkSize: 1024*1024  # optional, default GridFS chunk size in bytes (can be overridden per file).
# Default: 2MB. Reasonable range: 512KB - 4MB

@TemplateFiles = new FS.Collection "templateFiles", 
  stores: [new FS.Store.GridFS "templateFiles"]
  filter: 
    allow: 
      contentTypes: ['application/vnd.oasis.opendocument.text-template']
      extensions: ['ott']
    onInvalid: (message) ->
      if (Meteor.isClient) 
        alert(message)
      else 
        console.log(message);
#  stores: [new FS.Store.FileSystem("images", {path: "~/uploads"})]  


# Publications
#Meteor.publish "settingsAndFiles", (userId) ->
#  check(userId, String)
#  return [
#    Collections.Settings.find {userId: userId}, {fields: {secretInfo: 0}}
#    Collections.TemplateFiles.find
#      $query: {'metadata.owner': userId}
#      $orderby: {uploadedAt: -1}
#  ] 