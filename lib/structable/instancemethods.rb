require 'forwardable'

module Structable

  module InstanceMethods

    extend Forwardable

    def_delegators :'self.class',
      :members, :keys, :length, :size,
      :has_member?, :member?, :has_key?, :key?, :_members, :assert_member

    private :_members, :assert_member
    
    def_delegators :@_db, :hash, :has_value?, :value?, :empty?

    # @yield [name]
    # @yieldparam [Symbol] name
    # @yieldreturn [self]
    # @return [Enumerator]
    def each_member(&block)
      return to_enum(__method__) unless block_given?
      self.class.each_member(&block)
      self
    end
    
    alias_method :each_key, :each_member

    def initialize(*values)
      @_db, @_locks = {}, {}
      _replace_values(*values)
    end

    # @return [Array]
    def values
      members.map{|name|@_db[name]}
    end

    alias_method :to_a, :values

    # @return [Boolean]
    def ==(other)
      _compare other, :==
    end

    alias_method :===, :==
    
    def eql?(other)
      _compare other, :eql?
    end

     # @return [String]
    def inspect
      "#<#{self.class} (Structable)".tap {|s|
        each_pair do |name, value|
          suffix = (has_default?(name) && default?(name)) ? '(default)' : nil
          s << " #{name}=#{value.inspect}#{suffix}"
        end
        
        s << ">"
      }
    end

    # @return [String]
    def to_s
      "#<structable #{self.class}".tap {|s|
        each_pair do |name, value|
          s << " #{name}=#{value.inspect}"
        end
        
        s << '>'
      }
    end

    # @param [Boolean] reject_no_assign
    # @return [Hash]
    def to_h(reject_no_assign=false)
      return @_db.dup if reject_no_assign

      {}.tap {|h|
        each_pair do |key, value|
          h[key] = value
        end
      }
    end

    # @param [Fixnum, Range] *keys
    # @return [Array]
    def values_at(*_keys)
      [].tap {|r|
        _keys.each do |key|
          case key
          when Fixnum
            r << self[key]
          when Range
            key.each do |n|
              raise TypeError unless n.instance_of? Fixnum
              r << self[n]
            end
          else
            raise TypeError
          end
        end
      }
    end

    # @param [Symbol, String, Fixnum] key
    def [](key)
      _subscript(key) {|name|_get! name}
    end
    
    # @param [Symbol, String, Fixnum] key
    # @param [Object] value
    # @return [value]
    def []=(key, value)
      _subscript(key) {|name|_set! name, value}
    end

    # @return [self]
    def freeze
      close
      super
    end

    # @yield [value]
    # @yieldreturn [self]
    # @return [Enumerator]
    def each_value
      return to_enum(__method__) unless block_given?
      each_member{|name|yield self[name]}
    end

    alias_method :each, :each_value

    # @yield [name, value]
    # @yieldparam [Symbol] name
    # @yieldreturn [self]
    # @return [Enumerator]
    def each_pair
      return to_enum(__method__) unless block_given?
      each_member{|name|yield name, self[name]}
      self
    end
    
    # @param [Symbol, String] name
    # @return [self]
    def lock(name)
      name = name.to_sym
      assert_member name
      
      @_locks[name] = true
      self
    end
    
    # @param [Symbol, String] name
    def locked?(name)
      name = name.to_sym
      
      @_locks.has_key?(name)
    end
    
    private
    
    def initialize_copy(original)
      @_db, @_locks = @_db.dup, {}
    end

    def close
      [@_db, @_locks].each(&:freeze).freeze
      self
    end

    def _get!(name)
      @_db[name]
    end

    def _set!(name, value)
      raise "can't modify frozen #{self.class}" if frozen?
      raise "can't modify locked member '#{name}'" if locked? name

      @_db[name] = value
    end

    def _replace_values(*values)
      unless values.size <= size
        raise ArgumentError, "struct size differs (max: #{size})"
      end

      values.each_with_index do |value, index|
        self[index] = value
      end
    end

    # @param [Symbol] method
    def _compare(other, method)
      instance_of?(other.class) && values.__send__(method, other.values)
    end

    def _subscript(key)
      case key
      when Symbol, String
        yield self.class.autonym(key)
      when Fixnum
        if name = members[key]
          yield name
        else
          raise IndexError
        end
      else
        raise ArgumentError
      end
    end

  end

end
