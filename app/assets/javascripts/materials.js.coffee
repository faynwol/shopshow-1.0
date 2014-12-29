#= require jquery.ui.widget 
#= require jquery.fileupload 
#= require jquery.iframe-transport
#= require artDialog-without-seajs/popup
#= require artDialog-without-seajs/dialog

$(document).ready ->
  # Upload picture
  $('#product_picture').fileupload
    url: '/cpanel/materials'
    dataType: 'json'
    formData: { live_show_id: $('#live_show_id').val() }

    add: (e, data) ->
      if data.files and data.files[0]
        context = """
          <div class="pic">
            <div class="remove"></div>
          </div>
        """

        data.context = $(context)
        data.context.appendTo('.picture-lists')
        data.submit()

    done: (e, data) ->
      img = """
        <img width="80" height="80" class="img-thumbnail" src="#{data.result.material.resource.thumb.url}" />
      """

      data.context.append img
      data.context.attr 'id', data.result.material.id

      picture_ids = setPictures()

      if picture_ids > 9
        alert 'You can upload at most 9 pictures at a time'
        return false

      $('#picture_ids').val picture_ids

    fail: (e, data) ->
      console.log "fail event triggered."

  # Set pictures
  setPictures = ->
    $('.picture-lists .pic').map ->
      $(this).attr 'id'
    .get().join(',')

  # Remove an uploaded picture
  $('.picture-lists').on 'click', '.pic .remove',  ->
    $(this).parents('.pic').remove()
    picture_ids = setPictures()
    $('#picture_ids').val picture_ids

  $('a#choose_uploaded_pic').click ->
    live_show_id = $(this).attr('live-show-id')
    dialog = artDialog
      width: 400
      title: "choose pictures"          
      bottom: '1%'

      onshow: ->
        $.get "/cpanel/live_shows/#{live_show_id}/choose_material", (res) =>
          _this.content(res)
        , 'html'

      onclose: ->
        picture_ids = setPictures()
        $('#picture_ids').val picture_ids        

      ok: =>        
        $('.material-panel.choosed').each ->
          $this = $(this)
          $img = $this.find('img')
          img_path = $img.attr('src')
          id = $img.attr('material-id')

          context = """
            <div class="pic" id="#{id}">
              <div class="remove"></div>
              <img width="80" height="80" class="img-thumbnail" src="#{img_path}" />
            </div>
          """         
          $(context).appendTo('.picture-lists')
        
      okValue: 'ok'
      cancel: ->
      cancelValue: 'cancel'

    dialog.showModal()