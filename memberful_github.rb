require 'octokit'
require 'json'

class MemberfulGithub
  def call(env)
    request = Rack::Request.new(env)
    return unauthorized unless valid_key?(request.params['key'])

    json = JSON.parse env['rack.input'].read
    p json
    client = Client.new json
    response = client.handle

    [200, {"Content-Type" => "text/plain"}, [response.inspect]]
  end

  def valid_key?(key)
    ENV.fetch('MEMBERFUL_KEY') == key
  end

  def unauthorized
    [401, {"Content-Type" => "text/plain"}, ["key is incorrect"]]
  end

  class Client
    def initialize(json)
      @client = Octokit::Client.new(:access_token => ENV.fetch('GITHUB_TOKEN'))
      @json = json
    end

    def handle
      case @json.fetch('event')
      when 'order.purchased'
        order_purchased
      when 'order.refunded'
        order_refunded
      when 'subscription.deactivated', 'subscription.deleted'
        subscription_deactivated
      end
    end

    private
    def order_purchased
      username = @json.fetch('order').fetch('member').fetch('custom_field')
      add_member username
    end

    def order_refunded
      username = @json.fetch('order').fetch('member').fetch('custom_field')
      remove_member username
    end

    def subscription_deactivated
      username = @json.fetch('subscription').fetch('member').fetch('custom_field')
      remove_member username
    end

    def add_member(username)
      @client.add_team_membership ENV.fetch('TEAM_ID'), username
    end

    def remove_member(username)
      @client.remove_organization_membership(ENV.fetch('ORG_NAME'), user: username)
    end
  end
end
