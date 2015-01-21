Backbone.View.Extension = {}

BaseView = Backbone.View

class View extends BaseView

  constructor: (options = {}) ->
    @extensions = []
    for key, klass of Backbone.View.Extension
      if @[key.toLowerCase()]? || klass::force
        extension = new klass(@, options)
        @extensions.push(extension)
    BaseView.call(@, options)

  _runExtensionCallbacks: (key, callbackArguments) ->
    for extension in @extensions
      extension[key]?.apply(extension, callbackArguments)

_.each ['Initialize', 'Render', 'Remove'], (key) ->
  method = key.toLowerCase()
  beforeMethod = "before#{key}"
  afterMethod = "after#{key}"

  View::[method] = ->
    callbackArguments = Array.prototype.slice.call(arguments)
    callbackArguments.unshift @

    @[beforeMethod].apply(@, arguments) if @[beforeMethod]?
    @_runExtensionCallbacks(beforeMethod, callbackArguments)
    @_runExtensionCallbacks(method, callbackArguments)
    @_runExtensionCallbacks(afterMethod, callbackArguments)
    @[afterMethod].apply(@, arguments) if @[afterMethod]?
    BaseView::[method].apply(@, arguments)

Backbone.View = View
