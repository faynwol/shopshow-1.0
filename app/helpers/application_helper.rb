module ApplicationHelper
  def current_info_as_json(live_show)
    info = { room: live_show.room_jid, live_show_id: live_show.id }
    user = { id: current_user.id, name: current_user.name, jid: current_user.jid }
    bosh_service_url = Settings.bosh_service_url
    info.merge! user: user, bosh_service_url: bosh_service_url
    javascript_tag("window.current=#{info.to_json};")
  end
end
