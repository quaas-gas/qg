# RailsSettings Model
class Setting < RailsSettings::CachedSettings
  source Rails.root.join('config/app.yml')
  namespace Rails.env
end
