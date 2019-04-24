require 'singleton'

class Injector
  include Singleton

  attr_accessor :headers

  def initialize
    self.headers = {}
  end

  def add_header(header, value)
    self.headers[header] = value
  end

  def rm_header(header)
    self.headers.delete(header)
  end

  def self.decorate(options)
    options[:headers] = {} unless (options.key?(:headers) && options[:headers].is_a?(Hash))
    options[:headers].merge!(Injector.instance.headers)
    options
  end
end