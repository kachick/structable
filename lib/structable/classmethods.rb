# coding: us-ascii

require 'forwardable'

module Structable

  module ClassMethods

    extend Forwardable
    
    # @return [Integer]
    def length
      _members.length
    end

    alias_method :size, :length

    # @yield [name]
    # @yieldparam [Symbol] name
    # @yieldreturn [self]
    # @return [Enumerator]
    def each_member(&block)      
      return to_enum(__method__) unless block_given?
      autonyms.each(&block)
      self
    end
    
    alias_method :each_key, :each_member
  
    # @param [Boolean] include_aliased
    # @return [Array<Symbol>]
    def members(include_aliased=false)
      include_aliased ? all_members : autonyms
    end
    
    # @return [Array<Symbol>]
    def all_members
      _members.keys
    end

    alias_method :keys, :members

    # @param [Symbol, String] name
    def has_member?(name)
      _members.has_key? name
    end

    alias_method :member?, :has_member?
    alias_method :has_key?, :has_member?
    alias_method :key?, :has_member?

    # @param [Symbol, String] aliased
    # @param [Symbol, String] original
    # @return [self] to be accessible via other name
    def alias_member(aliased, original)
      aliased, original = aliased.to_sym, original.to_sym
      raise "Already defined the alias '#{aliased}'" if _members[aliased]

      _members[aliased] = original

      alias_method aliased, original
      alias_method :"#{aliased}=", :"#{original}="
    end

    # @param [Symbol, String] name
    # @return [Symbol] identifier symbol
    def autonym(name)
      name = name.to_sym
      
      if autonyms.include?(name)
        name
      else
        aliases[name] || raise(NameError)
      end
    end
    
    # @return [Array<Symbol>] original keys
    def autonyms
      _members.reject{|k, v|v.kind_of? Symbol}.keys
    end
    
    # @return [Hash] aliased_key => original_key
    def aliases
      _members.select{|k, v|v.kind_of? Symbol}
    end
    
    # @group Constructor
    
    def_delegator :self, :new, :[]
    
    # @param [#each_pair, #keys] pairs ex: Hash, Struct
    # @return [ClassMethods] new instance
    def for_pairs(pairs)
      unless pairs.respond_to?(:each_pair) and pairs.respond_to?(:keys)
        raise TypeError, 'not pairs object'
      end

      raise ArgumentError, "different members" unless (pairs.keys - keys).empty?

      new.tap {|instance|
        pairs.each_pair do |name, value|
          instance[name] = value
        end
      }
    end
    
    alias_method :load_pairs, :for_pairs

    # @endgroup
    
    # @return [self] 
    def freeze
      close
      super
    end

    def assert_member(name)
      raise NameError, "Unknown member '#{name}'" unless member?(name)
    end

    private

    # @param [Symbol, String] name
    # @return [nil]
    def member(name)
      name = name.to_sym
      if _members.has_key? name
        raise NameError, "Already defined the member '#{name}'" 
      end
      
      define_method name do
        _get! name
      end

      define_method :"#{name}=" do |value|
        _set! name, value
      end
      
      _members[name] = {}

      nil
    end

    def _members
      self::Structable_MEMBERS
    end

    def inherited(subclass)
      super subclass
      
      subclass.const_set :Structable_MEMBERS, _members.dup
    end
  
  end

end
