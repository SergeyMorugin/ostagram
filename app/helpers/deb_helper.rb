module DebHelper

  def write_log(str)
    log_file = Rails.root.join('tmp/deb_log.txt')
    File.open(log_file,'a'){|file| file.write("#{Time.now.to_s}] #{str}\n")}
  end
end