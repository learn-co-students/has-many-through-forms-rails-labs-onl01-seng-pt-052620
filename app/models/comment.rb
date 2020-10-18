class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :post

  accepts_nested_attributes_for :user

  def username
  	self.user.username
  end

  def user_attributes=(attributes)
    self.user = User.find_or_create_by(attributes) unless attributes[:username].blank?
  end



end
