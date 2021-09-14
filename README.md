# Web Server Fundamentals

## Learning Goals

- Understand how a web server works
- Use Rack to create a simple, bare-bones web server

## Introduction

How does a web server work?

We open a browser and it uses HTTP to send a message to a server. Servers are
just computers running code that waits for requests and sends back responses.
But when you say `/search?item=shoes&size=13M`, how does it know to run the code
to search for shoes of size 13M?

All web servers have a core architecture in common. By looking at that
architecture, we can build a mental model for how all web servers work. As an
analogy, we can explain how all cars work like this:

> "Explosions made by gasoline and fire make an inside wheel go round and that
> inside wheel makes the outside wheels go round"

In the same way, we can say that all web servers work like this:

> "They wait for an HTTP request and look at the HTTP verb and path, and then
> run some conditional logic to find out which stuff to send back in the
> response"

In Ruby, this idea of "a core architecture" for all web-server-like things is
captured in a gem called Rack. Rails, which you'll learn in Phase 4, "rides on
top of" Rack. Sinatra, which you'll learn in the coming lessons, "rides on top
of" Rack too.

In fact, the idea of a base, common web-server library was such a good idea,
other languages like Python and JavaScript (via the NodeJS environment)
implemented their own "base" web server. By understanding the core mechanics of
how a server works in Ruby, you'll have a **much** easier time learning how to
work with servers in those other languages.

Before we get to the complexity of things built _on top of Rack_, let's get a
simple server working on Rack by itself.

**Note**: We'll be moving on from Rack shortly, so don't worry too much about
understanding the exact syntax in this lesson. Focus on the concepts.

## Setup

To code along with this lesson, run `bundle install`. We'll be using the
[Rack gem][rack], which is included in the Gemfile.

## Setting up Rack

Our goal with any web server is to be able to **receive a request** and **send a
response**.

To accomplish this with Rack, we need to create a class that responds to a
single method: `#call`. All this method needs to do is return an array with
three elements:

- A [**status code**][http-status] (where `200` is used for `OK`)
- A **response headers** hash with a `"Content-Type"` key that returns the
  value of `text/html` (for HTML-based responses)
- An array of strings to send back in the **body** of the response (in our case,
  we can format the string like HTML: `"<p>Like this!</p>"`)

Essentially, we need the `#call` method to return something like this:

```txt
[status code, headers hash, response body]
```

Here's an example that returns an HTML string:

```rb
[200, { "Content-Type" => "text/html" }, ["<h2>Hello <em>World</em>!</h2>"]]
```

## Creating a Rack-Based Web Server

With this goal in mind, let's create a basic web server. Follow along with the
instructions below.

Let's create a file called `config.ru`. Files that are used by Rack end with
`.ru` instead of `.rb` because they're normally loaded with a command called
`rackup`. It's a way to indicate to other developers that this is our server
definition file.

Add this code to the `config.ru` file:

```ruby
require 'rack'

class App
  def call(env)
    [200, { "Content-Type" => "text/html" }, ["<h2>Hello <em>World</em>!</h2>"]]
  end
end

run App.new
```

When we run this code, Rack will essentially run in a loop in the background
waiting for a **request** to come in. When it receives a request, it will call
the `#call` method and pass in data about the request, so we can send back the
appropriate **response**.

Run this code from the command line:

```console
$ rackup config.ru
```

Rack will print out something like:

```text
[2021-07-19 16:38:10] INFO  WEBrick 1.4.2
[2021-07-19 16:38:10] INFO  ruby 2.6.3 (2019-04-16) [universal.x86_64-darwin20]
[2021-07-19 16:38:10] INFO  WEBrick::HTTPServer#start: pid=34006 port=9292
```

> WEBrick is a Ruby library that provides a simple HTTP server. Rack needs a web
> server to handle connections, and WEBrick is the default since it's included
> with Ruby. Later, we'll be replacing this with another more powerful Ruby
> server, Thin.

Try visiting `http://localhost:9292` in your browser. This will send a GET
request to your Rack server, and you should see the HTML response of
`Hello World` appear!

Let's deconstruct this URL a little bit though. The URL is
`http://localhost:9292/`. The protocol is `http`. That makes sense, but the
domain is `localhost:9292`. What's going on there?

`localhost` is normally where a domain name like `google.com` goes. In this
case, since you are running the server on your computer, `localhost` refers to
the internal address of your computer.

The last part of that URL is the `:9292` section. This the "port number" of your
server. You may want to run multiple servers on one computer (for example, one
for React and one for Sinatra) and having different ports allows them to be
running simultaneously without conflicting.

The path, or resource, that you are requesting is `/`. This is effectively like
saying the home or default path. You should be able to go to
`http://localhost:9292/` and see `Hello World` printed out by your web server!

Feel free to change `config.ru` to add changes to your web server. If you make
changes to `config.ru` **you'll have to shut down the server (`control + c`) and
re-start it to see the changes**.

We can also access different information about the **request** object by using
the `env` argument that is passed into the `call` method. Try adding a
`binding.pry` to the `#call` method:

```rb
require 'rack'
require 'pry'

class App
  def call(env)
    binding.pry
    [200, { "Content-Type" => "text/html" }, ["<h2>Hello <em>World</em>!</h2>"]]
  end
end

run App.new
```

Then, stop (`control + c`) and restart the server (`rackup config.ru`), and
refresh the browser to make another request to the server. You should hit your
`binding.pry` breakpoint, where you can explore the `env` hash with all the data
about the request:

```rb
env["REQUEST_METHOD"]
# => "GET"
env["PATH_INFO"]
# => "/"
```

From here, it's not too much of a leap to see how we could make our server more
dynamic and set it up to send back **different responses** based on the
**path**.

For example:

```rb
require 'rack'
require 'pry'

class App
  def call(env)
    path = env["PATH_INFO"]

    if path == "/"
      [200, { "Content-Type" => "text/html" }, ["<h2>Hello <em>World</em>!</h2>"]]
    elsif path == "/potato"
      [200, { "Content-Type" => "text/html" }, ["<p>Boil 'em, mash 'em, stick 'em in a stew</p>"]]
    else
      [404, { "Content-Type" => "text/html" }, ["Page not found"]]
    end
  end
end

run App.new
```

Try restarting the server, and make requests in the browser to see the
response change based on the path:

- [http://localhost:9292/](http://localhost:9292/)
- [http://localhost:9292/potato](http://localhost:9292/potato)
- [http://localhost:9292/home](http://localhost:9292/home)

This conditional logic based on the path (and also the HTTP verb, as we'll see
later) is known as **routing**, and it's is basically what web servers do all
day long. Rails, Sinatra, any web programming framework you can name: one of
their key features is to simplify and standardize how routing works so we can
focus on working with data and generating responses.

## Conclusion

Rack is a simple, low-level tool for writing servers in Ruby. Since it's such
a low-level tool, it can be challenging to build more complex applications with.
In the next lesson, we'll learn how to use Sinatra to help with some common
tasks when building a web server.

## Resources

- [Rack gem][rack]

[rack]: https://github.com/rack/rack
[http-status]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Status
