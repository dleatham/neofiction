require 'development_mail_interceptor'
ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => "neoFICTION.com",
  :user_name            => "support@neoFICTION.com",
  :password             => "nf12nf34",
  :authentication       => "plain",
  :enable_starttls_auto => true
 }


if Rails.env.production?
  ActionMailer::Base.default_url_options[:host] = "neoFICTION.com"
else
  ActionMailer::Base.default_url_options[:host] = "localhost:3000"  
end

# ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?
Mail.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?

