class @Work
  @id = null
  @intervalId = null
  @favicon = null
  @work = null 
  @tick = =>
    timetrack = Timetrack.findOne {_id: @id}
    from = moment(timetrack.from)
    to = moment(new Date())
    minutes = to.diff from, 'minutes'
    @favicon.badge minutes.toString()
    seconds = to.diff from, 'seconds'
    @work.innerHTML = formatDisplayTime seconds
  @startStop: () -> if @id then @stop() else @start()
  @init = ->
    unless @work then @work = document.getElementById 'work'
    unless @favicon
      @favicon = new Favico {animation: 'none', type: 'rectangle', bgColor: '#fff', textColor: '#ffa600'}
  @start = ->
    @init()
    @id = Timetrack.insert
      from: new Date()
      to: new Date()
      userId: Meteor.userId()
      billable: true
    @intervalId = setInterval @tick, 1000
    @favicon.badge '0'
    @work.innerHTML = formatDisplayTime 0
    @id
  @stop = ->
    timetrack = Timetrack.findOne {_id: @id}
    if timetrack
      from = moment(timetrack.from)
      to = moment(new Date())
      time = to.diff(from, 'hours', true)
      Timetrack.update {_id: @id}, {$set: {to: to.toDate(), time: time}}
    clearInterval @intervalId
    ret = @id
    @id = null
    @favicon.badge ''
    @work.innerHTML = 'Work'
    ret
