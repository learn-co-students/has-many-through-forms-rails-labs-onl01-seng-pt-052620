class User < ActiveRecord::Base
  has_many :comments
  has_many :posts, -> {distinct}, through: :comments

  validates :username, uniqueness: true
end
