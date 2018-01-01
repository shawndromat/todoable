require 'todoable/request'
require 'todoable/list'
require 'todoable/item'

module Todoable
  module API
    module Lists
      include Todoable::Request

      def lists
        json_request('/lists', :get)['lists'].map do |list_json|
          ListBuilder.new
            .set_name(list_json['name'])
            .set_id(list_json['id'])
            .set_url(list_json['src'])
            .build
        end
      end

      def create_list(name)
        list_json = json_request('/lists', :post, {list: {name: name}}.to_json)
        List.new(name: list_json['name'], url: list_json['src'], id: list_json['id'])
      end

      def list(id)
        list_json = json_request("/lists/#{id}", :get)

        items = list_json['items'].map do |item_json|
          Item.new(name: item_json['name'], url: item_json['src'], id: item_json['id'], finished_at: item_json['finished_at'])
        end

        List.new(name: list_json['name'], id: id, items: items)
      end

      def update_list(id, name)
        request("/lists/#{id}", :patch, {list: {name: name}}.to_json)
        List.new(name: name, id: id)
      end

      def delete_list(id)
        request("/lists/#{id}", :delete)
        List.new(id: id)
      end
    end
  end
end
