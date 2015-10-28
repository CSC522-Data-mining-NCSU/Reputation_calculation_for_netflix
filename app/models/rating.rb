class Rating < ActiveRecord::Base
	has_many :movies, class_name: "Movie", foreign_key: 'movie_id'
	has_many :users, class_name: "User", foreign_key: 'user_id'

	alias_attribute :rating, :score

  	def initialize(user_id, score, movie_id)
    	@user_id = user_id
    	@score = score
    	@movie_id = movie_id
  	end
end
