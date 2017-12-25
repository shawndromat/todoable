module Todoable
  class Item
    attr_reader :name, :url, :id, :finished_at

    def initialize(name:, url: nil, id: nil, finished_at: nil)
      @name = name
      @url = url
      @id = id
      @finished_at = finished_at
    end
  end
end
