
class ResqueJob
  #@@queue_class = :server1
  @queue = :server1

  def initialize
    #@queue = @@queue_class
  end

  def self.perform(*arg)
    #return false if arg.blank? || arg[0].blank?

    img_job = ImageJob.new(@queue)
    #img_job.set_config()
    img_job.execute
  end

end