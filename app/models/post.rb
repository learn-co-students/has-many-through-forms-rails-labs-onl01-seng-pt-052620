class Post < ActiveRecord::Base
  has_many :post_categories
  has_many :categories, through: :post_categories
  has_many :comments
  has_many :users, -> { distinct }, through: :comments
  #accepts_nested_attributes_for :categories
  #reject_if needs to be used somewhere so only to create new record if all the fields aren't blank.
  def categories_attributes=(attributes)
    category_name = attributes.values.first[:name]
    self.categories << Category.find_or_create_by(name: category_name) unless category_name.blank?
  end


end
