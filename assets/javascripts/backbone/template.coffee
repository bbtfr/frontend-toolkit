class Backbone.Template
  constructor: (options) ->
    @$el = $(_.required(options, "el"))

  render: ->
    @

  remove: ->
    @$el.remove()
