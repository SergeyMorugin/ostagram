class Client < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :validatable, :confirmable, :lockable
end
