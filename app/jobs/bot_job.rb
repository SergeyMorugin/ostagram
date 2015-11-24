class BotJob
  include DebHelper
  include ConstHelper
  include WorkerHelper


  def initialize
    @worker_name = :bot1
    @admin_email = "cmorugin@gmail.com"
  end



  def execute

    log('-----------------------Start-------------------')
    adm = Client.find_by(email: @admin_email)
    log("Admin_id = #{adm.id}")
    loop do
      sleep 10
      log('------Loop start-------')
      if !check_idle
        log("Queue busy")
        next
      end
      ci = get_random_content
      if ci.nil?
        log("No content")
        next
      end
      si = get_random_style
      if si.nil?
        log("No style")
        next
      end
      log("Content: #{ci.attributes}")
      log("Style: #{si.attributes}")
      qi = QueueImage.new
      qi.status = STATUS_NOT_PROCESSED
      qi.end_status = STATUS_VISIBLE_FOR_BOT
      qi.content_id = ci.id
      qi.style_id = si.id

      qi.client_id = adm.id
      qi.save

      start_workers
      log("Queue: #{qi.attributes}")
      log('----------Loop stop----------')
      #
      #break
    end
  end

  private

  def check_idle
    q = QueueImage.where("status = #{STATUS_NOT_PROCESSED} or status = #{STATUS_IN_PROCESS}")
    q.count == 0
  end

  def get_random_style
    si = Style.where(status: BOT_STYLE_IMAGE)
    count = si.count
    return nil if count == 0
    r = rand(count)
    si[r]
  end

  def get_random_content
    ci = Content.where(status: BOT_CONTENT_IMAGE)
    count = ci.count
    return nil if count == 0
    r = rand(count)
    ci[r]
  end

   def log(msg)
     write_log(msg, @worker_name.to_s)
   end


end