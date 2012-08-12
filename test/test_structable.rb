$VERBOSE = true
require_relative 'test_helper'

class TestStructableFreeze < Test::Unit::TestCase
  class Sth
    include Structable
    
    member :foo
  end
  
  def test_freeze
    sth = Sth.new
    sth.freeze
    
    assert_raises RuntimeError do
      sth.foo = 8
    end
   
    assert_equal true, sth.frozen?
  end
end


class TestStructableLoadPairs < Test::Unit::TestCase
  class Sth
    include Structable
    
    member :foo
    member :bar
    member :hoge
  end
  
  def test_for_pairs
    sth = Sth.for_pairs hoge: 7, foo: 8
    assert_equal [8, nil, 7], [sth.foo, sth.bar, sth.hoge]
    assert_equal [8, nil, 7], sth.values
  end
  
  def test_lock
    sth = Sth.new
    sth.lock :foo
    
    assert_raises RuntimeError do
      sth.foo = 8
    end
    
    sth.bar = 8
   
    assert_equal true, sth.locked?(:foo)
    assert_equal false, sth.locked?(:bar)
    assert_equal false, sth.locked?(:hoge)
  end
end

class TestStructableObject < Test::Unit::TestCase
  class Sth
    include Structable
    
    member :foo
    member :bar
    member :hoge
  end
  
  def test_hash
    sth1 = Sth[hoge: 7, foo: 8]
    sth2 = Sth[hoge: 7, foo: 8]
    assert_equal true, sth1.eql?(sth2)
    assert_equal true, sth2.eql?(sth1)
    assert_equal sth1.hash, sth2.hash
    assert_equal true, {sth1 => 1}.has_key?(sth2)
    assert_equal true, {sth2 => 1}.has_key?(sth1)
    assert_equal 1, {sth1 => 1}[sth2]
    assert_equal 1, {sth2 => 1}[sth1]
  end
end


class TestStructableAliasMember < Test::Unit::TestCase
  class Sth
    include Structable
    
    member :foo
    member :bar
    member :hoge
    alias_member :abc, :bar
  end

  def test_alias_member
    sth = Sth.new 'A', 8
    assert_equal [:foo, :bar, :hoge], sth.members
    assert_equal 8, sth[:bar]
    assert_equal 8, sth[:abc]
    assert_equal 8, sth.abc
    sth.abc = 5
    assert_equal 5, sth.bar
    sth[:abc] = 6
    assert_equal 6, sth.bar
    
    assert_raises NameError do
      Sth.class_eval do
        member :abc
      end
    end
    
    assert_equal({:abc => :bar}, Sth.aliases)
  end
end


class TestStructableInherit < Test::Unit::TestCase
  class Sth
    include Structable
    
    member :foo
    member :bar
  end
  
  class SubSth < Sth
    member :hoge
  end
  
  class SubSubSth < SubSth
    member :rest
  end
  
  def test_inherit
    assert_equal [:foo, :bar], Sth.members
    assert_equal [:foo, :bar, :hoge], SubSth.members
    assert_equal [:foo, :bar, :hoge, :rest], SubSubSth.members
    sth = Sth.new
    substh = SubSth.new
    
    assert_raises NoMethodError do
      sth.hoge = 3
    end
    
    assert_raises NoMethodError do
      substh.rest = :a4
    end
    
    subsubsth = SubSubSth.new
    
    subsubsth.rest = :a4
    
    assert_equal :a4, subsubsth[:rest]
  end
end

class TestStructableEnum < Test::Unit::TestCase
  class Sth
    include Structable
    
    member :name
    member :age
  end

  def test_each_pair
    sth = Sth.new 'a', 10
    assert_same sth, sth.each_pair{}
    
    enum = sth.each_pair
    assert_equal [:name, 'a'], enum.next
    assert_equal [:age, 10], enum.next
    assert_raises StopIteration do
      enum.next
    end
  end
end
