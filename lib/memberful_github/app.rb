module MemberfulGithub
  class App
    def call(env)
      request = Rack::Request.new(env)
      return unauthorized unless valid_token?(request.params['token'])

      json = JSON.parse env['rack.input'].read
      puts "******* json params *******"
      p json
      client = Client.new json
      response = client.webhook json
      puts "******* response *******"
      p response

      [200, {"Content-Type" => "text/plain"}, [response.inspect]]
    end

    def valid_token?(token)
      ENV.fetch('MEMBERFUL_WEBHOOK_TOKEN') == token
    end

    def unauthorized
      [401, {"Content-Type" => "text/plain"}, ["key is incorrect"]]
    end
  end
end
