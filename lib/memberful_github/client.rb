require 'octokit'
require 'json'
require 'open-uri'

module MemberfulGithub
  class Client
    def initialize(subdomain=ENV.fetch('MEMBERFUL_SUBDOMAIN'), token=ENV.fetch('MEMBERFUL_API_TOKEN'))
      @github = Octokit::Client.new(:access_token => ENV.fetch('GITHUB_TOKEN'))
      @subdomain = subdomain
      @token = token
    end

    def webhook(json)
      case json.fetch('event')
      when 'order.purchased'
        order_purchased json
      when 'order.refunded'
        order_refunded json
      when 'subscription.deactivated', 'subscription.deleted'
        subscription_deactivated json
      end
    end

    def member_details(id)
      JSON.parse(open(member_url(id)).read).tap do |details|
        details['member']['github'] = details.fetch('member').fetch('custom_field')
          .split('/').last # in case they provide URL
          .split('@').last # in case they include @ in the name
      end
    end

    def member_url(id)
      "https://#{@subdomain}.memberful.com/admin/members/#{id}.json?auth_token=#{@token}"
    end

    def order_purchased(json)
      id = json.fetch('order').fetch('member').fetch('id')
      add_member member_details(id).fetch('member').fetch('github')
    end

    def order_refunded(json)
      id = json.fetch('order').fetch('member').fetch('id')
      remove_member member_details(id).fetch('member').fetch('github')
    end

    def subscription_deactivated(json)
      id = json.fetch('subscription').fetch('member').fetch('id')
      remove_member member_details(id).fetch('member').fetch('github')
    end

    def add_member(username)
      @github.add_team_membership ENV.fetch('TEAM_ID'), username
    end

    def remove_member(username)
      @github.remove_organization_membership(ENV.fetch('ORG_NAME'), user: username)
    end
  end
end
