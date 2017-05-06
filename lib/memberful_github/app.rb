module MemberfulGithub
  class App
    def call(env)
      request = Rack::Request.new(env)
      return unauthorized unless valid_key?(request.params['key'])

      json = JSON.parse env['rack.input'].read
      puts "******* json params *******"
      p json
      client = Client.new json
      response = client.webhook json
      puts "******* response *******"
      p response

      [200, {"Content-Type" => "text/plain"}, [response.inspect]]
    end

    def valid_key?(key)
      ENV.fetch('MEMBERFUL_KEY') == key
    end

    def unauthorized
      [401, {"Content-Type" => "text/plain"}, ["key is incorrect"]]
    end
  end
end
