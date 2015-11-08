class Submission < ActiveRecord::Base
	belongs_to :review_record, class_name: 'ReviewRecord'
	attr_accessor :id
	attr_accessor :review_records
    attr_accessor :temp_score
end
