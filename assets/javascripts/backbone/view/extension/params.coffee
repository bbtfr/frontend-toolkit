# Params extension for Backbone.View
#
# class Demo extends Backbone.View
#   params:
#     required: [
#       ":param"
#     ]
#     optional:
#       ":param": ":default"
#

class Backbone.View.Extension.Params

  initialize: (view, options) ->
    # Required parameters
    for param in view.params.required
      view[param] = _.required(options, param)

    # Optional parameters
    for param, value of view.params.optional
      view[param] = options[param] || value
