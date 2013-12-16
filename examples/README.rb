#!/usr/local/bin/ruby -w
# coding: us-ascii

$VERBOSE = true

require_relative '../lib/structable'

class Drink
  include Structable

  member :taste
end

class Tea < Drink
  member :leaf
  alias_member :type, :leaf
end

tea = Tea.new :bitter, :green
p tea                                  #=> #<Tea (Structable) taste=:bitter leaf=:green>
p tea.members                          #=> [:taste, :leaf]
p tea.members(true)                    #=> [:taste, :leaf, :type]
p tea.member? :type                    #=> true
tea.type = 'Special Flavor'
p tea.taste                            #=> :bitter
p tea.leaf                             #=> 'Special Flavor'
p tea[0]                               #=> :bitter