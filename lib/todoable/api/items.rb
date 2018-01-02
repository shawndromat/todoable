require 'todoable/item'

module Todoable
  module API
    module Items
      def create_item(list_id, name)
        item_json = json_request("/lists/#{list_id}/items", :post, {item: {name: name}}.to_json)
        Item.new(name: item_json['name'], url: item_json['src'], id: item_json['id'])
      end
    end
  end
end
