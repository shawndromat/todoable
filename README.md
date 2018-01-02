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
## Notes on the gem design/API
* I modeled the structure and API of my gem after the Twitter gem because it is a widely-used API wrapper that I have personally used recently and found simple and easy
* I wanted to always return objects even though the API I'm wrapping doesn't always return json payloads that represent domain objects. This, in addition to the fact that the API doesn't always return the same fields for the same objects, means that I'm sometimes returning objects with missing fields. This feels a bit strange to do and in real life I'd hash out this detail through figuring out the use cases for this gem and its users

## Notes and Learnings from the process
* I started out trying VCR/cassettes due to the blog post about this assignment, but I ended switching to stub out my own requests. I found testing error cases easier to setup and easier to read this way
* The API returns different shapes of list depending on the endpoint, for example some of the details (url, id) which are returned in the list index endpoint are missing from the list show endpoint. If the latter was a strict superset of the former, I probably could have written a nice '#from_json' method and called it a day. But instead, I used the builder pattern as it's a pattern I like to use when my params for an object don't all come at once and from the same place
* Though I have tried cassettes before, this is the most I've played around with it. My thoughts thus far:
  * Pros of using cassettes:
    * assurance that the response was at least at one point a real response coming from real service
    * probably great for read-only integrations
  * Cons of cassettes:
    * Lack of integrative testing (this assignment does reads and writes but we can't really test that interplay)
    * Requires hitting the real service at least once which, if writing, dirties up that environment
    * Can't get clean recordings unless you have ability to clear out the external service and record again
    * A little unwieldy to get recorded error responses, either your recording needs to perform many calls (e.g. create a list before you can delete it) or the real service needs to be in a particular state before you record
    * If you need to change your test parameters a lot, it seems it might be painful to re-record
    * What the external service is actually doing is a bit opaque, you have to go look at the cassette files to see
    * A lot of recording and re-recording if you need to change the shape of a request/response
    * Recording can't happen in random order


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Todoable project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/todoable/blob/master/CODE_OF_CONDUCT.md).
