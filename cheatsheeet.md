## Dependencies (Gems/packages)

## Configuration (environment variables/other stuff in config folder)

## Database
```rb
ActiveRecord::Schema.define(version: 20160119152016) do

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", force: :cascade do |t|
    t.string   "content"
    t.integer  "user_id"
    t.integer  "post_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "comments", ["post_id"], name: "index_comments_on_post_id"
  add_index "comments", ["user_id"], name: "index_comments_on_user_id"

  create_table "post_categories", force: :cascade do |t|
    t.integer  "post_id"
    t.integer  "category_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "post_categories", ["category_id"], name: "index_post_categories_on_category_id"
  add_index "post_categories", ["post_id"], name: "index_post_categories_on_post_id"

  create_table "posts", force: :cascade do |t|
    t.string   "title"
    t.string   "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
# There could be 2 join models (many to many relationships)
# Users and Posts connected through Comments   
# Posts and Categories connected through post_categories  

```
## Models
```rb
class Category < ActiveRecord::Base
  has_many :post_categories
  has_many :posts, through: :post_categories
end

class PostCategory < ActiveRecord::Base
  belongs_to :post
  belongs_to :category
end
class Post < ActiveRecord::Base
  has_many :post_categories
  has_many :categories, through: :post_categories
  has_many :comments
  has_many :users, through: :comments
end
class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :post
end
class User < ActiveRecord::Base
  has_many :comments
  has_many :posts, through: :comments
end

```
## Views
nothing yet. (files but no content)

## Controllers
CategoriesController => show
CommentsController => create
PostsController => show,index,new,create
UsersController => show

## Routes
restful routes (resources) for posts, comments, users and categories
```rb
Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :posts
  resources :comments
  resources :users
  resources :categories
end

```

When you call build on a has_many, through association, it will create the join model in addition to the other model. 

Example:

```rb
@post = Post.create(title: "Feeling Groovy", content: "I'm feeling so groovy")
@cool = @post.categories.build(name: "Cool")

```

This line: `@post.categories.build(name: "Cool")` will create an instance of PostCategory as well as an instance of Category. When we save the post (`@post.save`), both of these instances will also be saved.

```rb
Post.last
  Post Load (1.7ms)  SELECT  "posts".* FROM "posts" ORDER BY "posts"."id" DESC LIMIT ?  [["LIMIT", 1]]
 => #<Post id: 1, title: "Feeling Groovy", content: "I'm feeling so groovy", created_at: "2020-10-15 22:21:40", updated_at: "2020-10-15 22:21:40"> 
2.6.1 :011 > Category.last
  Category Load (0.2ms)  SELECT  "categories".* FROM "categories" ORDER BY "categories"."id" DESC LIMIT ?  [["LIMIT", 1]]
 => #<Category id: 1, name: "Cool", created_at: "2020-10-15 22:21:41", updated_at: "2020-10-15 22:21:41"> 
2.6.1 :012 > PostCategory.last
  PostCategory Load (0.4ms)  SELECT  "post_categories".* FROM "post_categories" ORDER BY "post_categories"."id" DESC LIMIT ?  [["LIMIT", 1]]
 => #<PostCategory id: 1, post_id: 1, category_id: 1, created_at: "2020-10-15 22:21:41", updated_at: "2020-10-15 22:21:41"> 
2.6.1 :013 > 
```

If you need to clean up some of your records in the database that are missing foreign keys, you can do something like this in the rails console:

```rb
Comment.where(user_id:nil).update_all(user_id:1)
```

## Nested Form means what things for our Model View and Controller?
In our example we're adding a nested form for a Category to our new Post form.
### Model
categories_attributes= method (custom attribute writer)
or 
accepts_nested_attributes_for :categories
#### We know which we want to use by asking these questions:
Do I care about duplicates? 
Is this a one-to-many relationship or is it many-to-many? 
Do I need find_or_create_by?

If Yes => Use `categories_attributes=` (custom attribute writer) 
If No  => Use `accepts_nested_attributes_for` 

### View 
How do we implement a nested form in a view layer?  
We use fields_for and pass in the argument of categories 
The argument has to match the method name (before _attributes) in the model 

f.fields_for :categories, Category.new 


### Controller
```rb
def post_params
  params.require(:post).permit(:title, :content, category_ids:[], categories_attributes: [:name])
end
```

The `categories_attributes` param has to be the last key in the permitted params list and it will point to a value of an array of the field names inside of the fields_for in our form.

These are the things that need to change in the MVC to support a Nested Form.  

```ruby 
require 'rails_helper'
describe 'categories', type: 'feature' do
  before do
    @post = Post.create(title: "Feeling Groovy", content: "I'm feeling so groovy")
    @cool = @post.categories.build(name: "Cool") 
    # This relates to Post and Category models 
    # The .build method above is creating a Category and a Post Category for us
    # posts and related to categories via has many through which means to build a new category for a post we also need to create a post category  
    # .build does not save (it creates instances) 
    # .build creates instances and associations without saving them but if you save the parent all of the associations will be saved as well.  
    # When we save post that is also going to save the category with the name: cool and the posts_category with ids pointing to both of them  

    
    @post.save
  end
  describe 'show page' do
    it 'should display all of the related posts' do
      visit category_path(@cool)
      expect(page).to have_link(@post.title, href: post_path(@post))
    end
  end
end


``` 



class Post < ActiveRecord::Base
  has_many :post_categories
  has_many :categories, through: :post_categories
  has_many :comments
  has_many :users, -> {distinct}, through: :comments

  def categories_attributes=(attributes)
    category_name = attributes.values.first[:name]
    self.categories << Category.find_or_create_by(name: category_name) unless category_name.blank?
  end 

end

# Does the shovel method save? 
# When you use the shovel method it adds it to the collection 
# When you save it creates the join record 
# You cannot create the join record before you have both of the foreign keys 

# dictinct 
# This will make sure that when we call users on a post we don't end up with more than one of the same user. 
# -> This is called a lambda

#unique 
# We don't use unique because it will make us lose the connection to ActiveRecord 

# When yuo have one join model that's connecting two of the same instances, you will get duplicates by default. This is because it goes through comments and for each comment it gives you the associated post and if you comment on the same post more than once you're going to see it more than once unless you use distinct. 




class CommentsController < ApplicationController

  def create
    comment = Comment.create(comment_params)
    redirect_to comment.post
  end


  private

  def comment_params
    params.require(:comment).permit(:content, :post_id, :user_id, user_attributes:[:username, :email])
  end
end



# The .create method never creates a falsey value. It will always create an instance of the class it's called on. It will only have an id if it's successful in saving it to the database. 
# This is not the same with .save or .update method. 






class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :post

  def user_attributes=(attributes)
    self.user = User.find_or_create_by(attributes) unless attributes[:username].blank?   
  end 
end

# The existence of this setter method is what determines how fields_for works properly. A setter method that the fields_for model is a form for :user => user_attributes=(attributes) is going to make the inputs that are generated are going to generate a params hash that going to be passed into the attributes argument in the setter method above.  We made this method so we can avoid having a duplicate user. This method associates the comment that is being created with the user that has these attributes.  
# The method that associates the comment with the user is "belongs_to" :user    
# We can pass in attributes to User.find_or_create_by because it's whitelisted

# The user_attributes= method will run every time and this might cause errors, Empty string?? 

# It should only run if the attributes are not blank 

# username overrides selected user 
# This is because of strong params. They specify an order and user_attributes is last. 





class Post < ActiveRecord::Base
  has_many :post_categories
  has_many :categories, through: :post_categories
  has_many :comments
  has_many :users, -> {distinct}, through: :comments

  def categories_attributes=(attributes)
    category_name = attributes.values.first[:name]
    self.categories << Category.find_or_create_by(name: category_name) unless category_name.blank?
  end 
end

# Does the shovel method save? 
# When you use the shovel method it adds it to the collection 
# When you save it creates the join record 
# You cannot create the join record before you have both of the foreign keys 

# dictinct 
# This will make sure that when we call users on a post we don't end up with more than one of the same user. 
# -> This is called a lambda

#unique 
# We don't use unique because it will make us lose the connection to ActiveRecord 

# When yuo have one join model that's connecting two of the same instances, you will get duplicates by default. This is because it goes through comments and for each comment it gives you the associated post and if you comment on the same post more than once you're going to see it more than once unless you use distinct. 




<h1><%= @post.title %></h1>
Categories: <%= @post.categories.map(&:name).join(', ') %>
<p><%= @post.content %></p>
<p>Interested Users:
<% @post.users.each do |user| %>
  <%= link_to user.username, user %>
<% end %>
</p>

<h3>Add a Comment</h3>
<%= form_for @comment do |f| %>
  <%= f.hidden_field :post_id, value: @post.id %>
  <p>
    <%= f.label :content, "Content" %><br/>
    <%= f.text_area :content %>
  </p>
  <p>
    <%= f.label :user_id, "User" %>
    <%= f.collection_select :user_id, User.all, :id, :username, prompt: true %>
  </p>
  <p>
    <%= f.fields_for :user, User.new do |user_fields| %>
      <%= user_fields.label :username %>
      <%= user_fields.text_field :username %><br/>
      <%= user_fields.label :email %>
      <%= user_fields.text_field :email %>
    <% end %>
  </p>
  <p><%= f.submit %></p>
<% end %>
<ul>
  <% @post.comments.each do |comment| %>
    <li><%= comment.user.try(:username) %> says: <%= comment.content %></li>
  <% end %>
</ul>


<%# 
If we need a form to create a new comment and we want it to show up on the post show view 
If our form is connected to a model object we can use form_for 
If our form is not connected to a model form_tag we should use form_tag instead  

Comment is related to a Post 
Post is related to a Category 

The way that a comment belongs to a post 
When we call the post method on a comment it's going to look through the posts table for a post who's id matches the post_id of this comment. If that particular comment doesn't have a post_id it will be nil. 

We add a hidden_field to our form that will allow the post_id to come through params when we submit the form. 

Explain fields_for please 
It uses accepts_nested_attributes_for 
Because we want to prevent duplicates we assign the method manually. 

We are making a form_for @comment and we have nesting keys for a user, so the comment model is the one we want to call a method on and this is where the user_attributes= method has to be. Refer to comment.rb 

The reason we have User.new in f.fields_for is because the comment doesn't already belong to a User. We are specifying a User for whom these fields will be for. 

Because there isn't a User associated with the Comment when it's built, the fields will not appear unless we put in User.new

comment.user.try(:username) This will only call on :username if it exists  

%>



<%= form_for post do |f| %> 
  <p>
    <%= f.label :title %><br/>
    <%= f.text_field :title %>
  </p>
  <p>
    <%= f.label :content %><br/>
    <%= f.text_area :content %>
  </p>
  <p>
    <%= f.label :categories %>
    <%= f.collection_check_boxes(:category_ids, Category.all, :id, :name) %>
  </p>
  <p>
    <%= f.fields_for :categories, Category.new do |cf| %> 
      <%= cf.label :name, 'or add a new category:' %><br/>
      <%= cf.text_field :name %>
    <% end %>
  </p>
  <p>
  <%= f.submit %>
  </p>
<% end %>


   <%# we can do categories because we have a categories_attributes= method    %> 
  <%# 
any file that starts with an _ in a views directory is a partial. 
It's a local. We are passing a variable into the partial called post that refers to Post.new and this is why we can do form_for post in new.html.erb 

When we're creating a form for a post we need to think about deciding what kind of input to choose based on what kind of a relationship we're modelling. 

If we have inputs in a form_for categories we need to know what kind of relationship does a post have with a category. It is both has_many and has_many through. 
Usually has_many_through has checkboxes. More info on this please. 

What a checkbox is good for is allowing multiple inputs to go through, with multiple choices of category. Each post can have multiple choices of category. Also, each post can have multiple choices of category. It is common to have checkboxes in many to many relationships. 

One of the methods that we get from has_many that is designed to help us with dealing with checkbox inputs. We can use collection_checkboxes form builder and the associated method like the first argument we put in when using collection_checkboxes. We use category_id and category_id= are the methods that the collection checkbox helper is going to be calling. 

When you render the form the getter will determine which checkboxes start off as highlighted and then the setter will be called when you submit the form as the array of ids that come through params will be passed as an argument. In our it's example author_id= which is going to be used to create the join records and this works particularly for cases where your join model doesn't have any user submittable attributes and it's just a join model with the only purpose of creating an association between the two others. 

When we do fields for categories we need to add in Category.new object that these fields can use. 
The default behavior of this is it's going to give you fields for all the categories associated with this post which at this point there are going to be none that make sense.  We're writing a new post and there's not going to be any categories associated so we're not going to see any sets of fields, but if we have one there then we get a checkbox showing up.  

attributes 
{"0" => {"name" => "Ice Cream"}}

attributes["0"] 
{"name" => "Ice Cream"} 

attributes.values
[{"name" => "Ice Cream"}]

attributes.values.first 
{"name" => "Ice Cream"}

Category.find_or_create_by(attributes.values.first) 
This would create the category for us a
We want to shovel it into self.categories (self being an instance of post in the Post model) 

 %>
