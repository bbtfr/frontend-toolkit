# Debug extension for Backbone.View
# Show debug infomations
#

key = (view) ->
  "#{view.cid}(#{view.constructor.name})"

class Backbone.View.Extension.Debug

  force: true

  beforeInitialize: (view) ->
    _.debug("Create new Backbone.View: #{key(view)}")
    _.time("Create #{key(view)}")

  afterRender: (view) ->
    _.debug("Render Backbone.View: #{key(view)}")
    _.timeEnd("Create #{key(view)}")

  beforeRemove: (view) ->
    _.debug("Remove Backbone.View: #{key(view)}")
