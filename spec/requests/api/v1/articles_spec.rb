require 'rails_helper'

RSpec.describe Api::V1::ArticlesController, type: :request do
  let(:headers) { { HTTP_ACCEPT: 'application/json' } }

  describe 'GET /api/v1/article' do
    before do
      5.times { FactoryBot.create(:article)}
    end

    it 'returns a collection of articles' do
      get '/api/v1/articles', headers: headers
      expect(json_response['entries'].count).to eq 5
    end

    it 'returns 200 response' do
      get '/api/v1/articles', headers: headers
      expect(response.status).to eq 200
    end
  end

  describe 'POST /api/v1/articles' do
    it 'cretes an article entry' do
      post '/api/v1/articles', params: {
        article: { 
          title: 'Gothenburg is great', 
          ingress: 'According to many', 
          body: 'Not many people really think that Stockholm is a better place to live in', 
          image: 'https://assets.craftacademy.se/images/people/students_group.png'
        }
      }, headers: headers

      expect(json_response['message']).to eq 'Successfully created'
      expect(response.status).to eq 200
    end

    it 'cant be created without all fields present' do
      post '/api/v1/articles', params: {
        article: { 
          title: 'Gothenburg is great'
        }
      }, headers: headers
      
      expect(json_response['error']).to eq ["Ingress can't be blank", "Body can't be blank", "Image can't be blank"]
      expect(response.status).to eq 422
    end
  end
end
