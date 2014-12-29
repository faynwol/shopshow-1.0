#= require 'mobile/app'

$(document).ready ->
  regex = {
    mobile: /^0?(13[0-9]|15[0-9]|18[0-9]|14[0-9])[0-9]{8}$/
    # name: /^([u4e00-u9fa5]|[ufe30-uffa0]|[a-za-z0-9_]){3,12}$/
    name: /^[\u4E00-\u9FA5A-Za-z0-9_]+$/
  }

  # 60 秒钟倒计时
  COUNTDOWN = 60
  count = COUNTDOWN
  $resend_btn = $('button.btn.resend')
  timer = null

  setCountDownTimer = ->
    timer = setInterval () ->
      count -= 1
      text = count
      text = "0#{count}" if count < 10
      $resend_btn.attr('disabled', 'disabled').text text
      if count == 0
        $resend_btn.removeAttr('disabled').text '重新发送'
        clearInterval timer
    , 1000

  resetCountDownTimer = ->
    if timer?
      count = COUNTDOWN
      clearInterval timer
    setCountDownTimer()

  # 发送短信验证码
  $('.step_1 .btn.send_code').click ->
    $this = $(this)
    phone = $.trim $('#phone').val()

    if not regex.mobile.test(phone)
      alert '您输入的手机号有误'
    else
      $this.text('发送中...').attr 'disabled', 'disabled'
      $.post '/mobile/users/send_code', phone: phone, (res) ->
        if res.success
          $('.step_1').hide()
          $('#code').attr 'placeholder', "验证码，已发送到 #{res.phone}"
          $('.step_2').show()
          setCountDownTimer()
        else 
          alert res.message
          $this.text('下一步').removeAttr 'disabled'
      , 'json'

  # 重发短信验证码
  $resend_btn.click ->
    phone = $.trim $('#phone').val()
    $.post '/mobile/users/send_code', phone: phone, (res) ->
      if res.success
        resetCountDownTimer()
      else
        alert res.message
    , 'json'

  # 校验短信验证码 
  $('.verify_code').click ->
    $this = $(this)
    code = $.trim $('#code').val()

    if code == ''
      alert '请输入您收到的4位验证码'
    else
      $this.attr 'disabled', 'disabled'
      $.post '/mobile/users/verify_code', code: code, (res) ->
        if res.success
          $('.step_2').hide()
          $('.step_3').find('#valid_phone').val res.phone
          $('.step_3').show()
        else
          alert res.message

        $this.removeAttr 'disabled'
      , 'json'

  # 提交注册
  $('.btn.create_user').click ->
    $this = $(this)
    name = $.trim $('#name').val()
    phone = $('#valid_phone').val()
    password = $('#password').val()

    if name == ''
      alert '昵称不能为空'
    else if !regex.name.test(name)
      alert '昵称不能包括除下划线外的特殊字符'
    else if name.length < 2 || name.length > 20
      alert '昵称的长度为 2-20 位字符'
    else
      params = {
        name: name
        phone: phone
        password: password
      }

      $this.text('注册中...').attr 'disabled', 'disabled'
      $.post '/mobile/users', params, (res) ->
        if res.success
          window.location.href = "/mobile/users/regist_succeed?token=#{res.user.private_token}"
        else
          alert res.message
      , 'json'
      

      























    
 