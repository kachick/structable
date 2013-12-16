structable
=================

[![Build Status](https://secure.travis-ci.org/kachick/structable.png)](http://travis-ci.org/kachick/structable)
[![Gem Version](https://badge.fury.io/rb/structable.png)](http://badge.fury.io/rb/structable)

"Struct" like APIs

Features
-----

* Be appendable "Struct" like APIs
* Member aliasing
* Inheritable

Usage
-----

### Setup

```ruby
require 'structable'
```

### Overview

```ruby
class Drink
  include Structable

  member :taste
end

class Tea < Drink
  member :leaf
  alias_member :type, :leaf
end

tea = Tea.new :bitter, :green
tea.members                    #=> [:taste, :leaf]
tea.members(true)              #=> [:taste, :leaf, :type]
tea.member? :type              #=> true
tea.type = 'Special Flavor'
tea.taste                      #=> :bitter
tea.leaf                       #=> 'Special Flavor'
```

Requirements
-----

* [Ruby 1.9.3 or later](http://travis-ci.org/#!/kachick/structable)

Installation
-----

```bash
$ gem install structable
```

== Links

* [Home](http://kachick.github.com/structable)
* [code](https://github.com/kachick/structable)
* [API](http://kachick.github.com/structable/yard/frames.html)
* [issues](https://github.com/kachick/structable/issues)
* [CI](http://travis-ci.org/#!/kachick/structable)
* [gem](https://rubygems.org/gems/structable)

== License

The MIT X11 License  
Copyright (C) 2011-2012 Kenichi Kamiya  
See MIT-LICENSE for further details.
