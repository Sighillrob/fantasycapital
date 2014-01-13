module StatsClient
  module ResponseParser
    class BaseParser
      attr_reader :result

      def initialize(payload, resource_class)
        @payload = payload
        @resource_class = resource_class
        @result  = []
      end

      def parse(parent_node)
        case @payload
          when Array
            @payload.each do |entry|
              find_resource_node entry, parent_node
            end
          when Hash
            @payload.each do |entry|
              find_resource_node entry, parent_node
            end
        end

        @result
      end

      def find_resource_node(entry, node_key)
        case entry
          when Array
            entry.each do |child|
              find_resource_node child, node_key
            end
          when Hash
            entry.keys.each do |key|
              if key == node_key
                add_resource_entries entry[key]
                return
              else
                find_resource_node entry[key], node_key
              end
            end
        end
      end


      protected

      def add_resource_entries(resource_collection)
        resource_collection.each do |attr_hash|
          resource = @resource_class.new
          resource.copy_instance_variables_from_hash attr_hash
          @result << resource
        end
      end
    end
  end
end
