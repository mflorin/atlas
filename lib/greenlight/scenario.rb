require 'greenlight/console'
require 'greenlight/request'
require 'greenlight/test'

module Greenlight

  class ScenarioException < StandardError; end

  class Scenario

    # tests - hash of tests
    attr_accessor :name, :body

    def initialize(name, &block)
      self.name = name
      self.body = block
    end

    def run
      action Colors.white("SCENARIO ") + Colors.light_magenta(name)
      Console.instance.indent
      ret = Greenlight.eval({}, &body)
      success('scenario succeeded')
      ret
    rescue RequestException
      error error_msg
      raise ScenarioException
    rescue TestException
      error error_msg
      raise ScenarioException
    rescue StandardError => e
      error e.backtrace.inspect
      error e.message
      error error_msg
      raise ScenarioException
    ensure
      Console.instance.unindent
    end

    def error_msg
      "SCENARIO '#{name}' failed"
    end
  end

end
