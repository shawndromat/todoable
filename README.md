# Todoable

A wrapper around the Todoable API

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'todoable'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install todoable

## Usage

```ruby
todoable = Todoable::Client.new(user: user, password: password)
```

## Notes and Learnings
* I modeled the structure and API of my gem after the Twitter gem because it is a widely-used API wrapper that I have personally used recently and found simple and easy
* I started out trying VCR/cassettes due to the blog post about this assignment, but I ended switching to stub out my own requests. I found testing error cases easier to setup and easier to read this way
* Though I have tried cassettes before, this is the most I've played around with it. My thoughts thus far:
  * Pros of using cassettes:
    * assurance that the response was at least at one point a real response coming from real service
    * probably great for read-only integrations
  * Cons of cassettes:
    * Lack of integrative testing (this assignment does reads and writes but we can't really test that interplay)
    * Requires hitting the real service at least once which, if writing, dirties up that environment
    * Can't get clean recordings unless you have ability to clear out the external service and record again
    * Difficult to get recorded error responses
    * What the external service is actually doing is a bit opaque, you have to go look at the cassette files to see
    * A lot of recording and re-recording if you need to change the shape of a request/response

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Todoable project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/todoable/blob/master/CODE_OF_CONDUCT.md).
