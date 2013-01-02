require 'rake'

task :default => :gendoc

task :clean do
  `rm -rf doc`
  `rm -rf .yardoc`
end

task :gendoc => :clean do
  puts `yardoc -e ./lib/yard-docco.rb 'example/**/*' --debug`
  #`open doc/index.html`
end