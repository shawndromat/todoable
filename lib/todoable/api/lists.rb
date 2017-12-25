require 'todoable/request'
require 'todoable/list'
require 'todoable/item'

module Todoable
  module API
    module Lists
      include Todoable::Request

      def lists
        request('/lists', :get)['lists'].map do |list_json|
          ListBuilder.new
            .set_name(list_json['name'])
            .set_id(list_json['id'])
            .set_url(list_json['src'])
            .build
        end
      end

      def create_list(name)
        new_list = List.new(name: name)
        request('/lists', :post, new_list.to_json)
        new_list
      end

      def list(id)
        list_json = request("/lists/#{id}", :get)['list']

        items = list_json['items'].map do |item_json|
          Item.new(name: item_json['name'], url: item_json['src'], id: item_json['id'], finished_at: item_json['finished_at'])
        end

        ListBuilder.new
          .set_name(list_json['name'])
          .set_id(id)
          .set_items(items)
          .build
      end
    end
  end
end
