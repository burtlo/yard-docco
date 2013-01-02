module DoccoInTheYARD
  VERSION = '1.0.2'
end

YARD::Templates::Engine.register_template_path File.dirname(__FILE__) + '/../templates'

# The following static paths and templates are for yard server
YARD::Server.register_static_path File.dirname(__FILE__) + "/../templates/default/fulldoc/html"