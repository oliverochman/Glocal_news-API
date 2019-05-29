require 'rails_helper'

RSpec.describe Api::V1::ReviewsController, type: :request do
  let(:headers) { { HTTP_ACCEPT: 'application/json' } }
  let(:article) { FactoryBot.create(:article) }

  describe 'POST /api/v1/articles/id/reviews' do
    describe 'successfully' do
      before do
        post "/api/v1/articles/"+"#{article.id}"+"/reviews", params: {
          review: { 
            score: 8, 
            comment: "Good article, well done!"
          }
        }, headers: headers
      end

      it 'creates a review entry' do
        expect(json_response['message']).to eq 'Successfully created'
      end

      it 'sends back the newly created reviews score as a response ' do
        expect(json_response['score']).to eq 8
      end

      it 'sends back the newly created reviews comment as a response ' do
        expect(json_response['comment']).to eq "Good article, well done!"
      end

      it 'attaches the review to the correct article' do
        expect(article.reviews.last.comment).to eq "Good article, well done!"
      end
    end

    describe 'unsuccessfully' do
      it 'can not be created without providing both, score and comment' do
        post "/api/v1/articles/"+"#{article.id}"+"/reviews", params: {
          review: {
            score: 8
          }
        }, headers: headers
      
        expect(json_response['error']).to eq ["Comment can't be blank"]
      end
    end

    describe 'successfully publishes article if 3 reviews or more and score is high enough' do
      before do
        2.times { FactoryBot.create(:review, article_id: article.id, score: 10) }
        post "/api/v1/articles/"+"#{article.id}"+"/reviews", params: {
          review: { 
            score: 10, 
            comment: "Good article, well done!"
          }
        }, headers: headers
        article.reload
      end

      it 'publishes article' do
        expect(article.published).to eq true
      end
    end

    describe 'more then 3 reviews but not high enough average score' do
      before do
        2.times { FactoryBot.create(:review, article_id: article.id, score: 1) }
        post "/api/v1/articles/"+"#{article.id}"+"/reviews", params: {
          review: { 
            score: 4, 
            comment: "Good article, well done!"
          }
        }, headers: headers
        article.reload
      end

      it 'dont publishes article' do
        expect(article.published).to eq false
      end

    end

    describe 'cant leave review if article is published' do
      before do
        article.update(published: true)
        post "/api/v1/articles/"+"#{article.id}"+"/reviews", params: {
          review: { 
            score: 8, 
            comment: "Good article, well done!"
          }
        }, headers: headers
      end

      it 'renders error message' do
        expect(json_response['error']).to eq 'Article is not up for review'
      end
    end
  end 
end