# app/models/user.rb
class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true

  has_many :teams, dependent: :destroy
  has_many :players, dependent: :destroy
  has_many :tournaments, dependent: :destroy
  has_many :series, dependent: :destroy
  has_many :matches, dependent: :destroy
end
