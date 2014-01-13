module StatsClient
  module BaseResource

    module Methods
      def copy_instance_variables_from_hash(hash)
        hash.keys.each do |key|
          instance_variable_set "@#{self.class.method_name_for_attr(key)}", hash[key]
        end
      end
    end
    include Methods

    def self.included(klass)
      klass.extend Methods

    end
  end
end