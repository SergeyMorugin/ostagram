# encoding: utf-8

class AvatarUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:

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
  process :resize_to_fit => [1600, 1600]

  version :thumb do
     #process convert: 'png'
     process :resize_to_fit => [150, 150]
     process :resize_to_fill => [100, 100]
     #cloudinary_transformation :effect => "brightness:30", :radius => 20,
     #                          :width => 100, :height => 100, :crop => :thumb, :gravity => :face

     process :round
     #format = "\( +clone -crop 16x16+0+0  -fill white -colorize 100% -draw 'fill black circle 15,15 15,0' -background Red  -alpha shape \( +clone -flip \) \( +clone -flop \) \( +clone -flip \)  \)"
     #process :convert => format

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
     original_filename if original_filename
   end

  def rounded_corners
    radius = 10
    manipulate! do |img|
      #create a masq of same size
      masq = Magick::Image.new(img.columns, img.rows)
      d = Magick::Draw.new
      d.roundrectangle(0, 0, img.columns - 1, img.rows - 1, radius, radius)
      d.draw(masq)
      img.composite(masq, 0, 0, Magick::LightenCompositeOp)
    end
  end

  def round
    manipulate! do |img|
      img.format 'png'

      width = img[:width]-2
      radius = width/6

      mask = ::MiniMagick::Image.open img.path
      mask.format 'png'

      mask.combine_options do |m|
        m.alpha 'transparent'
        m.background 'none'
        m.fill 'white'
        m.draw 'roundrectangle 1,1,%s,%s,%s,%s' % [width, width, radius, radius]
      end

      overlay = ::MiniMagick::Image.open img.path
      overlay.format 'png'

      overlay.combine_options do |o|
        o.alpha 'transparent'
        o.background 'none'
        o.fill 'none'
        o.stroke 'white'
        o.strokewidth 2
        o.draw 'roundrectangle 1,1,%s,%s,%s,%s' % [width, width, radius, radius]
      end

      masked = img.composite(mask, 'png') do |i|
        i.alpha "set"
        i.compose 'DstIn'
      end

      masked.composite(overlay, 'png') do |i|
        i.compose 'Over'
      end
    end
  end

  def round_corner(radius = 10)
    round_command = ""
    round_command << '\( +clone -alpha extract '
    round_command << "-draw 'fill black polygon 0,0 0,#{radius} #{radius},0 fill white circle #{radius},#{radius} #{radius},0' "
    round_command << '\( +clone -flip \) -compose Multiply -composite '
    round_command << '\( +clone -flop \) -compose Multiply -composite \) '
    round_command << '-alpha off -compose CopyOpacity -composite'
    manipulate! do |image|
      image.format 'png'
      image.combine_options do |command|
        command << round_command
      end

      image
    end
  end

  def draw_border
    manipulate! do |image|
      image.combine_options do |c|
        c.mattecolor "Blue" #задает основной цвет. Кроме указания имени, можно задать цвет в формате rgb(x,y,z) и #xxyyzz
        c.frame "2x2"
      end

      image
    end
  end

  def move_to_cach
    false
  end


end
