class Api::V1::ReviewsController < ApplicationController
  after_action :publish_article, only: :create


  def create
    article = Article.find(params[:article_id])
    if article.published === false
      review = article.reviews.create(review_params)
      if review.persisted?
        render json: { message: 'Successfully created', review_id: review.id, score: review.score, comment: review.comment }
      else
        render json: { error: review.errors.full_messages }
      end
    else 
      render json: { error: 'Article is not up for review'}, status: 400
    end
  end
  
  private
    def review_params
      params.require(:review).permit(:score, :comment)
    end

    def publish_article      
      article = Article.find(params[:article_id])
      if article.reviews.count >= 3
        average_score = article.reviews.sum(&:score)/article.reviews.count.to_f
        if average_score >= 6
          article.update(published: true)
        end
      end
    end
end

