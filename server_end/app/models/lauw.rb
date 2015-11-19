class Lauw < ActiveRecord::Base
	###############################################
	#Define Lauw's algorithm
	#parameters:
	#'submissions' hash with 'rating_records' array
	#'reviewers'   hash with 'rating_records' array
	###############################################
	def self.calculate_reputations(submissions, reviewers)
	  alpha = 0.5  #self-defined

	  # Iterate until convergence
	  begin
	    previous_leniency = Array.new
	    reviewers.each do |key, reviewer|
	    	previous_leniency << reviewer.leniency
	    end
	    puts "=========================previous_leniencies=========================="
	    #previous_leniency.each_with_index do |leniency, index|
	    #  puts reviewers[index+1].to_s + ": " + leniency.to_s
	    #end
	    # Pass 1: calculated weighted grades for each submission
	    submissions.each do |key, submission|
	      sum_weighted_grades = 0.0
	      submission.review_records.each do |rr|
	      	reviewer_leniency = reviewers[rr.reviewer_id].leniency
	        sum_weighted_grades = sum_weighted_grades+rr.score*(1-alpha*reviewer_leniency)
	      end
	      submission.temp_score = 1.0 * sum_weighted_grades.to_f/(submission.review_records.size == 0 ? 1 : submission.review_records.size)
	      #puts "temp_score=" + submission.temp_score.to_s
	    end

	    #Pass 2: calculate leniencies for each reviewer
	    reviewers.each do |key, reviewer|
        sum_leniency=0.0
        reviewer.review_records.each do |rr|
          submission_temp_score = submissions[rr.submission_id].temp_score
          if rr.score!=0
            temp_leniency = 1.0 * (rr.score-submission_temp_score)/(rr.score == 0 ? 1 : rr.score)
            if temp_leniency>1
              temp_leniency=1
            end
            if temp_leniency<-1
              temp_leniency=-1
            end
            sum_leniency=sum_leniency+temp_leniency
          else
            sum_leniency=sum_leniency+1.0 * (rr.score-submission_temp_score)/(submission_temp_score == 0 ? 1 : submission_temp_score)
          end
        end

	      if reviewer.review_records.size==0
            reviewer.leniency=0
          else
            reviewer.leniency=1.0 * sum_leniency/(reviewer.review_records.size == 0 ? 1 : reviewer.review_records.size)
            #puts "sum_leniency/reviewer.review_records.size:" + sum_leniency.to_s+"/"+reviewer.review_records.size.to_s+"="+reviewer.leniency.to_s
          end
        end

        current_leniency = Array.new
        reviewers.each do |key, reviewer|
	    	current_leniency << reviewer.leniency
	    end
      end while ApplicationHelper::convergence?(previous_leniency,current_leniency, :precision => 4)
      #for each reviewer, use absolute value of leniency as reputation. At the same time make 1 the highest reputation and 0 the lowest
      reviewers.each do |key, reviewer|
        reviewer.reputation = 1 - (reviewer.leniency).abs
      end

      #for each reviewer, if no peer-review has been done in current task,  reputation =N/A
	  puts "=========================Lauw's final_weights=========================="
      final_reputation = Hash.new
      reviewers.sort_by {|key, reviewer| key.to_i}.to_h.each do |key, reviewer|
	    	final_reputation[key] = reviewer.reputation.round(3)
	    	puts 'reviewer' + reviewer.id.to_s + ': ' + reviewer.reputation.to_s
	  end

	  return final_reputation
	end

	
end
