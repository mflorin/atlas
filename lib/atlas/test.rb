require 'lib/console'
require 'lib/request'
require 'lib/library'

module Atlas
  class TestException < StandardError; end

  class Test
    attr_accessor :name
    attr_accessor :body
    attr_accessor :args

    def initialize(name, &block)
      self.name = name
      self.body = block
    end

    def run(args = {})
      action Colors.white("TEST ") + Colors.yellow(name)
      Console.instance.indent
      begin
        ret = Atlas.eval(args, &body)
        success('test succeeded')
        ret
      rescue RequestException
        error error_msg
        raise TestException
      rescue LibraryException
        error error_msg
        raise TestException
      rescue StandardError => e
        error e.backtrace.inspect
        error e.message
        error error_msg
        raise TestException
      ensure
        Console.instance.unindent
      end
    end

    def error_msg
      "TEST '#{name}' failed"
    end
  end
end
