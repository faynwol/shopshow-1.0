namespace :notify do
  desc "no live show is about to begin"
  task :live_begin => :environment do
    LiveShow.where( {start_time: (Time.now - 5.minute)..Time.now } ) do |liveshow|            
      #TODO 
      LiveShow.delay.jpush_notify alert: "#{liveshow.subject} 直播间马上开始了！开始时间:#{liveshow.start_time}"

    end
  end


end