#= require 'mobile/app'

$(document).ready ->
  private_token = $('#private_token').val()

 # click check button
  $('.list-group-item.product, .toggleAll').click ->
    $this = $(this).find ".circle"
    $checked = '<i class="fa fa-check"></i>'

    $this.toggleClass ->
      if $(this).is('.checked')
        $(this).parents('.list-group-item').removeClass 'selected'        
        $(this).empty();
      else
        $(this).parents('.list-group-item').addClass 'selected'        
        $(this).append($checked);
      return 'checked';

    if $this.parent().is('.toggleAll')
      if $this.is('.checked')
        $('.list-group-item.product').addClass 'selected'
        $('.circle').not($this).addClass('checked').empty().append($checked)
      else
        $('.list-group-item.product').removeClass 'selected'
        $('.circle').not($this).removeClass('checked').empty()

    reCalcAmountAndQuantity()

  # 进入编辑模式
  $('span.editMode').click ->
    $this = $(this)
    $this.toggleClass('editing')

    if $this.is('.editing')
      $this.text('完成');
      $('.list-group-item.product').find('.quantity').hide()
      $('.list-group-item.product').find('.remove').show()
      $('.go-check a.check').hide()
      $('.go-check a.destroy_all').show()
    else
      $this.text('编辑')
      $('.list-group-item.product').find('.quantity').show()
      $('.list-group-item.product').find('.remove').hide()        
      $('.go-check a.check').show()
      $('.go-check a.destroy_all').hide()

  # click plus button
  $('.reduce .btn').click ->
    $this = $(this)
    sku_id = $(this).parents('.list-group-item.product').data 'sku_id'
    $quantity = $this.parent().next('input')
    q = parseInt($quantity.val())

    if q > 1
      q = q - 1 
      $quantity.val(q)      
      updateCartItem sku_id, q

  # click minus button
  $('.increase .btn').click ->
    $this = $(this)
    sku_id = $(this).parents('.list-group-item.product').data 'sku_id'
    $quantity = $this.parent().prev('input')
    q = parseInt($quantity.val())

    if (q < 999)
      q = q + 1
      $quantity.val(q)      
      updateCartItem sku_id, q

  # 从购物车删除一项
  $('.remove .btn').click ->
    $this = $(this)
    $item = $this.parents('.list-group-item')
    good_id = $item.data 'good_id'

    params = {
      token: private_token
      good_id: good_id
    }

    loading = MobileApp.loading()
    $.post '/mobile/shopping_cart/remove', params, (res) ->
      if res.success
        $item.slideUp 'fast', ->
          $(this).remove()
          reCalcAmountAndQuantity()
          $(loading).remove()

  # 从购物车中删除多项
  $('a.destroy_all').click ->
    $this = $(this)
    good_ids = $('.list-group-item.product.selected').map ->
      $(this).data 'good_id'
    .get()

    params = {
      token: private_token
      good_ids: good_ids
    }

    loading = MobileApp.loading()
    $.post '/mobile/shopping_cart/remove_selected', params, (res) ->
      if res.success
        $('.list-group-item.product.selected').remove()
        reCalcAmountAndQuantity()
        $('span.editMode').click()
      else
        alert res.message
      $this.hide()
      $this.prev().show()
      $(loading).remove()
    , 'json'

  # 修改购物车里的商品数量
  updateCartItem = (sku_id, quantity, func = null) ->
    loading = MobileApp.loading()
    params = {
      token: private_token
      sku_id: sku_id
      quantity: quantity
    }

    $.post '/mobile/shopping_cart/update_item', params, (res) ->
      if res.success
        reCalcAmountAndQuantity()
        func.call() if func?
      else
        alert res.message
      $(loading).remove()
    , 'json'

  # 重新计算购物车商品总价和商品件数
  reCalcAmountAndQuantity = () ->
    total_amount = 0
    total_quantity = 0
    clearing_quantity = 0
    clearing_amount = 0

    loading = MobileApp.loading()

    $('.list-group-item.product').each ->
      quantity = $(this).find('.goodQuantity').val()
      price = $(this).find('.clearingPrice').text()
      sub_total = parseInt(price) * parseInt(quantity)

      if $(this).is('.selected')
        clearing_quantity += parseInt(quantity)
        clearing_amount += sub_total

      total_quantity += parseInt(quantity)
      total_amount += sub_total

    $('.clearingQuantity').text clearing_quantity
    $('.clearingAmount').text "#{clearing_amount}.0"
    $('.totalQuantity').text total_quantity
    $('.totalAmount').text "#{total_amount}.0" 

    $(loading).remove()

  # 结算
  $('.go-check .check').click ->
    good_ids = $('.list-group-item.product.selected').map ->
      $(this).data 'good_id'
    .get().join(',')

    if good_ids.length == 0
      alert '请选择需要结算的商品'
    else
      live_show_id = $('#live_show_id').val()
      window.location.href = "/mobile/shopping_cart/confirm?good_ids=#{good_ids}&live_show_id=#{live_show_id}&token=#{private_token}"

























