# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  include DebHelper
  include UploadHelper
  include CarrierWave::MiniMagick
  #include CarrierWave::RMagick
  #include Cloudinary::CarrierWave

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end
  # process convert: 'png'
  # Create different versions of your uploaded files:
  #process convert: 'jpg'
  #full_filename

  version :thumb200 do
    #process convert: 'png'
    process :resize_to_fit => [300, 300]
    process :resize_to_fill => [180, 180]
    process convert: 'jpg'
    def full_filename (for_file) # = model.logo.file)
      if (for_file.size == 29) && (for_file.index('img') == 0)
        "thumb200_img.jpg"
      else
        [version_name, for_file].compact.join('_')
      end
    end
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    #"#{original_filename.split('.').first}.png" if original_filename
    #"img#{Time.now.strftime("%y%m%d%H%M%S")}#{SecureRandom.hex(10)}.#{original_filename.split('.').last}" if original_filename
    #original_filename if original_filename
    #"#{new_file_name}.#{original_filename.split('.').last}" if original_filename.present?
    "#{secure_token(10)}.#{file.extension}" if original_filename.present?
  end

  protected

  def secure_token(length=16)
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, "img#{Time.now.strftime("%y%m%d%H%M%S")}#{SecureRandom.hex(length/2)}")
  end

end
