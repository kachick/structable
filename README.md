structable
=================

* ***This repository is archived***
* ***No longer maintained***
* ***All versions have been yanked from https://rubygems.org for releasing valuable namespace for others***

"Struct" like APIs

Features
-----

* Be appendable "Struct" like APIs
* Member aliasing
* Inheritable

Usage
-----

Setup

```ruby
require 'structable'
```

Overview

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

* Ruby 2.5 or later

License
-----

The MIT X11 License  
Copyright (C) 2011-2012 Kenichi Kamiya  
See MIT-LICENSE for further details.
