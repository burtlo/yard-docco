require 'YARD'
require File.dirname(__FILE__) + "/lib/yard-docco"

module DoccoInTheYARD
  def self.show_version_changes(version)
    date = ""
    changes = []  
    grab_changes = false

    File.open("#{File.dirname(__FILE__)}/History.txt",'r') do |file|
      while (line = file.gets) do

        if line =~ /^===\s*#{version.gsub('.','\.')}\s*\/\s*(.+)\s*$/
          grab_changes = true
          date = $1.strip
        elsif line =~ /^===\s*.+$/
          grab_changes = false
        elsif grab_changes
          changes = changes << line
        end

      end
    end

    { :date => date, :changes => changes }
  end
end

Gem::Specification.new do |s|
  s.name        = 'yard-docco'
  s.version     = ::DoccoInTheYARD::VERSION
  s.authors     = ["Franklin Webber"]
  s.description = %{ 
    YARD-Docco is a YARD extension that provides an additional source view that
    will show comments alongside the source code within a method.  }
  s.summary     = "Docco style documentation within methods"
  s.email       = 'franklin.webber@gmail.com'
  s.homepage    = "http://github.com/burtlo/yard-docco"

  s.platform    = Gem::Platform::RUBY
  
  changes = DoccoInTheYARD.show_version_changes(::DoccoInTheYARD::VERSION)
  
  s.post_install_message = %{
(==) (==) (==) (==) (==) (==) (==) (==) (==) (==) (==) (==) (==) (==) (==)

  Thank you for installing yard-docco #{::DoccoInTheYARD::VERSION} / #{changes[:date]}.
  
  Changes:
  #{changes[:changes].collect{|change| "  #{change}"}.join("")}
(==) (==) (==) (==) (==) (==) (==) (==) (==) (==) (==) (==) (==) (==) (==)

}

  s.add_dependency 'yard', '>= 0.7.0'
  
  s.rubygems_version   = "1.3.7"
  s.files            = `git ls-files`.split("\n")
  s.extra_rdoc_files = ["README.md", "History.txt"]
  s.rdoc_options     = ["--charset=UTF-8"]
  s.require_path     = "lib"
end
