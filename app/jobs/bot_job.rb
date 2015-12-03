class BotJob
  include DebHelper
  include ConstHelper
  include WorkerHelper


  def initialize
    @worker_name = :bot1
    @admin_email = "xxx@gmail.com"
    @sleep_time = 10
    @end_status = 11
    @debug = true
  end

  def set_config(bot_name)
    log "set config"
    return if bot_name.nil?
    @worker_name = bot_name
    file = Rails.root.join('config/config.secret')
    par = load_settings(file)
    par = par[bot_name.to_s]
    log "config: #{par.to_s}"
    return if par.blank?
    @admin_email = par["admin_email"]
    @sleep_time = par["sleep_time"]
    @user_priority = par["user_priority"]
    @end_status = par["end_status"]
    @debug = par["debug"]
    @admin = Client.find_by_email(@admin_email)
    log "admin_id: #{@admin.id}"
  end


  def execute
    log('-----------------------Start-------------------')
    loop do
      log('------Loop start-------')
      sleep @sleep_time
      log("sleep #{@sleep_time}")
      set_config(:bot1)
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
      qi = QueueImage.where("content_id = #{ci.id} and style_id = #{si.id} and status = #{STATUS_PROCESSED}")
      if qi.count > 0
        log("Queue exists")
        next
      end

      qi = QueueImage.new
      qi.status = STATUS_NOT_PROCESSED
      qi.end_status = @end_status
      qi.content_id = ci.id
      qi.style_id = si.id

      qi.client_id = @admin.id
      qi.save

      start_workers
      log("Queue: #{qi.attributes}")
      log('----------Loop end----------')
      #
      #break
    end
  end

  private

  def check_idle
    #q = QueueImage.where("status = #{STATUS_NOT_PROCESSED} or status = #{STATUS_IN_PROCESS}")
    if @user_priority
      q = QueueImage.where("status = #{STATUS_NOT_PROCESSED} or status = #{STATUS_IN_PROCESS}")
    else
      q = QueueImage.where("client_id = #{@admin.id} and status = #{STATUS_NOT_PROCESSED}")
    end
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
     write_log(msg, @worker_name.to_s) if @debug
   end


end