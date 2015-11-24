class BotResqueJob
  @queue = :job1

  def initialize

  end

  def self.perform(*arg)
    #return false if arg.blank? || arg[0].blank?

    bot_job = BotJob.new
    bot_job.execute
  end

end