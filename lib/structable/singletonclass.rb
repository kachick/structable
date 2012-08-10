module Structable

  class << self

    private
    
    def included(mod)
      eigen = self
      
      mod.module_eval do
        if eigen.equal? ::Structable
          extend  ::Structable::ClassMethods
          include ::Structable::InstanceMethods
          attrs = {}
        else
          attrs = eigen::MEMBER_DEFINES.dup
        end

        const_set :MEMBER_DEFINES, attrs
      end
    end

  end

end