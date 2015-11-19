class Client < ActiveRecord::Base
  has_many :queue_images
  mount_uploader :avatar, AvatarUploader
  # Include default devise modules. Others available are:
  # :, :lockable, :timeoutable and :omniauthable :confirmable,
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :validatable, :lockable
  validates :name, presence: true
  validates :name, uniqueness: true, if: -> { self.name.present? }
  validates :avatar, presence: true


end
