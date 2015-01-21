module FrontendToolkit
  module Rails
    class Engine < ::Rails::Engine
      initializer 'frontend-toolkit.assets.precompile' do |app|
        %w(stylesheets javascripts fonts images).each do |sub|
          app.config.assets.paths << root.join('assets', sub).to_s
        end
        app.config.assets.precompile << %r(bootstrap/glyphicons-halflings-regular\.(?:eot|svg|ttf|woff2?)$)
      end
    end
  end
end