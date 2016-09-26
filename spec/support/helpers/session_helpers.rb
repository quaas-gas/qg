module Features
  module SessionHelpers
    def sign_up_with(email, password, confirmation)
      visit new_user_registration_path
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      fill_in 'Password confirmation', :with => confirmation
      click_button 'Sign up'
    end

    def signin(username, password)
      visit new_user_session_path
      fill_in 'Benutzername', with: username
      fill_in 'Passwort', with: password
      click_button 'Anmelden'
    end
  end
end
