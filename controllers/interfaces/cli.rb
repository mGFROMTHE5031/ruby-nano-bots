# frozen_string_literal: true

require_relative '../instance'
require_relative '../../static/gem'

module NanoBot
  module Controllers
    module Interfaces
      module CLI
        def self.handle!
          case ARGV[0]
          when 'version'
            puts NanoBot::GEM[:version]
            exit
          when 'help', '', nil
            puts ''
            puts "Nano Bots #{NanoBot::GEM[:version]}"
            puts ''
            puts '  nb - - eval "hello"'
            puts '  nb - - repl'
            puts ''
            puts '  nb cartridge.yml - eval "hello"'
            puts '  nb cartridge.yml - repl'
            puts ''
            puts '  nb - STATE-KEY eval "hello"'
            puts '  nb - STATE-KEY repl'
            puts ''
            puts '  nb cartridge.yml STATE-KEY eval "hello"'
            puts '  nb cartridge.yml STATE-KEY repl'
            puts ''
            puts '  nb - - cartridge'
            puts '  nb cartridge.yml - cartridge'
            puts ''
            puts '  nb - STATE-KEY state'
            puts '  nb cartridge.yml STATE-KEY state'
            puts ''
            puts '  nb version'
            puts '  nb help'
            puts ''
            exit
          end

          params = { cartridge_path: ARGV[0], state: ARGV[1], command: ARGV[2] }

          bot = Instance.new(
            cartridge_path: params[:cartridge_path], state: params[:state], stream: $stdout
          )

          case params[:command]
          when 'eval'
            params[:input] = ARGV[3..]&.join(' ')
            params[:input] = $stdin.read.chomp if params[:input].nil? || params[:input].empty?
            bot.eval(params[:input])
          when 'repl'
            bot.repl
          when 'state'
            pp bot.state
          when 'cartridge'
            puts YAML.dump(bot.cartridge)
          else
            raise "TODO: [#{params[:command]}]"
          end
        end
      end
    end
  end
end
