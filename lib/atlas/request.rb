require 'typhoeus'
require 'json'

require 'atlas/injector'
require 'atlas/console'

module Atlas

  class RequestException < StandardError; end
  class AssertionException < StandardError; end

  class RequestResponse
    attr_accessor :body, :headers, :raw_body, :total_time, :code
  end

  class Request

    # request description
    attr_accessor :url, :options

    # request response
    attr_accessor :response

    # response structure with json parsed body
    attr_accessor :req_response

    # request assertions
    attr_accessor :expectations

    # count assertions to report the index of the failed one
    attr_accessor :assert_no


    def initialize(url, options)
      self.url = url
      self.options = options
      self.expectations = []
    end

    # define list of expectations (assertions)
    def expect(&block)
      self.expectations = block
      run
    end

    def _debug_info
      if code != 0
        info "response status code: #{code}"
      else
        info "library returned: #{response.return_code}"
      end
      info "request body: #{options[:body]}"
      info "request headers: #{options[:headers]}"
      info "response body: #{body}"
      info "response headers: #{response.headers}"

    end

    # define assertion
    def assert(condition)
      unless condition
        error "assertion no. #{assert_no} failed"
        _debug_info
        raise AssertionException
      end

      self.assert_no = assert_no + 1
    end

    # assertion helpers
    def header(name)
      response.headers[name]
    end

    def headers
      response.headers
    end

    def code
      response.code
    end

    def raw_body
      response.body
    end

    def body
      req_response.body
    end

    def total_time
      response.total_time
    end

    # run the request and evaluate expectations
    def run

      action Colors.grey("REQUEST ") + Colors.light_blue("#{options[:method].upcase} #{url}")
      Console.instance.indent
      # run the request
      options[:ssl_verifypeer] = false
      options[:followlocation] = true

      Injector.decorate(options)

      # convert all headers keys to strings to avoid having symbols like :"header" when
      # declaring headers with colons instead of arrows
      if options.key?(:headers)
        new_opts = {}
        options[:headers].map do |k, v|
          new_opts[k.to_s] = v
        end
        options[:headers] = new_opts
      end

      if options.key?(:headers) and options[:headers].key?('Content-Type')
        ctype = options[:headers]['Content-Type']
        if ctype.include?('application/json')
          # automatically encode json content
          options[:body] = JSON.generate(options[:body], quirks_mode: true)
        end
      end



      self.response = Typhoeus::Request.new(url, options).run

      self.req_response = RequestResponse.new.tap { |r|
        r.raw_body = response.body
        r.headers = response.headers
        r.code = response.code
        r.total_time = response.total_time

        if !r.headers.nil? && r.headers.key?('Content-Type') && r.headers['Content-Type'].include?('application/json')
          r.body = JSON.parse(response.body)
        else
          r.body = response.body
        end
      }

      # reset assertion counter
      self.assert_no = 1

      # evaluate response against expectations
      begin
        instance_eval(&expectations)
      rescue AssertionException
        error error_msg + " at #{expectations.source_location}"
        raise RequestException
      rescue StandardError => e
        error 'Exception ' + e.message
        info e.backtrace.inspect
        _debug_info
        error error_msg
        raise RequestException
      ensure
        Console.instance.unindent
      end

      req_response

    end

    def error_msg
      "REQUEST '#{options[:method].upcase} #{url}' failed"
    end
  end
end
