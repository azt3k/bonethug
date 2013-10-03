module ApplicationHelper

  def image_absolute_url(source)
    # this should work, but there's something funky going on with the asset paths
    host = Rails.application.routes.default_url_options[:host]
    path = ActionController::Base.helpers.asset_path(source, type: :image)
    path = path.gsub(host,'')
    path = (host + path).gsub('//','/')
    'http://' + path
    # 'http://' + Rails.application.routes.default_url_options[:host] + '/assets/' + source    
  end

end