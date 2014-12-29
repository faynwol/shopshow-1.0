# coding: utf-8
class BetaTestUserMailer < ActionMailer::Base
  default :from => 'no-reply@shopshow.com'

  def congratulation user
    mail(
      :to => "896472652@qq.com", 
      #:to => user.email,
      :subject => "您老获得内测资格，还不快嘚瑟下！"  ,
      :body => '恩 就是这样, 您老获得内测资格，赶紧加入我们的尚品秀吐槽群吧 QQ群号：115684632'    
    )
  end


end
