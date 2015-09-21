# Numo

Your RabbitMQ deadletter queue handler. Where messages go to die.

Inspiration: http://bitsuppliers.com/dead-lettering-with-rabbitmq-strategies/

(Numo stands for National Undeliverable Mail Office)

## Consumers

These are processes that consumes messages from a specific rabbit queue and takes action. Many consumers can run at the same time, listening to different queues.

To add consumers to numo you add them to the consumers list under `config :numo, Consumers` in the config.exs file.

### Json consumer

This is currently the only consumer that exists, but can serve as a starting point for creating new ones.

The Json consumer will send valid json messages to the configured exchange if the message has never been seen before.
Other messages are saved to a database. Messages can be saved for the following reasons:

- invalid json
- not a deadlettered message
- a message that has been previously sent to the out exchange but ended up in the numo queue again

Some assumptions:

- The json contains an "id" field in its root OR
- The amqp message has a message_id property

If none of the above holds true for the messages you expect in the queue that the consumer listens to, then you need to create a new consumer (or hack this one) that can properly identify your messages.

Configuration options:

- Broker
- Queue to consume from
- Exchange to re-send to
- Throttle of resends (checks the size of given queue, and doesn't send if the size > specified number)
- TODO: Number of times to re-send/queue a message before handling it. Currently 1
- TODO: Max size of cache
- TTL of cache entries. Default is 30min (ttl check default 1min). This is global for all json consumers.


#### Web UI

[`localhost:4000`](http://localhost:4000) will list all running Json consumers.
The [`/messages`](http://localhost:4000/messages) endpoint will show the latest saved messages.

## Misc TODOs

- Build a docker image
- Tests
- Pluggable identification of messages
- Resend button

---

To start Numo:

  1. Install dependencies with `mix deps.get`
  2. Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  3. Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
