# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
require 'securerandom'
include YamlHelper


def load_config
  Ostagram::Application.config.secret_key_base = secure_token
  #
  file = Rails.root.join('config/config.secret')
  #par = get_param_config(file, :server1, :password)
  #
  #Ostagram::Application.config.action_mailer.delivery_method = :smtp
  par = load_settings(file)
  par = par["smtp_settings"]
  params = {}
  par.each { |p,v| params[p.to_sym] = v.to_s}
  Ostagram::Application.config.action_mailer.smtp_settings = params
end

def secure_token
  file = Rails.root.join('config/config.secret')

  if File.exist?(file)
    get_param_config(file, :token, :production)
  else
    token = SecureRandom.hex(64)
    update_config(file, :token, :production, token)
    token
  end
end




load_config()