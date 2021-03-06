# init moment.js as formatter for jquery datetimepicker
Date.parseDate = (input, format) ->
  moment(input,format).toDate()

Date.prototype.dateFormat = (format) ->
  moment(this).format(format)

@dateTimePickerOptions =
  datepicker: true
  timepicker: true
#  format: 'd.m.Y H:i'
  format: Config.dateTimeFormat
  dayOfWeekStart: 1
  closeOnDateSelect: false
  formatTime: Config.timeFormat
#    startDate:'+1971/05/01'//or 1986/12/08
#    onChangeDateTime: (dp, $input) ->
#      alert($input.val())
#    mask: true
#    format:'DD.MM.YYYY HH:mm'

@timePickerOptions =
  datepicker: false
  timepicker: true
  format: Config.timeFormat
  step: 15

@datePickerOptions =
  datepicker: true
  timepicker: false
  format: Config.dateFormat

@unixTimestamp2Date = (ts) ->
  if typeof ts is 'string'
    ts = parseInt ts
  new Date parseInt ts*1000

@formatDate = (date) -> moment(date).format Config.dateFormat
@formatDateTime = (date) -> moment(date).format Config.dateTimeFormat
@formatTime = (date) -> moment(date).format Config.timeFormat
@formatIndustrialTime = (number) -> number.toFixed 2
@formatDisplayTime = (number) ->
  minutes = Math.floor(number / 60)
  if minutes < 10
    minutes = '0' + minutes
  seconds = number % 60
  if seconds < 10
    seconds = '0' + seconds
  "#{minutes}:#{seconds}"
  
  