class Post < ActiveRecord::Base
  has_many :post_categories
  has_many :categories, through: :post_categories
  has_many :comments
  has_many :users, -> {distinct}, through: :comments

  def categories_attributes=(category_attributes)
    category = category_attributes.values.first[:name]
    self.categories << Category.find_or_create_by(name: category) unless category.blank?
  end

end
