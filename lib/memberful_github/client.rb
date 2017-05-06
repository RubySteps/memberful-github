require 'octokit'
require 'json'

module MemberfulGithub
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
