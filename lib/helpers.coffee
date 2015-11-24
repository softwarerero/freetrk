@LOG = (name, data) -> console.log name + ': ' + data
@LOGJ = (name, data) -> console.log name + ': ' + JSON.stringify data


@NonEmptyString = Match.Where (x) ->
  check(x, String)
  x.length > 0    