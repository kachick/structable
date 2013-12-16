#!/usr/local/bin/ruby -w
# coding: us-ascii

$VERBOSE = true

require_relative '../lib/structable'
require 'declare'

class Drink
  include Structable

  member :taste
end

class Tea < Drink
  member :leaf
  alias_member :type, :leaf
end

Declare do
  
  The(Tea.new :bitter, :green) do |tea|
    kind Structable
    
    The tea.inspect do
      is '#<Tea (Structable) taste=:bitter leaf=:green>'
    end
    
    The tea.each_member do |em|
      a Enumerator
      
      The em.to_a do
        is [:taste, :leaf]
      end
    end
    
    The tea.each_value do |ev|
      a Enumerator
      
      The ev.to_a do
        is [:bitter, :green]
      end
    end
    
    The tea.each_pair do |ep|
      a Enumerator
      
      The ep.to_a do
        is [[:taste, :bitter], [:leaf, :green]]
      end
    end
  
  end
  
end