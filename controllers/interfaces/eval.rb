# frozen_string_literal: true

require 'pry'
require 'rainbow'

require_relative '../../logic/helpers/hash'
require_relative '../../logic/cartridge/affixes'

module NanoBot
  module Controllers
    module Interfaces
      module Eval
        def self.evaluate(input, cartridge, session)
          prefix = Logic::Cartridge::Affixes.get(cartridge, :eval, :output, :prefix)
          suffix = Logic::Cartridge::Affixes.get(cartridge, :eval, :output, :suffix)

          session.print(prefix) unless prefix.nil?

          session.evaluate_and_print(input, mode: 'eval')

          session.print(suffix) unless suffix.nil?
        end
      end
    end
  end
end
