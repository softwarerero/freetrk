Meteor.publish 'all', () -> [
  Timetrack.find {userId: this.userId}
  Projects.find {user: this.userId}
  Customers.find {user: this.userId}
  Settings.find {userId: this.userId}
  Invoices.find {userId: this.userId}
#  TemplateFiles.find()
] 