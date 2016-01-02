@LOG = (name, data) -> console.log name + ': ' + data
@LOGJ = (name, data) -> console.log name + ': ' + JSON.stringify data


@NonEmptyString = Match.Where (x) ->
  check(x, String)
  x.length > 0


@merge = (xs...) ->
  if xs?.length > 0
    tap {}, (m) -> m[k] = v for k, v of x for x in xs

@tap = (o, fn) -> fn(o); o  