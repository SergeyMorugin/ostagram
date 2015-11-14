module DebHelper

  def write_log(str,prefix = "")
    log_file = Rails.root.join("tmp/#{prefix}_deb.log")
    File.open(log_file,'a'){|file| file.write("#{Time.now.to_s}] #{str}\n")}
  end
end