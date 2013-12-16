# coding: us-ascii

module Structable

  class << self

    private
    
    def included(mod)
      eigen = self
      
      mod.module_eval do
        if eigen.equal? ::Structable
          extend  ::Structable::ClassMethods
          include ::Structable::InstanceMethods
          _members = {}
        else
          _members = eigen::Structable_MEMBERS.dup
        end

        const_set :Structable_MEMBERS, _members
      end
    end

  end

end
