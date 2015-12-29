module UploadHelper
  def new_file_name
    "img#{Time.now.strftime("%y%m%d%H%M%S")}" #{SecureRandom.hex(10)}"
  end
end