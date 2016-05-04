class CreateAdminService
  def call
    username = ENV['ADMIN_USERNAME'] || 'admin'
    user = User.find_or_create_by!(username: username) do |user|
      user.email = ENV['ADMIN_EMAIL'] || 'admin@admin.com'
      user.password = ENV['ADMIN_PASSWORD'] || 'admin123'
      user.password_confirmation = ENV['ADMIN_PASSWORD'] || 'admin123'
      user.admin!
    end
  end
end
