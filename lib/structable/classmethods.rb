require 'forwardable'

module Structable

  module ClassMethods

    extend Forwardable

    def each_member(&block)      
      return to_enum(__method__) unless block_given?
      _attrs.each_key(&block)
      self
    end
    
    alias_method :each_key, :each_member

    def members(aliased=false)
      (aliased ? _attrs : _attrs.select{|k, v|v.respond_to? :each_pair}).keys
    end

    alias_method :keys, :members

    def length
      _attrs.length
    end

    alias_method :size, :length

    def has_member?(name)
      _attrs.has_key? name
    end

    alias_method :member?, :has_member?
    alias_method :has_key?, :has_member?
    alias_method :key?, :has_member?

    def alias_member(aliased, original)
      _attrs[aliased] = original
     (_attrs(original)[:aliases] ||= []) << aliased

      alias_method aliased, original
      alias_method :"#{aliased}=", :"#{original}="
    end

    def freeze
      close
      super
    end

    # @param [Symbol, String, #to_str] name
    def autonym(name)
      name = name.to_sym
      if _attrs.has_key? name
        (linked = _attrs[name]).kind_of?(Symbol) ? linked : name
      else
        raise NameError
      end
    end
    
    # @group Constructor
    
    def_delegator :self, :new, :[]
    
    # @param [#each_pair, #keys] pairs ex: Hash, Struct
    def load_pairs(pairs)
      unless pairs.respond_to?(:each_pair) and pairs.respond_to?(:keys)
        raise TypeError, 'no pairs object'
      end

      raise ArgumentError, "different members" unless (pairs.keys - keys).empty?

      new.tap {|instance|
        pairs.each_pair do |name, value|
          instance[name] = value
        end
      }
    end

    # @endgroup

    private
    
    def member(name)
      name = name.to_sym
      raise NameError, 'Already defined' if _attrs.has_key? name
      
      define_method name do
        _get! name
      end

      define_method :"#{name}=" do |value|
        _set! name, value
      end
      
      _attrs[name] = {}

      nil
    end

    def _attrs(name=nil)
      name ? self::MEMBER_DEFINES[autonym name] : self::MEMBER_DEFINES
    end

    def inherited(subclass)
      eigen = self
      super subclass
      
      subclass.module_eval do
        const_set :MEMBER_DEFINES, eigen::MEMBER_DEFINES.dup
      end
    end
  
  end

end
