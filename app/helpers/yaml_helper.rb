require 'yaml'

module YamlHelper

  def get_param_config(file_name,key1,key2)
    load_settings(file_name)[key1.to_s][key2.to_s]
  end

  def update_config(file_name,key1,key2, value)
    settings = load_settings(file_name)
    settings[key1.to_s] ||= {}
    settings[key1.to_s][key2.to_s] = value.to_s
    save_settings(file_name, settings)
  end

  def load_settings(file_name)
    #file = Rails.root.join(@file_name)
    if File.exist?(file_name)
      @config = YAML.load(File.read(file_name))
    else
      {}
    end
  end

  def save_settings(file_name, settings)
    #file = Rails.root.join(@file_name)
    File.write(file_name, settings.to_yaml)
  end

end