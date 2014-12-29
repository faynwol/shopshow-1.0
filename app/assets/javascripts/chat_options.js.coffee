#= require materials

chat = null
audio = null

$(window).bind 'beforeunload', ->
  if chat?
    chat.disconnect()

$(document).ready ->
  # Init chat client
  chat = new App.Chat(window.current.room, window.current.user.name)
  chat.attach()

  # Chat
  $('.sendMessage').click ->
    message = $('.messageBody').val()
    chat.send message
    $('.messageBody').val(' ')

  # Play audio
  $('.chattings').on 'click', '.message .body .audio', ->
    audio.pause() if audio?

    $this = $(this)
    $('.body .audio').removeClass 'playing'
    $this.addClass 'playing'

    audio_url = $(this).data "audio_url"
    audio = new Audio(audio_url)
    audio.play()

    audio.onended = =>
      $this.removeClass 'playing'

  # Show product form
  $('.products-list .btn-success').click ->
    $('.products-list').addClass 'hide'
    $('.product-form').removeClass 'hide'

  # Back to product list
  $('.backToProductList').click ->
    $('.products-list').removeClass 'hide'
    $('.product-form').addClass 'hide'

  # Publish product from product list
  $('.products-list').on 'click', 'table a.publishProduct', ->
    product_id = $(this).data "product_id"
    url = "/cpanel/products/#{product_id}/publish"
    $btn = $(this)

    $.post url, (res) ->
      chat.send product_id, 'Product'
      $btn.replaceWith('<span>已发布</span>')
    , 'json'

  # Query chat room occupants
  $('.queryQccupants').click ->
    chat.updateOccupants()

  # Kick user
  $('#Chat .occupants table').on 'click', 'a.kickUser', ->
    nickname = $(this).parents('tr').find('td:first').text()
    if confirm("Kickout #{nickname}, sure?")
      chat.kick nickname

  # List all products when click the Products tab
  $('.tab-header a[data-toggle="tab"]').on 'shown.bs.tab', (e) ->
    pane = $(e.target).attr 'href'
    if pane == "#Products"
      url = "/cpanel/live_shows/#{window.current.live_show_id}/products"
      $.get url, (res) ->
        $(pane).find('.products-list').find('table').remove()
        $(pane).find('.products-list').append res
      , 'html'

  # Add Product
  $('.postProduct').click ->
    $this = $(this)
    $this.button 'Loading...'

    properties = {}
    $('.form-group.property').each ->
      name = $.trim $(this).find('input.name').val()
      value = $.trim $(this).find('input.value').val()
      if name.length > 0 and value.length > 0
        properties[name] = value

    if $('#status').is(':checked')
      status = "published"
    else
      status = "preset"

    params = {
      product: {
        name_en:          $('#name_en').val()
        name_cn:          $('#name_cn').val()
        description:      $('#description').val()
        price:            $('#price').val()
        currency:         $('#currency').val()
        tax_rate:         $('#tax_rate').val()
        brand_en:         $('#brand_en').val()
        brand_cn:         $('#brand_cn').val()
        live_show_id:     $('#live_show_id').val()
        picture_ids:      $('#picture_ids').val()
        status:           status
        props:            properties
      }
    }

    if params.product.description.length == 0
      alert 'Product description cannot be blank'
      $this.button 'reset'
    else if params.product.name_en.length == 0
      alert 'Product en name cannot be blank'
      $this.button 'reset'
    else if params.product.price.length == 0
      alert 'Product price cannot be blank'
      $this.button 'reset'
    else if params.product.picture_ids.length == 0
      alert 'Please upload one picture at least'
      $this.button 'reset'

    else
      $.post '/cpanel/products', params, (res) ->
        if res.success
          if res.product.status == 'published'
            chat.send(res.product.id, 'Product') # send product to current chatroom.
            $('#chatTab').tab 'show'
          else
            alert '产品创建成功，暂未发布'
        $this.button 'reset'        
      , 'json'

  # Fuck this.
  $('#name_cn').focus ->
    $(this).val $('#description').val()

  $('a#orders-tab').click ->
    $('#orders').removeClass('sr-only')
    $('#shopping-lists').addClass('sr-only')
    $(this).addClass('btn-primary')
    $('a#shopping-list-tab').removeClass('btn-primary')

  $('a#shopping-list-tab').click ->
    $('#orders').addClass('sr-only')
    $('#shopping-lists').removeClass('sr-only')  
    $(this).addClass('btn-primary')
    $('a#orders-tab').removeClass('btn-primary')   
