#= require strophe.min
#= require strophe.muc

class App.Chat
  @prebind_url = '/jabber/prebind'
  @bosh_service_url = window.current.bosh_service_url
  @audio = null
  @aliyun_host = 'http://shopshow.oss-cn-hangzhou.aliyuncs.com/'
  @current_user_id = window.current.user.id
  @live_show_id = window.current.live_show_id

  constructor: (@roomname, @nickname) ->
    if @connection?
      @connection.disconnect()

    @connection = new Strophe.Connection(Chat.bosh_service_url)

  status = (flag) ->
    $('.connect-status span').text flag

  attach: () =>
    status 'Preparing...'

    $.post Chat.prebind_url, (resp) =>
      @connection.attach resp.jid, resp.sid, resp.rid + 1, @_onConnect

  disconnect: () =>
    @connection.disconnect()

  send: (message, type = "AdminText") =>
    if type == "AdminText"
      tree = """
        <CellType>AdminText</CellType>
        <Content>#{message}</Content>
      """
    else if type == "Product"
      tree = """
        <CellType>Product</CellType>
        <ProductID>#{message}</ProductID>
      """

    suffix = """
      <UserID>#{Chat.current_user_id}</UserID>
      <LiveShowID>#{Chat.live_show_id}</LiveShowID>  
    """

    tree = "#{tree}#{suffix}"
    tree = tree.replace(/\n/g, '')
    @connection.muc.groupchat @roomname, tree, null, null

  updateOccupants: () =>
    @connection.muc.queryOccupants @roomname, (tree) ->
      items = tree.getElementsByTagName 'item'
      $table = $('#Chat .occupants table')
      $table.find('tbody').empty()

      for item, i in items
        name = item.getAttribute 'name'
        body = """
          <tr>
            <td>#{name}</td>
            <td></td>
            <td>
              <a href="#this" class="kickUser">
                <i class="fa fa-sign-out"></i><span class="ml-2">Kick</span>
              </a>
            </td>
          </tr>
        """
        $table.find('tbody').append body

    , null

  kick: (nickname) ->
    @connection.muc.kick @roomname, nickname, "no reason"

  _onConnect: (state) =>
    switch state
      when Strophe.Status.CONNECTING
        status 'Connecting to server...'
      when Strophe.Status.CONNFAIL
        status 'Failed to connect.'
      when Strophe.Status.DISCONNECTING
        status 'Disconnecting...'
      when Strophe.Status.DISCONNECTED
        status 'Disconnected.'
      when Strophe.Status.CONNECTED, Strophe.Status.ATTACHED
        status 'Connected.'

        @connection.muc.join @roomname, @nickname, @_onMessage, @_onPresence
        # @connection.addHandler onMessage, null, 'message', null, @roomname, null
        # @connection.send $pres.tree()
      else
        @connection.disconnect()

  _onPresence: (message) =>
    @updateOccupants()

  _onMessage: (message) =>
    try
      to = message.getAttribute 'to'
      from = message.getAttribute 'from'
      type = message.getAttribute 'type'
      elems = message.getElementsByTagName 'body'

      if elems.length > 0 && type == 'groupchat'
        recv = Strophe.getText(elems[0]).replace /\n/g, ''
        return true if recv.indexOf('CellType') < 0

        message_type = recv.match(/&lt;CellType&gt;(.*?)&lt;\/CellType&gt;/)[1]
        message_body = @_formatBubbleContent message_type, recv
        bubble = @_makeBubble from, message_body

        $('.chattings').append bubble
        $('.chattings')[0].scrollTop = $('.chattings')[0].scrollHeight

        if message_type == 'Product'
          product_id = recv.match(/&lt;ProductID&gt;(.*?)&lt;\/ProductID&gt;/)[1]
          @_findProductBy(product_id)
      true
    finally
      true

  _formatBubbleContent: (message_type, message) =>
    switch message_type
      when 'AdminText', 'UserText'
        text = message.match(/&lt;Content&gt;(.*?)&lt;\/Content&gt;/)[1]

        message_body = """
          <div class="text">
            #{text}
          </div>
        """
      when 'AdminImage'
        image_path = message.match(/&lt;ImageID&gt;(.*?)&lt;\/ImageID&gt;/)[1]
        image_url = "#{Chat.aliyun_host}#{image_path}"

        message_body = """
          <div class="picture">
            <a href="#{image_url}" target="_blank">
              <img src="#{image_url}" />
            </a>
          </div>
        """
      when 'AdminVoice'
        audio_path = message.match(/&lt;VoiceID&gt;(.*?)&lt;\/VoiceID&gt;/)[1]
        audio_url = "#{Chat.aliyun_host}#{audio_path}"

        message_body = """
          <div class='audio' data-audio_url="#{audio_url}">
            <i class="fa fa-volume-up fa-2x"></i>
          </div>
        """
      when 'AdminVideo'
        video_path = message.match(/&lt;VideoID&gt;(.*?)&lt;\/VideoID&gt;/)[1]
        video_url = "#{Chat.aliyun_host}#{video_path}"

        message_body = """
          <div class='video'>
            <video src="#{video_url}" controls="controls"></video>
          </div>        
        """
      when 'Product'
        product_id = message.match(/&lt;ProductID&gt;(.*?)&lt;\/ProductID&gt;/)[1]

        message_body = """
          <div class="product product-#{product_id}" data-product_id="#{product_id}">
            <div class="loading">
              <i class="fa fa-circle-o-notch fa-spin fa-2x"></i>
            </div>
          </div>
        """
      else
        message_body = message

    message_body

  _makeBubble: (from, msg) =>
    if from.indexOf('im') > 0
      from = from.split('/')[1]
    else
      from = from.split('@')[0]

    if from == @nickname
      klass = 'to'
      pull = 'left'
    else
      klass = 'from'
      pull = 'right'

    """
      <div class='#{klass} message clearfix'>
        <a class='pull-#{pull} name' href='#'>#{from}</a>
          <div class='pull-#{pull} body'>#{msg}</div>
      </div>
    """

  _findProductBy: (id) =>
    $product = $(".product-#{id}") 
    $.get "/cpanel/products/#{id}", (res) ->
      $product.html res
    , 'html'
