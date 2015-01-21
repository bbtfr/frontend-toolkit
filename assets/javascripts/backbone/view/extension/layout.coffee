# Layout extension for Backbone.View
#
# class Demo extends Backbone.View
#   layout:
#     ":selector": ":view/template"
#     ":selector": -> ":view/template"
#     ":key":
#       selector: "selector (required)"
#       template: "view or template (required, string or function)"
#

class Backbone.View.Extension.Layout

  initialize: (view, options) ->
    _.extend(view.layout, options.layout)

  render: (view) ->
    @remove(view) if view.views?
    view.views = {}

    for key, options of view.layout
      if _.isString(options) || _.isFunction(options)
        selector = key
        template = options
      else
        selector = _.required(options, "selector")
        template = _.required(options, "template")

      $selector = view.$(selector)

      if _.isFunction(template)
        templateOptions =
          el: $selector
          parent: view
        _.defaults(templateOptions, options.options)

        if template.name != ""
          template = new template(templateOptions).render()
        else
          template = template(templateOptions)
          template = new Backbone.Template(el: template)
      else
        template = new Backbone.Template(el: template)

      view.views[key] = template

  remove: (view) ->
    for selector, template of view.views
      template.remove()
