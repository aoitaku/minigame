require 'forwardable'

module Delegable

  include Forwardable

  def delegate_to(accessor, *methods, **method_hash)
    methods.each do|method|
      def_instance_delegator(accessor, method)
    end
    method_hash.each do|method, ali|
      def_instance_delegator(accessor, method, ali)
    end
  end

end
