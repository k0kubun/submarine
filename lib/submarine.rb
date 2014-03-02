require "submarine/version"
require "capybara-webkit"
require "capybara/dsl"

class Submarine
  include Capybara::DSL

  TWITTER_URL = "https://twitter.com/"
  LOGIN_URL = "#{TWITTER_URL}login"
  DEACTIVATION_URL = "#{TWITTER_URL}settings/accounts/confirm_deactivation"

  def initialize(screen_name, password)
    @screen_name = screen_name
    @password = password
    Capybara.current_driver = :webkit
    Capybara.run_server = false
  end

  def activate
    login unless logged_in?
  end

  def deactivate
    login unless logged_in?

    visit(DEACTIVATION_URL)
    find("#settings_save")
    click_button("@#{@screen_name}を削除")

    find("#auth_password")
    within("#deactivation_password_dialog") do
      fill_in("auth_password", with: @password)
      click_button("退会する")
    end
  end

  def activated?
    visit("#{TWITTER_URL}#{@screen_name}")
    status_code == 200
  end

  private

  def logged_in?
    visit(LOGIN_URL)
    current_url == TWITTER_URL
  end

  def login
    visit(LOGIN_URL)
    within(".signin") do
      fill_in("session[username_or_email]", with: @screen_name)
      fill_in("session[password]", with: @password)
      click_button("ログイン")
    end
  end
end
