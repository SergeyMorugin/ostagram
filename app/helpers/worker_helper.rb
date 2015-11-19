module WorkerHelper
  public
  def start_workers
    worker_name = :server1

    if false#debug
      if Resque.size(worker_name) == 0
        #ResqueJob.queue_class = worker_name
        Resque.enqueue(ResqueJob, worker_name)
      end
      #@result = Resque.size(:server1).to_s
    else
      img_job = ImageJob.new(:server1)
      #img_job.set_config()
      img_job.execute_debug
      #ResqueJob.perform(worker_name)
      #pri = ImageJob.new(:s2)
      #@result = pri.execute
    end
  end
end