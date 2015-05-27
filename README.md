__[CLOSED]__ Now I think collect all the assets libraries in one folder is not a good idea: of course, it's easy to use in sprockets, but hard to specify the version of asset in each project. That's why I closed this project, and will not commit to it anymore.
Please see [middleman-bower](https://github.com/bbtfr/middleman-bower) for further information.

# Frontend Toolkit

My Favorite Frontend Toolkit for Sprockets & Compass, including bootstrap, ratchet, jquery, zepto, underscore, backbone, react, etc.

## Installation

Add this line to your application's Gemfile:

    gem 'frontend-toolkit'

And then execute:

    $ bundle

To build your own frontend toolkit, please clone this project and run `ruby bin/update all` to update the assets libraries to lastest version.

## Usage

A collection of Javascript & CSS libraries, so you can use it in your asset pipeline.

For example, in your application.js
```javascript
//= require backbone
```

Now including: bootstrap, ratchet, jquery, zepto, underscore, backbone, react.

## Contributing

1. Fork it ( https://github.com/bbtfr/frontend-toolkit/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
