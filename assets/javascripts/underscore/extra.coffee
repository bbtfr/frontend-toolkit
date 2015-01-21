_.mixin 

  required: (obj, key) ->
    _.tap obj[key], (value) ->
      _.error("Parameter '#{key}' is required for ", obj) unless value

  deleted: (obj, key) ->
    _.tap obj[key], ->
      delete obj[key]

  # For JST
  loadTemplate: (path) ->
    if template = $("[id='#{path}']").html()
      JST[path] = _.template(template)
    _.required(JST, path)

  renderTemplate: (path, options = {}) ->
    _.loadTemplate(path)(options)

  setDebugLevel: (debugLevel) ->
    DebugLevelMap =
      0: ['debug', 'time', 'timeEnd']
      1: ['info', 'log']
      2: ['warn']
      3: ['error', 'assert']

    for level, methods of DebugLevelMap
      for method in methods
        if debugLevel <= level && console[method]?
          _[method] = _.bind(console[method], console)
        else
          _[method] = _.noop

_.setDebugLevel 0
