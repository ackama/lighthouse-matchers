# Lighthouse Matchers [![Gem Version](https://badge.fury.io/rb/lighthouse-matchers.svg)](https://badge.fury.io/rb/lighthouse-matchers) [![Maintainability](https://api.codeclimate.com/v1/badges/2f1df198307f6a0489fc/maintainability)](https://codeclimate.com/github/ackama/lighthouse-matchers/maintainability) [![Build Status](https://travis-ci.org/ackama/lighthouse-matchers.svg?branch=master)](https://travis-ci.org/ackama/lighthouse-matchers) 

Lighthouse Matchers provides single-line RSpec matchers for 
expectations against the result of [Lighthouse](https://developers.google.com/web/tools/lighthouse/) 
audit checks.

## Getting Started

### RSpec

Start by including the gem in your Gemfile:

``` ruby
group :test do
  gem 'lighthouse-matchers'
end
```

Next, you need to require the matchers in your `spec_helper.rb` or `rails_helper.rb`:

``` ruby
require "lighthouse/matchers/rspec"
```

You also need to have the `lighthouse` CLI tool available. The matchers will automatically pick up the tool
if you have added it to your `$PATH`, or if you have installed the tool using: 

* `npm install --save-dev lighthouse` 
* `yarn add --dev ligththouse`

If you have the `lighthouse` CLI tool installed, but available elsewhere on your system, you can set the location manually.
See [Configuration](#configuration) for further instructions.

The matchers are now available to use. If you wish for your Lighthouse audits to use the same Chrome session
as your system tests (e.g. the page requires a logged-in user), then you should 
change the definition of your system test Chrome browser arguments to define a "remote debugging port". Without
defining this port, The `lighthouse` audit tool cannot connect to your existing Chrome session and will begin a new
one, clearing any session information.

An example of such a configuration is:

``` ruby
# spec/spec_helper.rb

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w(headless remote-debugging-port=9222) }
  )

  Capybara::Selenium::Driver.new app,
    browser: :chrome,
    desired_capabilities: capabilities
end

Capybara.javascript_driver = :headless_chrome
Lighthouse::Matchers.remote_debugging_port = 9222
```

### Test::Unit

Test::Unit support is planning and is coming soon!

## Matchers

### `pass_lighthouse_audit` 

This matcher accepts an optional audit type, and minimum score. 
If no audit type is passed in, then all audits are run. If a minimum score is not provided, then the score defined 
in `Lighthouse::Matchers.minimum_score` is used. The default value of this attribute is 100 - i.e. the audit must pass 
entirely.

#### Examples

* Assert that a URL fully passes all audits:
  ```
  it { expect("http://mysite.com").to pass_lighthouse_audit }
  ```
* Assert that a Capybara page object passes a performance audit only:
  ```
  it { expect(page).to pass_lighthouse_audit(:performance) }
  ```
* Assert that a Capybara page object passes all audits with a minimum score of 60:
  ``` 
  it { expect(page).to pass_lighthouse_audit(score: 60) }
  ```
* Assert that a URL passes the PWA audit with a minimum score of 90:
  ```
  it { expect("http://pwa.mysite.com").to pass_lighthouse_audit(:pwa, score: 90) }
  ```

## Configuration

All configuration keys are accessible against the `Lighthouse::Matchers` object. Configuration options include:

* **`remote_debugging_port`:** If defined, Lighthouse will connect to this Chrome debugging port. 
  This allows the audit to run in the same context as the Chrome session that created the port 
  (for example, in Capybara, this would be the current state of the page under test). This setting is useful for 
  running a Lighthouse audit against the _current state_ of a page, rather than it's initial load state. This setting
  must match up with the remote debugging port that has been configured for the Chrome browser instance if 
  Selenium webdrivers are being used.
* **`lighthouse_cli`:** The path to the Lighthouse CLI tool. By default, we will check `$PATH` and `node_modules/.bin/`
  for the CLI. This setting can be used if the Lighthouse tool is installed in a non-standard location.
* **`minimum_score`:** The default minimum score that audits must meet for the matcher to pass. 
  The default value of this configuration setting is '100' - e.g. audits must fully comply to pass.

## Compatibility

* Lighthouse Matchers is tested and supported against Ruby 2.0+ and RSpec 3.x. 
* The `lighthouse` CLI tool must be installed for these matchers to function.
* The [`capybara`](https://rubygems.org/gems/capybara) gem is required to make assertions 
  by passing in a `Capybara::Session`.

## Contributing

Contributions are welcome. 
Please see the [contribution guidelines](https://github.com/ackama/lighthouse-matchers/blob/master/CONTRIBUTING.md) 
for detailed instructions.

## Versioning

This gem endeavours to follow Semantic Versioning 2.0 as defined at https://semver.org/.

## License

lighthouse-matchers is copyright © 2019 Ackama Group Ltd.
It is free software, and may be redistributed under the terms specified in the 
[LICENSE](https://github.com/ackama/lighthouse-matchers/blob/master/LICENSE.txt) file.


## About Ackama

Lighthouse Matchers is created and maintained by Ackama Group using our investment time scheme. 
We are passionate about using and contributing back to the open source community, and are available for hire.