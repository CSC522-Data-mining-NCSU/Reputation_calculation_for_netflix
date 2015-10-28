class User < ActiveRecord::Base
	belongs_to :rating, class_name: 'Rating'

	attr_accessor :rating_records
	attr_accessor :leniency
	attr_accessor :weight

	def initialize(id)
    	@id = id
    	@rating_records = Array.new
    	@reputation = nil
    	@leniency = 0
    end

    def weight
    	@weight
    end
end
