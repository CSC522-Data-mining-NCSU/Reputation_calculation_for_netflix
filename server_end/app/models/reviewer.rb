class Reviewer < ActiveRecord::Base
	belongs_to :review_record, class_name: 'ReviewRecord'
	attr_accessor :id
    attr_accessor :review_records
    attr_accessor :reputation
    attr_accessor :leniency
end
