class CalculationsController < ApplicationController
	#Instead of completely turning off the built in security, 
	#kills off any session that might exist when something hits the server without the CSRF token.
	protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
	#response_to :json
	def lauw_algorithm
=begin
		Input example:
		{
			"assgt1": {"stu1":91, "stu3":99},
		    "assgt2": {"stu5":92, "stu8":90},
			"assgt1": {"stu2":91, "stu4":88}
		}
=end
		
		#prepare parameters
		submissions = Hash.new
		reviewers = Hash.new
		params.each do |key, value|
			if /submission[0-9]+/.match(key)
				submission_id = key.gsub(/submission/,'').to_i
				s = Submission.new(id: submission_id, review_records: Array.new, temp_score: 0)
				value.each do |k, v|
					reviewer_id = k.gsub(/stu/,'').to_i
					rr = ReviewRecord.new(submission_id: submission_id, reviewer_id: reviewer_id, score: v)
					#check if this reviewer is already in hash.
					if reviewers[k].nil?
						r = Reviewer.new(id: reviewer_id, review_records: Array.new, reputation: nil, leniency: 0)
						r.review_records << rr
						reviewers[reviewer_id] = r
					else 
						r = reviewers[k]
						r.review_records << rr
					end
					s.review_records << rr
				end
				submissions[submission_id] = s
			end
		end

		final_reputation = Lauw.calculate_reputations(submissions, reviewers)
		#render json: final_reputation.to_json
		render json: final_reputation.to_json
	end	
end
