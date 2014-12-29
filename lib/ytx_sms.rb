# 云通讯的短信通道
require 'rest-client'

class YTXSms
  VERSION = '2013-12-26'  
  SAND_BOX_BASE_URL = 'https://sandboxapp.cloopen.com:8883'
  BASE_URL = 'https://app.cloopen.com:8883'

  ACCOUNT_SID = '8a48b55149f50bf3014a13e1948115f5'
  AUTH_TOKEN = '065d2b2e99b44c95a25f9b1a9110fdb0'
  APP_ID = '8a48b55149f50bf3014a141852d2162f'

  MESSAGE_TEMPLATE_ID = '8552'

  attr_reader :request_at, :request_path, 
              :request_headers, :paramters, :sig, :authorization,
              :response, :requireds

  def initialize(paramters = {})
    @paramters = paramters
    @request_at = Time.now    
    @sig = degist_paramters
    @authorization = degist_account
    @request_path = "#{VERSION}/Accounts/#{ACCOUNT_SID}/SMS/TemplateSMS?sig=#{@sig}"
    @request_headers = {
      "Accept"          => "application/json",
      "Content-Type"    => "application/json;charset=utf-8",
      "Authorization"   => @authorization
    }
    @request = RestClient::Resource.new(BASE_URL, headers: @request_headers)
  end

  def send
    @requireds = {
      to: @paramters[:mobile],
      appId: APP_ID,
      templateId: MESSAGE_TEMPLATE_ID,
      datas: [@paramters[:message], '1']
    }.to_json

    @response = @request[@request_path].post requireds
    @response = @response.force_encoding('UTF-8')

    self
  end

  private

  def degist_account
    Base64.urlsafe_encode64("#{ACCOUNT_SID}:#{@request_at.strftime('%Y%m%d%H%M%S')}")
  end

  def degist_paramters
    Digest::MD5.hexdigest("#{ACCOUNT_SID}#{AUTH_TOKEN}#{@request_at.strftime('%Y%m%d%H%M%S')}").upcase
  end

  class << self
    def send(paramters)
      sms = new paramters
      sms.send
    end
  end
end