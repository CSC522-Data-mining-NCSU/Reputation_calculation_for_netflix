class ReviewRecord < ActiveRecord::Base
  	has_many :submissons, class_name: "Submission", foreign_key: 'submission_id'
	has_many :reviewers, class_name: "Reviewer", foreign_key: 'reviewer_id'
  	attr_accessor :submission_id
    attr_accessor :reviewer_id
    attr_accessor :score
    attr_accessor :quiz_score
end
