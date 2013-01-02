YARD-Docco: Docco style code annotation
====================================

Synopsis
--------

YARD-Docco is a YARD extension that provides an additional source view that
will show comments alongside the source code within a method. I recently spent
some time learning Backbone.js and really enjoyed the annotated source code that
was generated for a large number of the examples and thought that it would be 
useful to add this view to YARD's existing source view to take advantage of comments
made within methods.

Examples
--------

I have created a trivial, example project to help provide a quick 
visualization of the resulting documentation.

The implemented example has been deployed at [http://recursivegames.com/yard-docco/Example.html](http://recursivegames.com/yard-docco/Example.html).

**1. Comments made within methods appear alongside the code they are attempting to describe.

**2. YARD tags (e.g. @note, @todo) and links will appear as they do for methods and classes.

Installation
------------

YARD-Docco requires the following gems installed:

    YARD 0.7.0 - http://yardoc.org

To install `yard-docco` use the following command:

    $ gem install yard-docco

(Add `sudo` if you're installing under a POSIX system as root)

Usage
-----

YARD supports for automatically including gems with the prefix `yard-` 
as a plugin. To enable automatic loading yard-docco. 

    $ yard config load_plugins true
    $ yardoc 'example/**/*.rb'

Now you can run YARD as you [normally](https://github.com/lsegal/yard) would and 
have your features, step definitions and transforms captured.

An example with the rake task:

    require 'yard'

    YARD::Rake::YardocTask.new do |t|
      t.files   = ['lib/**/*.rb', 'app/**/*.rb']
      t.options = ['--any', '--extra', '--opts'] # optional
    end

LICENSE
-------

(The MIT License)

Copyright (c) 2011 Franklin Webber

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.