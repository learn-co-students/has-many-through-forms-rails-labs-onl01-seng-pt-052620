class Post < ActiveRecord::Base
  has_many :post_categories
  has_many :categories, through: :post_categories
  has_many :comments
  has_many :users, through: :comments

  def categories_attributes=(categories_hash)
    categories_hash.values.each do |category_attr|
      if category_attr[:name].present?
        category = Category.find_or_create_by(category_attr)
        self.categories << category
      end
    end 
  end
end
