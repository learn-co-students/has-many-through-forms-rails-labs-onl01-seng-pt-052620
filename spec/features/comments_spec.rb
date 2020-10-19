require 'rails_helper'

describe 'comments', type: 'feature' do

  before do
    @category = Category.create(name: "Cool")
    @post = Post.create(title: "So Awesome", content: "Man am I a great blogger OR WHAT!")
    @user = User.create(username: 'RealBigFish')
    visit post_path(@post) 
  end

  it 'creates a comment with an existing user' do
    fill_in('comment_content', with: 'great post!')
    select(@user.username, from: 'comment_user_id')
    click_button('Create Comment')
    expect(page).to have_content("#{@user.username} says: great post!")
  end

  it 'creates a comment and a new user' do
    fill_in('comment_content', with: 'i agree')
    fill_in('comment_user_attributes_username', with: 'CoolPerson25')
    click_button('Create Comment')
    expect(page).to have_content("CoolPerson25 says: i agree")
  end
end


# The test is visiting the post showpage and then filling in a form to create a comment     
# Why do we go to PostsController and not CommentsController next??? 
# The spec is about comments but it's on the posts show page this is why we work on the post show page 

# If we need a form to create a new comment and we want it to show up on the post show view 
# If our form is connected to a model object we can use form_for 
# If our form is not connected to a model form_tag we should use form_tag instead 