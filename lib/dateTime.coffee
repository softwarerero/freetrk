# init moment.js as formatter for jquery datetimepicker
Date.parseDate = (input, format) ->
  moment(input,format).toDate()

Date.prototype.dateFormat = (format) ->
  moment(this).format(format)

@datePickerOptions =
#  datepicker: false
  timepicker: false
  format: Config.dateFormat
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
