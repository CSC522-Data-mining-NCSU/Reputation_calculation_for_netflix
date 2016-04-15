class CalculationsController < ApplicationController
	#Instead of completely turning off the built in security, 
	#kills off any session that might exist when something hits the server without the CSRF token.
	protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
	
	swagger_controller :calculations, "Calculations"

	swagger_api :reputation_algorithms do
	  summary "Fetches reputation value for each peer reviewer"
	  param :expert_grades, :string, :optional, "Expert Grades"
	  param :initial_hamer_reputation, :string, :optional, "Initial Hamer Reputation"
	  param :initial_lauw_reputation, :string, :optional, "Initial Lauw Reputation"
	  param :quiz_scores, :string, :optional, "Quiz Scores"
	  param :peer_review_records, :string, :required, "Peer Review Records"
	  response :unauthorized
	  response :not_acceptable
	  response :unprocessable_entity
	end



	#response_to :json
	def reputation_algorithms
		puts "Get post msg!" if !params.nil?
		# Decryption
		if !params[:keys].nil? and !params[:data].nil?
			key = PublicKeyEncryption.rsa_private_key1(params[:keys][0, 350])
			vi = PublicKeyEncryption.rsa_private_key1(params[:keys][350,350])
			# AES symmetric algorithm decrypts data
			aes_encrypted_request_data = params[:data]
			plain_json = JSON.parse(PublicKeyEncryption.aes_decrypt(aes_encrypted_request_data, key, vi))
		elsif params.keys.any? {|key| key.match(/submission[0-9]+/)}
			plain_json = params
		end
		#prepare parameters
		submissions = Hash.new
		reviewer_initial_values = Hash.new
		reviewers = Hash.new
		expert_grades = Hash.new
		quiz_scores = Hash.new
		has_quiz_scores = false
		has_expert_grades = false
		has_initial_hamer_reputation = false
		has_initial_lauw_leniency = false

		plain_json.each do |key, value|
			if /expert_grades/.match(key)
				value.each do |k, v|
					submission_id = k.gsub(/submission/,'').to_i
					expert_grades[submission_id] = v
				end
				has_expert_grades = true
			end

			# initial hamer reputation values are real reputation values with range [0,1]
			if /initial_hamer_reputation/.match(key)
				has_initial_hamer_reputation = true
				value.each do |k ,v|
					reviewer_id = k.gsub(/stu/,'').to_i
					reviewer_initial_values[reviewer_id] = v.to_f
				end
			end

			# initial lauw leniency values can be positive or negative, reputation = 1 - |leniency|
			if /initial_lauw_leniency/.match(key)
				has_initial_lauw_leniency = true
				value.each do |k ,v|
					reviewer_id = k.gsub(/stu/,'').to_i
					reviewer_initial_values[reviewer_id] = v.to_f
				end
			end

			if /quiz_scores/.match(key)
				has_quiz_scores = true
				value.each do |k, v|
					submission_id = k.gsub(/submission/,'').to_i
					quiz_scores[submission_id] = Hash.new
					v.each do |k1, v1| 
						reviewer_id = k1.gsub(/stu/,'').to_i
						quiz_scores[submission_id][reviewer_id] = v1
					end
				end
			end
			if /submission[0-9]+/.match(key)
				submission_id = key.gsub(/submission/,'').to_i
				s = Submission.new(id: submission_id, review_records: Array.new, temp_score: 0)
				value.each do |k, v|
					reviewer_id = k.gsub(/stu/,'').to_i
					next if (has_initial_hamer_reputation or has_initial_lauw_leniency) and !reviewer_initial_values.has_key?(reviewer_id)

					if has_quiz_scores and !quiz_scores[submission_id].nil?
						quiz_score = quiz_scores[submission_id][reviewer_id] ||= 20
					else
						quiz_score = 0.0
					end
					rr = ReviewRecord.new(submission_id: submission_id, reviewer_id: reviewer_id, score: v, quiz_score: quiz_score)
					#check if this reviewer is already in hash.
					if reviewers[k].nil?
						has_initial_hamer_reputation ? weight = reviewer_initial_values[reviewer_id] : weight = 1
						has_initial_lauw_leniency ? leniency = reviewer_initial_values[reviewer_id] : leniency = 0
						r = Reviewer.new(id: reviewer_id, review_records: Array.new, reputation: nil, leniency: leniency, weight: weight, variance: 0)
						# Future improvement: actually storing ReviewRecord.id instead of storing whole ReviewRecord will save lots of space
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
		unless has_quiz_scores
			puts reviewer_initial_values
			final_reputation_hamer = Hamer.calculate_reputations(submissions, reviewers)
		    final_reputation_lauw = Lauw.calculate_reputations(submissions, reviewers)
			final_reputation = Hash.new
			final_reputation['Hamer'] = final_reputation_hamer
			final_reputation['Lauw'] = final_reputation_lauw
			if has_expert_grades
				final_reputation_hamer_expert = HamerExpert.calculate_reputations(submissions, reviewers, expert_grades) 
				final_reputation_lauw_expert = LauwExpert.calculate_reputations(submissions, reviewers, expert_grades)
				final_reputation['HamerExpert'] = final_reputation_hamer_expert
				final_reputation['LauwExpert'] = final_reputation_lauw_expert
			end
			render json: encryption(final_reputation.to_json)
		else
			predicted_grades = Hash.new
			predicted_grades = QuizBased.calculate_predicted_grades(submissions)
			render json: encryption(predicted_grades.to_json)
		end
	end

	private
	def encryption(data)
		# AES symmetric algorithm encrypts raw data
		aes_encrypted_response_data = PublicKeyEncryption.aes_encrypt(data)
		response_body = aes_encrypted_response_data[0]
		# RSA asymmetric algorithm encrypts keys of AES
		encrypted_key = PublicKeyEncryption.rsa_public_key2(aes_encrypted_response_data[1])
		encrypted_vi = PublicKeyEncryption.rsa_public_key2(aes_encrypted_response_data[2])
		# fixed length 350
		response_body.prepend('", "data":"')
		response_body.prepend(encrypted_vi)
		response_body.prepend(encrypted_key)
		# request body should be in JSON format.
		response_body.prepend('{"keys":"')
		response_body << '"}'
		response_body.gsub!(/\n/, '\\n')
	end	
end
