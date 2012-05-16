gsub_file 'Gemfile', /# (gem 'therubyracer')/, '\1'
gsub_file 'Gemfile', /^\s*#.*$/, ''
gsub_file 'Gemfile', /\n+/, "\n"
gsub_file 'Gemfile', /\ngroup/, "\n\ngroup"
gsub_file 'Gemfile', /end\n/, "end\n\n"
gsub_file 'Gemfile', /source[^\n]*\n/, "\\0\n"

append_file 'Gemfile', <<-GEMFILE
gem 'activeadmin'
gem 'formtastic', '~> 2.1.1'
gem 'simple_form'
gem 'friendly_id'
gem 'twitter-bootstrap-rails'

group :development, :test do
  gem 'rspec-rails'
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'tclone'
end

group :extra do
  gem 'thin'
  gem 'foreman'
end
GEMFILE

# Bundle Install
run "bundle install"

# Generate
generate "rspec:install"
generate "active_admin:install"
generate "bootstrap:install"
generate "bootstrap:layout", "-f"
generate "simple_form:install", "--bootstrap"
generate "friendly_id"

# ActiveAdmin
create_file "app/admin/admin_user.rb", <<-AdminUserConfig
ActiveAdmin.register AdminUser do
  index do
    column :email
    column :last_sign_in_at
    default_actions
  end

  filter :email

  form do |f|
    f.inputs :email, :password
    f.buttons
  end
end
AdminUserConfig

# Move stylesheet
run "mkdir -p lib/assets/stylesheets lib/assets/javascripts"
run "mv app/assets/stylesheets/active_admin.css.scss lib/assets/stylesheets"
run "mv app/assets/javascripts/active_admin.js lib/assets/javascripts"

# DB Migration
run "rake db:migrate"

# Home page
remove_file "public/index.html"
generate "controller", "home", "index"
gsub_file 'config/routes.rb', /get "home\/index"/, 'root :to => "home#index"'
gsub_file 'config/routes.rb', /^\s*#.*$/, ''
gsub_file 'config/routes.rb', /\n+/, "\n"

