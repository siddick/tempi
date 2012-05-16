append_file 'Gemfile', <<-GEMFILE
gem 'devise'
gem 'omniauth'
gem 'omniauth-openid'
GEMFILE

run "bundle install"

generate "devise:install"
generate "devise", "user"
generate "model",  "authorization", "provider:string uid:string user:references extra:text"

create_file "app/controllers/user/omniauth_callbacks_controller.rb", <<-OmniauthCallback
class User::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def developer
    process_provider('developer')
  end

  def google
    process_provider('google')
  end

  def yahoo
    process_provider('yahoo')
  end

  def open_id
    process_provider('open_id')
  end

  private
  def process_provider(provider)
    auth = env["omniauth.auth"]
    unless authorization = Authorization.find_by_provider_and_uid(provider, auth['uid'])
      user = User.new( :email => auth.info['email'] )
      user.authorizations.build( :provider => provider, :uid => auth['uid'] )
      user.save!  # TODO: Need to handle failure
    end
    sign_in_and_redirect user, :event => :authentication
  end

end
OmniauthCallback

gsub_file "config/initializers/devise.rb", /^\s*end\s*$/, <<-DeviseConfig
  config.omniauth :developer  if Rails.env == "development"
  config.omniauth :open_id, :require => "omniauth-openid"
  config.omniauth :open_id, :name => "google", :identifier => 'https://www.google.com/accounts/o8/id', :require => "omniauth-openid"
  config.omniauth :open_id, :name => "yahoo",  :identifier => 'http://yahoo.com', :require => "omniauth-openid"

end
DeviseConfig
gsub_file "app/models/user.rb", ":registerable", '\0, :omniauthable'
gsub_file "app/models/user.rb", /^class User.*$/, <<-UserConfig
\\0
  has_many :authorizations, :dependent => :delete_all
  def password_required?
    (authorizations.empty? || !password.blank?) && super
  end
UserConfig
gsub_file "app/models/authorization.rb", /^class Authorization.*$/, "\\0\n  validates_uniqueness_of :uid, :scope => :provider"
gsub_file "config/routes.rb", /devise_for :users/, '\0, :controllers => { :omniauth_callbacks => "user/omniauth_callbacks" }'

run "bundle exec rake db:migrate"

