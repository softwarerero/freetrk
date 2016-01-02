all =
  insert: () -> true
  update: () -> true
  remove: () -> true

TemplateFiles.allow all
#  insert: () -> true
#  update: () -> true
#  remove: () -> true
Timetrack.allow all
Projects.allow all
Customers.allow all
Settings.allow all
Invoices.allow all


#Meteor.methods
#  upsertTimetrack: (id, doc) -> Timetrack.upsert id, doc