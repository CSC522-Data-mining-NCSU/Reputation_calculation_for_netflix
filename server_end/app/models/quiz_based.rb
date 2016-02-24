class QuizBased < ActiveRecord::Base
	###############################################
	#Define Quiz-based algorithm
	#parameters:
	#'submissions' 		hash with 'rating_records' array
	#'quiz_scores'      hash
	###############################################
	def self.calculate_reputations(submissions)
		predicted_grades = Hash.new

		submissions.each do |key, submission|
			review_records = submission.review_records
			weighted_score_sum = 0
			weight_sum = 0
			review_records.each do |rr|
				weighted_score_sum += rr.score * rr.quiz_score
				weight_sum += rr.quiz_score
			end

			predicted_grades[submission.id] = 1.0 * weighted_score_sum / weight_sum
		end
		return predicted_grades
	end