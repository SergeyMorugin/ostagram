class ImageJob
  include DebHelper
  include ConstHelper

  @worker_name = :bot1

  def execute
    loop do
      #sleep 2
      log('-----------------------Start-------------------')
      next if !check_idle
      ci = get_random_content
      next if ci.nil?
      si = get_random_style
      next if si.nil?
      log("Content: #{ci.attributes}")
      log("Style: #{si.attributes}")
      qi = QueueImage.new
      qi.status = STATUS_NOT_PROCESSED
      qi.end_status = STATUS_VISIBLE_FOR_BOT
      qi.content_id = ci.id
      qi.style_id = si.id
      qi.user_id = 1
      qi.save
      log("Queue: #{qi.attributes}")
      log('-----------------------Stop-------------------')
      #
      break
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
     write_log(msg, @worker_name)
   end

end