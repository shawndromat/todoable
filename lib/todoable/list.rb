module Todoable
  class List
    attr_accessor :name, :url, :id, :items

    def initialize(name: nil, url: nil, id: nil, items: [])
      @name = name
      @url = url
      @id = id
      @items = items
    end

    def to_json
      {
        list: {
          name: self.name
        }
      }.to_json
    end
  end

  class ListBuilder
    def initialize
      @list = List.new
    end

    def set_name(name)
      @list.name = name
      self
    end

    def set_url(url)
      @list.url = url
      self
    end

    def set_id(id)
      @list.id = id
      self
    end

    def set_items(items)
      @list.items = items
      self
    end

    def build
      @list
    end
  end
end
