class FoodRecipe
    attr_accessor :ingredients, :url, :title, :thumbnail

    def ==(other)
        self.ingredients == other.ingredients &&
        self.url == other.url &&
        self.title == other.title &&
        self.thumbnail == other.thumbnail
    end

    def self.new_collection(attrs_list)
        attrs_list.map { |attrs| new(attrs.with_indifferent_access) }
    end

    def initialize(attrs)
        self.ingredients = (attrs[:ingredients] || "").split(/,\s?/).uniq
        self.url = attrs[:href]
        self.thumbnail = (attrs[:thumbnail] || "")
        self.title = attrs[:title]
    end
end