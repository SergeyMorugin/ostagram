module WorkerHelper
  public
  def start_workers
    worker_name = :server1

    if true #debug
      if Resque.size(worker_name) == 0
        #ResqueJob.queue_class = worker_name
        Resque.enqueue(ResqueJob, worker_name)
      end
      #@result = Resque.size(:server1).to_s
    else
      ResqueJob.perform(worker_name)
      #pri = ImageJob.new(:s2)
      #@result = pri.execute
    end
  end
end