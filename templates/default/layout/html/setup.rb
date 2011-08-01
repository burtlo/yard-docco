def init
  super
end

#
# Append yard-docco stylesheet to yard core stylesheets
# 
def stylesheets
  super + %w(css/docco.css)
end

#
# Append yard-docco javascript to yard core javascripts
# 
def javascripts
  super + %w(js/docco.js)
end