module SportsdataClient
  class ResponseParser
      attr_reader :result

      def initialize(payload=nil)
        @payload = payload
        @result  = []
      end

      # find all instances of a node key in a tree and return it. This acts cumulatively over multiple calls.
      def parse(node_to_find, payload=nil)
        @payload = payload if !payload.nil?
        find_resource_node @payload, node_to_find
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
                @result.push(*entry[key])
                return
              else
                find_resource_node entry[key], node_key
              end
            end
        end
      end

    end
end
