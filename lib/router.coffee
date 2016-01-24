FlowRouter.route '/',
  action: () -> BlazeLayout.render "mainLayout", {content: "main"}
    

timetrackSection = FlowRouter.group
  prefix: "/timetrack"

timetrackSection.route '/',
  action: () -> BlazeLayout.render "mainLayout", {content: "timetracks"}

timetrackSection.route '/:_id',
  triggersEnter: [ (context, redirect) ->
    if context.params._id is 'work'
      id = Work.startStop()
      if id
        redirect "/timetrack/#{id}"
  ]
  action: (params) ->
    BlazeLayout.render "mainLayout", {content: "timetrack"}


invoiceSection = FlowRouter.group
  prefix: "/invoice"

invoiceSection.route '/',
  action: () -> BlazeLayout.render "mainLayout", {content: "invoices"}

invoiceSection.route '/:_id',
  action: () -> BlazeLayout.render "mainLayout", {content: "invoice"}    


adminSection = FlowRouter.group
  prefix: "/admin"

adminSection.route '/',
  action: () -> BlazeLayout.render "mainLayout", {content: "settings"}

adminSection.route '/projects',
  action: () -> BlazeLayout.render "mainLayout", {content: "projects"}

adminSection.route '/project',
  action: () -> BlazeLayout.render "mainLayout", {content: "project"}

adminSection.route '/project/:_id',
  action: () -> BlazeLayout.render "mainLayout", {content: "project"}

adminSection.route '/customers',
  action: () -> BlazeLayout.render "mainLayout", {content: "customers"}

adminSection.route '/customer',
  action: () -> BlazeLayout.render "mainLayout", {content: "customer"}

adminSection.route '/customer/:_id',
  action: () -> BlazeLayout.render "mainLayout", {content: "customer"}

superAdminSection = adminSection.group
  prefix: "/super"

superAdminSection.route '/access-control',
  action: () ->
