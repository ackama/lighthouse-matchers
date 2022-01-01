# Contributing

Although we are always happy to make improvements, we also
welcome changes and improvements from the community!

Have a fix for a problem you've been running into or an idea for a new feature
you think would be useful? Here's what you need to do:

1. [Read and understand the Code of Conduct](#code-of-conduct).
1. Fork this repo and clone your fork to somewhere on your machine.
1. [Ensure that you have a working environment](#setting-up-your-environment).
1. Read up on the [architecture of the gem](#architecture), [how to run
   tests](#running-tests), and [the code style we use in this
   project](#code-style).
1. Cut a new branch and write a failing test for the feature or bugfix you plan
   on implementing.
1. [Make sure your branch is well managed as you go
   along](#managing-your-branch).
   API](#documentation).
1. [Refrain from updating the changelog.](#changelog)
1. Push to your fork and submit a pull request.
1. [Ensure that the test suite passes CI and make any necessary changes
   to your branch to bring it to green.](#continuous-integration)

Although we maintain this gem in our free time, we try to respond to
contributions in a timely manner. Once we look at your pull request, we may give
you feedback. For instance, we may suggest some changes to make to your code to
fit within the project style or discuss alternate ways of addressing the issue
in question. Assuming we're happy with everything, we'll then bring your changes
into master. Now you're a contributor!

---

## Code of Conduct

If this is your first time contributing, please read the [Code of Conduct]. We
want to create a space in which everyone is allowed to contribute, and we
enforce the policies outline in this document.

[Code of Conduct]: https://github.com/ackama/lighthouse-matchers/blob/master/CODE_OF_CONDUCT.md

## Setting up your environment

The setup script will install all dependencies necessary for working on the
project:

```bash
bin/setup
```

## Architecture

This project follows the typical structure for a gem: code is located in `lib`
and tests are in `spec`.

There are other files in the project, of course, but these are likely the ones
you'll be most interested in.

### Tests

In addition, tests are broken up into two categories:

* Unit tests — low-level tests for individual matchers (you're probably
  interested in these). These tests typically stub out actual requests to the Lighthouse CLI.
* Integration tests — high-level tests to ensure that the gem works against the CLI tool. These tests are not updated frequently but are important to make sure that changes to the CLI interface do not cause this library to break.

Our approach to testing tends to iterate over time. The best approach for writing tests is to copy an existing test in the same file as where you want to add a new test. We may suggest changes to bring the tests in line with
our current approach.

## Code style

We follow a derivative of the [unofficial Ruby style guide] created by the
Rubocop developers. You can view our Rubocop configuration [here], but here are
some key differences:

* We allow longer blocks in spec files. This is because `RSpec.describe` blocks can
  quite easily go over the default Rubocop limit.
* We have increased the maximum line length to 100 characters.

[unofficial Ruby style guide]: https://github.com/rubocop-hq/ruby-style-guide
[here]: .rubocop.yml

## Running tests

### Unit tests

Unit tests are the most common kind of tests in the gem. They exercise matcher
code file by file using mocked results from the Lighthouse CLI.

To run a unit test, you might say something like:

```bash
bundle exec rspec spec/lighthouse/matchers/rspec_spec.rb
```

You can run all unit tests (fast) using a special rake task:

```bash
bundle exec rake spec:unit
```

### Integration tests

The integration tests exercise matchers using real Lighthouse audit results. We aim to
select reasonably complex well-known projects that are know to have good audit scores to exercise
that our matchers correctly catch pass and fail conditions.

To run an integration test, you might say something like:

```bash
bundle exec rspec spec/integration/lighthouse_matchers_spec.rb
```

You can run all integration tests (slow) using a special rake task:

```bash
bundle exec rake spec:integration
```

### All tests

In order to run all of the tests, simply run:

```bash
bundle exec rake
```

## Managing your branch

* Use well-crafted commit messages, providing context if possible.
* Squash "WIP" commits and remove merge commits by rebasing your branch against
  `master`. We try to keep our commit history as clean as possible.

## Documentation

As you navigate the codebase, you may notice certain classes and methods that
are prefaced with inline documentation.

If your changes end up extending or updating the API, it helps greatly to update the
docs at the same time for future developers and other readers of the source code.

## A word on the changelog

You may also notice that we have a changelog at [CHANGELOG.md](CHANGELOG.md)
You may be tempted to include changes to this in your branch, but don't worry
about this — we'll take care of it when we release a new version.

## Continuous integration

While running `bundle exec rake` is a great way to check your work, this command
will only run your tests against the latest supported Ruby and Rails version.
Ultimately, though, you'll want to ensure that your changes work in all possible
environments. We make use of [Github Actions][actions] to do this work for us. This
will kick in after you push up a branch or open a PR. It takes a few minutes to
run a complete build, which you are free to
[monitor as it progresses][actions].

[actions]: https://github.com/ackama/lighthouse-matchers/actions

What happens if the build fails in some way? Don't fear! Click on a failed job
and scroll through its output to determine the cause of the failure. You'll want
to make changes to your branch and push them up until the entire build is green.
It may take a bit of time, but overall it is worth it and it helps us immensely!
