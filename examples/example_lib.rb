require 'greenlight'

# we can wrap only the request in a function and use it afterwards
def login_request(username, password)
  post(data['hosts']['auth'] + '/login', {
      headers: {
          'Content-Type' => 'application/json'
      },
      body: {
          username: username,
          password: password
      }
  })
end


# ... or we can actually run the request as part of the function call
def login(username, password)
  resp = post(data['hosts']['auth'] + '/login', {
      headers: {
          'Content-Type' => 'application/json'
      },
      body: {
          username: username,
          password: password
      }
  }).expect {
    assert(code == 200)
    assert(body.is_a? Hash)
    assert(body.length > 0)
    assert(body.key?('token'))
  }

  # add this authorization header to all future requests
  add_header(:Authorization, "Bearer #{resp.body['token']}")
  resp
end
