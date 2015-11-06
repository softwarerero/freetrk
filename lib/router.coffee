FlowRouter.route '/blog/:postId', 
  action: (params, queryParams) ->
    console.log("Yeah! We are on the post:", params.postId)



FlowRouter.route '/',
  action: () -> BlazeLayout.render "mainLayout", {content: "home"}

#FlowRouter.route '/:postId', 
#  action: () -> BlazeLayout.render "mainLayout", {content: "blogPost"}


timetrackSection = FlowRouter.group
  prefix: "/timetrack"

timetrackSection.route '/',
  action: () -> BlazeLayout.render "mainLayout", {content: "timetracks"}

timetrackSection.route '/:_id',
  action: () -> BlazeLayout.render "mainLayout", {content: "timetrack"}

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
    
superAdminSection = adminSection.group
  prefix: "/super"

superAdminSection.route '/access-control',
  action: () ->
    