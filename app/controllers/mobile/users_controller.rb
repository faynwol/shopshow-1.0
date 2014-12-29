class Mobile::UsersController < Mobile::AppController  
  def new
    @user = User.new
  end

  def create
    begin
      User.transaction do
        @user = User.new
        @user.name = params[:name]
        @user.username = @user.name
        @user.password = params[:password]
        @user.phone = params[:phone]
        if @user.valid?
          @user.save!
          @user.ensure_private_token!
          balance = @user.build_user_balance
          balance.user_id = @user.id
          balance.save!
          render json: { success: true, user: @user.as_json }
        else
          render json: { success: true, message: @user.errors.full_messages.first }
        end
      end
    rescue Exception => e
      ExceptionNotifier.notify_exception e, env: request.env, 
                                            data: { message: "注册用户出错啦！" }
      render json: { success: false, message: '>_< 注册的过程中出错了，请再试一下' }
    end
  end

  def regist_succeed
    user = User.find_by private_token: params[:token]
    pick_cols = %i( id name jid email created_at private_token)
    avatar = user.avatar_url(:middle)
    if avatar.blank?
      avatar = "http://115.29.167.37:9001#{avatar}"
    end
    balance = user.balance
    ret = user.as_json(only: pick_cols)
    ret = ret.merge(avatar: avatar, balance: balance, recipients: [])
    render json: ret
  end

  def send_code
    begin
      if User.find_by(phone: params[:phone])
        render json: { success: false, message: "该手机号已被注册了" }
      else
        message = MobileVerifyCode.new
        message.phone = params[:phone]
        message.save!
        YTXSms.send mobile: message.phone, message: message.body
        render json: { success: true, phone: message.phone }
      end
    rescue Exception => e
      ExceptionNotifier.notify_exception e, env: request.env, 
                                            data: { message: "发送短信验证码失败" }      
      render json: { success: false, message: '验证码发送失败' }
    end
  end

  def verify_code
    code = MobileVerifyCode.find_by(body: params[:code])
    if code && code.is_valid?
      code.active!
      render json: { success: true, phone: code.phone }
    else
      render json: { success: false, message: '验证码是无效的或已过期' }
    end
  end

  def check_name
    exists = User.find_by(name: params[:name]).exists?
    render json: { exists: exists }
  end
end