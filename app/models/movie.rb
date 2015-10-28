class Movie < ActiveRecord::Base
	belongs_to :rating, class_name: 'Rating'

	attr_accessor :rating_records
  	attr_accessor :temp_score

  	def initialize(id)
   		@id = id
    	@rating_records = Array.new
    	@temp_score = 0
  	end
end
