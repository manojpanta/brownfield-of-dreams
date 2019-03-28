require 'rails_helper'

describe 'Visitor registration' do
  before :each do
    @email = 'jimbob@aol.com'
    @first_name = 'Jim'
    @last_name = 'Bob'
    @password = 'password'
    @password_confirmation = 'password'
  end
  describe 'vistor can create an account', :js do
    it ' visits the home page' do
      visit '/'

      click_on 'Sign In'

      expect(current_path).to eq(login_path)

      click_on 'Sign up now.'

      expect(current_path).to eq(new_user_path)

      fill_in 'user[email]', with: @email
      fill_in 'user[first_name]', with: @first_name
      fill_in 'user[last_name]', with: @last_name
      fill_in 'user[password]', with: @password
      fill_in 'user[password_confirmation]', with: @password

      click_on'Create Account'

      expect(current_path).to eq(dashboard_path)

      expect(page).to have_content(@email)
      expect(page).to have_content(@first_name)
      expect(page).to have_content(@last_name)
      expect(page).to_not have_content('Sign In')
    end
  end

  it 'visitor cannot create an account if the email they choose is already taken' do
    create(:user, email: @email)

    visit '/'

    click_on 'Sign In'

    expect(current_path).to eq(login_path)

    click_on 'Sign up now.'

    expect(current_path).to eq(new_user_path)

    fill_in 'user[email]', with: @email
    fill_in 'user[first_name]', with: @first_name
    fill_in 'user[last_name]', with: @last_name
    fill_in 'user[password]', with: @password
    fill_in 'user[password_confirmation]', with: @password

    click_on'Create Account'

    expect(User.all.count).to eq(1)
    expect(page).to have_content('Email already exists')
  end
end
