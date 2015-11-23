class Reviewer < ActiveRecord::Base
	belongs_to :review_record, class_name: 'ReviewRecord'
	attr_accessor :id
    attr_accessor :review_records
    attr_accessor :reputation #for both algs
    attr_accessor :leniency	  #for lauw's alg
    attr_accessor :variance	  #for hamer's alg, intermediate variable, used to calculate weight 
    attr_accessor :weight	  #for hamer's alg 
end
