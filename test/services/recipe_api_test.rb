require 'rails_helper'
require 'pry'
describe RecipeApi do
    let(:recipe) { '{"title": "omlette", "ingredients": "onion,chilli,egg,salt", "href": "www.omletterecipe.com"}' }
    let(:endpoint_url) { "http://www.recipepuppy.com/api" }
    let(:success_response) {
        <<~JSON
        {
            "title":"Recipe Puppy",
            "version":0.1,
            "href":"http:\/\/www.recipepuppy.com\/",
            "results":[
                #{recipe}
            ]
        }
        JSON
    }
    let(:response_page_1) { File.read("#{Rails.root}/test/helpers/recipe_page_1.json")}
    let(:response_page_2) { File.read("#{Rails.root}/test/helpers/recipe_page_2.json")}

    it 'returns the recipe search results' do
        stub_request(:get, endpoint_url)
        .with(query: {q: 'onion'})
        .to_return(body: success_response, status: 200)
        expect(described_class.search(keyword: 'onion')).to include(FoodRecipe.new(JSON.parse(recipe).with_indifferent_access))
    end

    it 'raises unexpected error when status is 500' do
        stub_request(:get, endpoint_url)
        .with(query: {q: 'random'})
        .to_return(status: 500)

        expect { described_class.search(keyword: 'random') }.to raise_error(UnexpectedError)
    end

    it 'raises not found error when status is 404' do
        stub_request(:get, endpoint_url)
        .with(query: {q: 'random'})
        .to_return(status: 404)

        expect { described_class.search(keyword: 'random') }.to raise_error(NotFoundError)
    end

    it 'returns first n results on fetch_n_results' do
        stub_request(:get, endpoint_url)
        .with(query: {q: 'pea', p: 1})
        .to_return(status: 200, body: response_page_1)

        stub_request(:get, endpoint_url)
        .with(query: {q: 'pea', p: 2})
        .to_return(status: 200, body: response_page_2)

        expect(described_class.fetch_n_results(n: 20, keyword: 'pea').count).to eq(20)

    end
end