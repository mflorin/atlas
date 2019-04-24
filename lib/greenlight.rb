require 'greenlight/console'
require 'greenlight/request'
require 'greenlight/test'
require 'greenlight/scenario'
require 'singleton'
require 'yaml'
require 'json'
require 'typhoeus'

module Greenlight
  class Runner
    include Singleton

    attr_accessor :params, :data

    ATLAS_ENV_PREFIX = 'greenlight'
    ATLAS_ENV_SEPARATOR = '_'

    private
    def load_data_url(uri)
      resp = Typhoeus::Request.new(uri, {}).run
      if resp.code == 200
        case resp.headers['Content-Type'].split(';')[0]
        when 'application/json'
          JSON.parse(resp.body)
        when 'text/yaml'
          YAML.load(resp.body)
        else
          error 'unsupported data file format; only json and yaml are supported'
          error resp.headers['Content-Type'] + ' found'
          failure
        end

      else
        error "loading test data from #{uri} failed with code #{resp.code}"
        failure
      end

    end

    def load_data_file(uri)
      ext = File.extname(uri)
      case ext
      when '.json'
        JSON.parse(File.read(uri))
      when '.yml'
        YAML.load_file(uri)
      else
        error 'unsupported file format: ' + ext
        error 'only .json and .yml are supported'
      end
    end

    def env_override(env_var)
      ptr = data
      parts = env_var.split(ATLAS_ENV_SEPARATOR)
      parts[1, parts.length - 2].each do |p|
        if ptr[p].is_a? Hash
          ptr = ptr[p]
        else
          ptr[p] = {}
          ptr = ptr[p]
        end
      end

      ptr[parts[parts.length - 1]] = ENV[env_var]
    end

    def load_env
      ENV.keys.each do |k|

        next unless k.start_with?(ATLAS_ENV_PREFIX + ATLAS_ENV_SEPARATOR)
        env_override(k)

      end
    end

    public

    %w[post get options delete put patch].each do |method|
      define_method(method.to_s) do |url, options = {}|
        options[:url] = url
        options[:method] = method.to_sym
        req = Request.new url, options
        req
      end
    end

    def initialize
      self.params = {}
      self.data = {}
    end

    def load_data(uri, overwrite = false)
      info "loading data from #{uri}"
      if uri.start_with?('http://', 'https://')
        new_data = load_data_url(uri)
      else
        new_data = load_data_file(uri)
      end

      if overwrite
        self.data = new_data
      else
        self.data.merge!(new_data)
      end

      load_env
      new_data
    end

    def test(name, &block)
      Test.new(name, &block).run
    end

    def scenario(name, &block)
      Scenario.new(name, &block).run
    end

    def add_header(header, value)
      Injector.instance.add_header(header, value)
    end

    def rm_header(header)
      Injector.instance.rm_header(header)
    end

    def add_headers(headers)
      headers.each do |key, val|
        Injector.instance.add_header(key, val)
      end
    end

  end

  def self.eval(params, &block)
    runner = Runner.instance
    runner.params = params
    runner.instance_eval(&block)
  end
end

def greenlight(&block)
  begin
    Greenlight.eval({}, &block)
  rescue Greenlight::LibraryException
    failure
  rescue Greenlight::ScenarioException
    failure
  rescue Greenlight::TestException
    failure
  rescue Greenlight::RequestException
    failure
  rescue StandardError => e
    info e.backtrace.inspect
    error e.message
    failure
  end
end

def failure
  error 'TEST RUN FAILED'
  abort
end
