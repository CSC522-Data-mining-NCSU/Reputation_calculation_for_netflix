class User < ActiveRecord::Base
	belongs_to :rating, class_name: 'Rating'

	attr_accessor :rating_records

	def initialize(id)
    	@id = id
    	@rating_records = Array.new
    end
end
