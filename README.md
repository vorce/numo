# Numo

Your RabbitMQ deadletter queue handler.

Will resend valid json messages to the out exchange if the message has never been seen before.
Saves other messages to a database. Messages can be saved for the following reasons:

- invalid json
- not a deadlettered message
- a message has been previously resent but ended up in the numo queue again

Inspiration: http://bitsuppliers.com/dead-lettering-with-rabbitmq-strategies/

Configuration options:

- Broker
- Queue to consume from
- Exchange to re-send to
- TODO: Number of times to re-send/queue a message before handling it. Currently 1
- TODO: Max size of cache
- TODO: TTL of cache entries. Currently 30 min

---

To start your Phoenix app:

  1. Install dependencies with `mix deps.get`
  2. Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  3. Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: http://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
