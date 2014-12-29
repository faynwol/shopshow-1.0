require 'xmpp4r'
require 'xmpp4r/httpbinding/client'

class JabberController < ApplicationController
  before_filter :login_required
  skip_before_action :verify_authenticity_token

  def prebind
    Jabber::debug = true

    client = Jabber::HTTPBinding::Client.new current_user.jid_bind('web')
    client.connect(Settings.bosh_service_url)
    client.auth current_user.ejabberd_password
    sid = client.instance_variable_get('@http_sid')
    rid = client.instance_variable_get('@http_rid')

    render json: {
      success: true,
      sid: sid, 
      rid: rid, 
      jid: current_user.jid 
    }
  end
end