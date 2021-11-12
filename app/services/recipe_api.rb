require 'httparty'

class NotFoundError < StandardError
    def initialize(msg="No Results Found")
        super
    end
end

class UnexpectedError < StandardError
    def initialize(msg="Unexpected Error Occured")
        super
    end
end


class RecipeApi
    include HTTParty
    base_uri 'www.recipepuppy.com'
    debug_output $stdout

    query_string_normalizer proc { |query|
        query.map do |key, value|
            "#{key}=#{value.kind_of?(Array) ? value.join(',') : value}"
        end.join('&')
    }

    def self.search(keyword: nil, page: nil)
        query = {}
        query[:q] = keyword if keyword.present?
        query[:p] = page if page.present?
        response = get("/api", { query: query })
        case response.code
        when 200    
            results = begin
                JSON.parse(response.body).fetch("results")
              rescue JSON::ParserError, KeyError => e
                Rails.logger.info("RecipePuppy API Error: #{e}")
                []
              end
            FoodRecipe.new_collection(results)
        when 404
            raise NotFoundError.new
        else
            raise UnexpectedError.new
        end
    end

    def self.fetch_n_results(n:, keyword:)
        page = 0
        recipes = []
        total = 0
        
        while total < n
            page +=1
            results = search(keyword: keyword, page: page)
            break if results.empty?

            recipes = recipes + results
            total += results.length
        end
        recipes.first(n)
    end
end