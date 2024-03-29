# Store (collection) extension for Backbone.View
# Auto update html when collection add/sort/reset/remove
#
# class Demo extends Backbone.View
#   store:
#     selector: "selector (required)"
#     template: "view or template (required, string or function)"
#     onAdd: (model, collection, options) ->
#       "callback on add model to collection (optional)"
#     onSort: (collection, options) ->
#       "callback on sort collection (optional)"
#     onReset: (collection, options) ->
#       "callback on reset collection (optional)"
#     onRemove: (model, options) ->
#       "callback on remove model from collection (optional)"
#

class Collection2ViewBinder
  defaults:
    onAdd: (model, collection, options) ->
      template = @template

      if _.isFunction(template)
        templateOptions =
          model: model
          collection: collection
          parent: @view

        if template.name != ""
          template = new template(templateOptions).render()
        else
          template = template(templateOptions)
          template = new Backbone.Template(el: template)
      else
        template = new Backbone.Template(el: template)

      template.$el.appendTo(@$selector)
      @views[model.cid] = template

    onSort: (collection, options) ->
      for model in collection.models
        template = @views[model.cid]
        template.$el.appendTo(@$selector)

    onReset: (collection, options) ->
      @remove(cid: cid) for cid, template of @views
      @add(model, collection) for model in collection.models

    onRemove: (model, options) ->
      @views[model.cid].remove()
      delete @views[model.cid]

    onFilter: (collection, attributes) ->
      eachTemplate = (models, callback) =>
        for model in models
          template = @views[model.cid]
          callback(template.$el)
      if attributes?
        eachTemplate collection.models, (template) ->
          template.hide()
        eachTemplate collection.where(attributes), (template) ->
          template.show()
      else
        eachTemplate collection.models, (template) ->
          template.show()

    infinite:
      prefix: false
      suffix: false
      slice: 10

      onReset: (collection, options) ->
        for cid, template of @views
          (template.$el || template).hide()
        @$container.scrollTop(0)
        @infinite.length = 0
        @infinite.models = if @infinite.attributes?
            collection.where(@infinite.attributes)
          else
            collection.models
        @show(@options.slice)

      onFilter: (collection, attributes) ->
        @infinite.attributes = attributes
        @reset()

      onSort: (collection, options) ->
        @reset()

      onScroll: ->
        return if @onScrollWorking
        @onScrollWorking = true

        getHeight = =>
          height = @$container.attr("scrollHeight")
          height -= @$container.attr("scrollTop")
          height -= @$container.height()
          height -= @$suffix.height() if @$suffix?
          height

        @infinite.height ||= @$selector.height() / @infinite.length
        while getHeight() < @infinite.height * @options.slice and @infinite.length < @infinite.models.length
          @show(@infinite.length + @options.slice)

        @onScrollWorking = false

      onShow: (length) ->
        models = @infinite.models[@infinite.length...length]
        @infinite.length = length
        for model in models
          template = @views[model.cid]
          if template?
            template.$el.appendTo(@$selector)
            (template.$el || template).show()
          else
            @add(model)
        if @$suffix?
          height = (@infinite.models.length - @infinite.length) * @infinite.height
          height = if height > 0 then height else 0
          @$suffix.height(height)

  constructor: (collection, $el, options) ->
    [ @collection, @$el ] = arguments
    @infinite = options.infinite
    @options = _.defaults(options, @defaults)
    @template = _.required(@options, "template")
    @$selector = @$el.find(_.required(@options, 'selector'))
    @views = {}

    if @infinite?
      @options = _.extend(@options, @defaults.infinite, @infinite)

  on: ->
    @off() if @handlers?

    @handlers = {}
    for key in [ 'Add', 'Sort', 'Reset', 'Remove' ]
      event = key.toLowerCase()
      method = "on#{key}"
      handler = @options[method].bind(@)
      @handlers[event] = handler
      @collection.on(event, handler)
    @handlers['filter'] = @options['onFilter'].bind(@)

    if @infinite
      @show = @options["onShow"].bind(@)
      @$container = @$selector.closest(@infinite.container)
      if @options.suffix
        @$suffix = $("<div class=\"infinite-suffix\"></div>")
          .appendTo(@$container)
      handler = @options["onScroll"].bind(@)
      @handlers['scroll'] = handler
      @$container.on('scroll', handler)

  off: ->
    for event, handler of @handlers
      @collection.off(event, handler)

  add: (model) ->
    @handlers["add"](model, @collection)

  remove: (model) ->
    @handlers["remove"](model)

  reset: (collection = @collection) ->
    @handlers["reset"](collection)

  filter: (attributes) ->
    if _.isEmpty(attributes) and not _.isFunction(attributes)
      attributes = undefined
    @handlers["filter"](@collection, attributes)

  sort: (comparator) ->
    @collection.comparator = comparator
    @collection.sort()

class Backbone.View.Extension.Store

  initialize: (view, options) ->
    if view.collection
      collection = view.collection
      collection = collection(options) if _.isFunction(collection)
    else
      collection = _.required(options, "collection")

    view.binder = new Collection2ViewBinder(collection, view.$el, view.store)
    view.binder.on()

  render: (view) ->
    view.binder.reset()

  remove: (view) ->
    view.binder.off()
