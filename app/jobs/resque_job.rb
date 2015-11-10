
class ResqueJob
  @queue = :server1

  def self.perform()      #
    img_job = ImageJob.new
    img_job.set_config
    img_job.execute
  end

end