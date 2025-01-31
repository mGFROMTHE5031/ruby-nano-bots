# Nano Bots 💎 🤖

A Ruby implementation of the [Nano Bots](https://github.com/icebaker/nano-bots) specification.

![Ruby Nano Bots](https://user-images.githubusercontent.com/113217272/237839690-7880915a-b287-4484-a75e-0b96284b8a32.png)
_Image artificially created by Midjourney through a prompt generated by a Nano Bot specialized in Midjourney._

https://user-images.githubusercontent.com/113217272/238141567-c58a240c-7b67-4b3b-864a-0f49bbf6e22f.mp4

- [Setup](#setup)
  - [Docker](#docker)
- [Usage](#usage)
  - [Command Line](#command-line)
  - [Library](#library)
- [Cartridges](#cartridges)
- [Providers](#providers)
- [Debugging](#debugging)
- [Development](#development)
  - [Publish to RubyGems](#publish-to-rubygems)

## Setup

For a system usage:

```sh
gem install nano-bots -v 0.0.7
```

To use it in a project, add it to your `Gemfile`:

```ruby
gem 'nano-bots', '~> 0.0.7'
```

```sh
bundle install
```

For credentials and configurations, relevant environment variables can be set in your `.bashrc`, `.zshrc`, or equivalent files, as well as in your Docker Container or System Environment. Example:

```sh
export OPENAI_API_ADDRESS=https://api.openai.com
export OPENAI_API_ACCESS_TOKEN=your-token
export OPENAI_API_USER_IDENTIFIER=your-user

# export NANO_BOTS_STATE_DIRECTORY=/home/user/.local/state/nano-bots
# export NANO_BOTS_CARTRIDGES_DIRECTORY=/home/user/.local/share/nano-bots/cartridges
```

Alternatively, if your current directory has a `.env` file with the environment variables, they will be automatically loaded:

```sh
OPENAI_API_ADDRESS=https://api.openai.com
OPENAI_API_ACCESS_TOKEN=your-token
OPENAI_API_USER_IDENTIFIER=your-user

# NANO_BOTS_STATE_DIRECTORY=/home/user/.local/state/nano-bots
# NANO_BOTS_CARTRIDGES_DIRECTORY=/home/user/.local/share/nano-bots/cartridges
```

## Docker

Clone the repository and copy the Docker Compose template:

```
git clone git@github.com:icebaker/ruby-nano-bots.git
cd ruby-nano-bots
cp docker-compose.example.yml docker-compose.yml
```

Set your provider credentials and choose your desired directory for the cartridges files:

```yaml
version: '3.7'

services:
  nano-bots:
    image: ruby:3.2.2-slim-bullseye
    command: sh -c "gem install nano-bots -v 0.0.7 && bash"
    environment:
      OPENAI_API_ADDRESS: https://api.openai.com
      OPENAI_API_ACCESS_TOKEN: your-token
      OPENAI_API_USER_IDENTIFIER: your-user
    volumes:
      - ./your-cartridges:/cartridges
      # - ./your-data:/data
```

Enter the container:
```sh
docker compose run nano-bots
```

Start playing:
```sh
nb - - eval "hello"
nb - - repl

nb cartridges/assistant.yml - eval "hello"
nb cartridges/assistant.yml - repl
```

## Usage

### Command Line

After installing the gem, the `nb` binary command will be available for your project or system.

Examples of usage:

```bash
nb - - eval "hello"
# => Hello! How may I assist you today?

nb to-en-us-translator.yml - eval "Salut, comment ça va?"
# => Hello, how are you doing?

nb midjourney.yml - eval "happy cyberpunk robot"
# => A cheerful and fun-loving robot is dancing wildly amidst a
#    futuristic and lively cityscape. Holographic advertisements
#    and vibrant neon colors can be seen in the background.

nb lisp.yml - eval "(+ 1 2)"
# => 3

cat article.txt |
  nb to-en-us-translator.yml - eval |
  nb summarizer.yml - eval
# -> LLM stands for Large Language Model, which refers to an
#    artificial intelligence algorithm capable of processing
#    and understanding vast amounts of natural language data,
#    allowing it to generate human-like responses and perform
#    a range of language-related tasks.
```

```bash
nb - - repl

nb assistant.yml - repl
```

```text
🤖> Hi, how are you doing?

As an AI language model, I do not experience emotions but I am functioning
well. How can I assist you?

🤖> |
```

All of the commands above are stateless. If you want to preserve the history of your interactions, replace the `-` with a state key:

```bash
nb assistant.yml your-user eval "Salut, comment ça va?"
nb assistant.yml your-user repl

nb assistant.yml 6ea6c43c42a1c076b1e3c36fa349ac2c eval "Salut, comment ça va?"
nb assistant.yml 6ea6c43c42a1c076b1e3c36fa349ac2c repl
```

You can use a simple key, such as your username, or a randomly generated one:

```ruby
require 'securerandom'

SecureRandom.hex # => 6ea6c43c42a1c076b1e3c36fa349ac2c
```

### Debugging

```sh
nb - - cartridge
nb cartridge.yml - cartridge

nb - STATE-KEY state
nb cartridge.yml STATE-KEY state
```

### Library

To use it as a library:

```ruby
require 'nano-bots/cli' # Equivalent to the `nb` command.
```

```ruby
require 'nano-bots'

NanoBot.cli # Equivalent to the `nb` command.

NanoBot.repl(cartridge: 'cartridge.yml') # Starts a new REPL.

bot = NanoBot.new(cartridge: 'cartridge.yml')

bot = NanoBot.new(
  cartridge: YAML.safe_load(File.read('cartridge.yml'), permitted_classes: [Symbol])
)

bot = NanoBot.new(
  cartridge: { ... } # Parsed Cartridge Hash
)

bot.eval('Hello')

# When stream is enabled and available:
bot.eval('Hi!') do |content, fragment, finished|
  print fragment unless fragment.nil?
end

bot.repl # Starts a new REPL.

NanoBot.repl(cartridge: 'cartridge.yml', state: '6ea6c43c42a1c076b1e3c36fa349ac2c')

bot = NanoBot.new(cartridge: 'cartridge.yml', state: '6ea6c43c42a1c076b1e3c36fa349ac2c')
```

## Cartridges

Here's what a Nano Bot Cartridge looks like:

```yaml
---
meta:
  name: Nano Bot Name
  author: Your Name
  version: 0.0.1

behaviors:
  interaction:
    directive: You are a helpful assistant.

provider:
  name: openai
  settings:
    model: gpt-3.5-turbo
    credentials:
      address: ENV/OPENAI_API_ADDRESS
      access-token: ENV/OPENAI_API_ACCESS_TOKEN
      user-identifier: ENV/OPENAI_API_USER_IDENTIFIER
```

Check the Nano Bots specification to learn more about [how to build cartridges](https://icebaker.github.io/nano-bots/#/README?id=cartridges).

## Providers

Currently supported providers:

- [ ] [Vicuna](https://github.com/lm-sys/FastChat)
- [x] [Open AI](https://platform.openai.com/docs/api-reference)
- [ ] [Google PaLM](https://developers.generativeai.google/)
- [ ] [Alpaca](https://github.com/tatsu-lab/stanford_alpaca)
- [ ] [LLaMA](https://github.com/facebookresearch/llama)

## Development

```bash
bundle
rubocop -A
rspec
```

### Publish to RubyGems

```bash
gem build nano-bots.gemspec

gem signin

gem push nano-bots-0.0.7.gem
```
