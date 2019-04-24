#!/usr/bin/env ruby

require 'greenlight'
require 'example_lib'

greenlight {

  load_data('test.yml')

  login(data['username'], data['password'])

  get("#{data['hosts']['some_api']}/persons").expect {
    assert(code == 200)
  }

}
