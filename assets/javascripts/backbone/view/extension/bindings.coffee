# 2-ways binding extension for Backbone.View
# Auto update html when model change, and update model when html change
#
# class Demo extends Backbone.View
#   bindings:
#     ":selector": ":attribute"
#     ":selector":
#       attribute: ":attribute"
#     ":key":
#       selector: "selector (required)"
#       accessor: "method called for set/get value on $el, string or function \
#         (optional, default: 'val' for input/textarea, 'text' for the other)"
#       event: "event (optional, default: 'change' for input/textarea)"
#       reverse: "is 2-ways binding (optional, default: true)"
#       onGet: ($el, model, attr, value) ->
#         "callback on get model attribute (optional)"
#       onSet: ($el, model, attr, event) ->
#         "callback on set model attribute (optional)"
#

class Binder
  constructor: (model, $el, options) ->
    [ @model, @$el ] = arguments
    @options = _.defaults(options, @defaults)
    @selector = _.required(options, 'selector')
    @attribute = _.required(options, 'attribute')

class View2ModelBinder extends Binder
  defaults:
    event: "change"
    accessor: "val"
    reverse: true
    onSet: ($el, model, attr, event) ->
      accessor = @options.accessor
      accessor = $el[accessor] if _.isString(accessor)
      value = accessor.call($el)
      model.set(attr, value)

  constructor: ->
    super

    if @options.reverse
      @reverse = new Model2ViewBinder(@model, @$el, @options)

  on: ->
    @off() if @handler?

    @handler = (event) =>
      @reverse._pending = true if @reverse
      $selector = @$el.find(@selector)
      # _.debug "View2ModelBinder: #{$selector.attr('id')}"
      @options.onSet.call(@, $selector, @model, @attribute, event)

    @$el.on(@options.event, @selector, @handler)
    @reverse.on() if @reverse

  off: ->
    @$el.off(@options.event, @selector, @handler)
    @reverse.off() if @reverse

class Model2ViewBinder extends Binder
  defaults:
    accessor: "text"
    onGet: ($el, model, attr, value) ->
      accessor = @options.accessor
      accessor = $el[accessor] if _.isString(accessor)
      accessor.call($el, value)

  on: ->
    @off() if @handler?
    @handler = (model, value) =>
      return @_pending = false if @_pending
      $selector = @$el.find(@selector)
      # _.debug "Model2ViewBinder: #{$selector.attr('id')}"
      @options.onGet.call(@, $selector, model, @attribute, value)
    @model.on("change:#{@attribute}", @handler)

  off: ->
    @model.off("change:#{@attribute}", @handler)


class Backbone.View.Extension.Bindings

  initialize: (view, options) ->
    if view.model
      model = view.model
      model = model(options) if _.isFunction(model)
    else
      model = _.required(options, "model")

    view.binders = {}
    for key, binding of view.bindings
      binding = { attribute: binding } if _.isString(binding)
      binding.selector = key unless binding.selector?

      $selector = view.$(binding.selector)
      tag = $selector.attr("tagName").toLowerCase()

      if /input|textarea/.test(tag) || binding.event?
        binder = new View2ModelBinder(model, view.$el, binding)
      else
        binder = new Model2ViewBinder(model, view.$el, binding)

      binder.on()
      view.binders[key] = binder

  remove: (view) ->
    for binder in view.binders
      binder.off()
