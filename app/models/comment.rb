class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :post

  # def ingredient_attributes=(ingredient)
  #   self.ingredient = Ingredient.find_or_create_by(name: ingredient[:name])
  #   self.ingredient.update(ingredient)
  # end

  def user_attributes
    @username
  end

  def user_attributes=(user)
    # byebug
    unless user[:username] == ""
      self.user = User.find_or_create_by(username: user[:username])
      self.user.update(user)
    end
  end

end
