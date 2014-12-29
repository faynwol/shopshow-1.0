#= require jquery.ui.widget 
#= require jquery.fileupload 
#= require jquery.iframe-transport

App.Products =
  maxUpload: 9

  init: ->
    # 上传产品图片
    $('#uploadButton').fileupload
      url: '/delivery/materials'
      dataType: 'json'
      formData: { live_show_id: $('#product_live_show_id').val() }

      add: (e, data) =>
        uploaded_ids = this.getUploadedMaterialIds()

        loading = $('.photos').data "loading_image"
        # 上传图片的item模板
        uploadTemplate = """
          <li class="pull-left mr-10 mb-10">
            <img src="#{loading}" width="120" height="120"/>
            <div class="btns">
              <button class="btn btn-warning btn-block btn-xs">
                <i class="fa fa-check"></i>
                <span>设为封面</span>
              </button>
              <button class="btn btn-default btn-block btn-xs">
                <i class="fa fa-trash"></i>
                <span>删除</span>
              </button>                
            </div>
            <div class="cover-icon"></div>
          </li>  
        """        

        if uploaded_ids.length >= this.maxUpload
          alert "你最多可以上传 #{this.maxUpload} 张图片"
          return false

        if data.files and data.files[0]
          data.context = $(uploadTemplate)
          $('.photos > ul').prepend data.context
          data.submit()

      done: (e, data) =>
        data.context.find('img').attr 'src', data.result.material.resource.thumb.url
        data.context.attr 'id', data.result.material.id

        uploaded_ids = this.getUploadedMaterialIds()
        if uploaded_ids.length >= this.maxUpload
          return false

        $('#product_picture_ids').val uploaded_ids.join(',')

      fail: (e, data) ->
        data.context.remove()

    # 提交表单前检查是否上传了图片
    $('.products-edit form, .products-new form').submit =>
      $('#product_picture_ids').val this.getUploadedMaterialIds().join(",")
      if this.getUploadedMaterialIds().length == 0
        alert "至少需要上传一张商品图片"
        return false
      return true

    # 删除已上传的图片
    $(".photos > ul").on "click", ".btns > .btn-default", ->
      $(this).parents("li").remove()

    # 设置产品封面图片
    $(".photos > ul").on "click", ".btns > .btn-warning", ->
      $li = $(this).parents("li")
      $li.addClass "is-cover"
      $(".photos > ul li").not($li).removeClass "is-cover"
      $("#product_cover_id").val $li.attr('id')

  # 计算结算价格
  computeClearningPrice : () ->
    $("#product_price").keyup ->
      val = $(this).val()
      $price = $(this).parents('.form-group').find('.text-danger')
      if val == ""
        $price.text "￥0"
      else
        $price.text "..."
      params = { product_price: val }
      $.post "/delivery/live_shows/#{$('#product_live_show_id').val()}/clearing_price", params, (res) ->
        $price.text "￥#{res.clearing_price}"
      , 'json'

  # 返回已上传的图片id
  getUploadedMaterialIds: () ->
    $('.photos > ul li').map ->
      $(this).attr 'id'
    .get()

$(document).ready ->
  App.Products.init()
  App.Products.computeClearningPrice()
