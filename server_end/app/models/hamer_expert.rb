class HamerExpert < ActiveRecord::Base
    ###############################################
    #Define Hamer's algorithm
    #parameters:
    #'submissions'    hash with 'rating_records' array
    #'reviewers'      hash with 'rating_records' array
    #'expert_grades'  hash
    ###############################################
    def self.calculate_reputations(submissions, reviewers, expert_grades)

      # Iterate until convergence
      iterator = 1
      precision = 4
      begin
        # Store previous weights to determine convergence
        previous_weights = Array.new
        current_weights = Array.new
        reviewers.each do |key, reviewer|
          previous_weights << reviewer.weight
        end
        #puts "=========================previous_weights=========================="
        reviewers.each do |key, reviewer|
          #puts reviewer.id.to_s + ": " + reviewer.weight.to_s
        end

        # Reset reviewer variance each round
        reviewers.each {|key, reviewer| reviewer.variance = 0 }

        # Pass 1: Calculate reviewer distance from average (variance)
        submissions.each do |key, submission|
          # Find current weighted average
          review_records = submission.review_records
          weighted_scores = 0
          sum_weight = 0
          predicted_score = expert_grades[submission.id]

          # Add to the reviewers' variance average
          review_records.each do |rr|
            reviewer = reviewers[rr.reviewer_id]
            variance = (rr.score - predicted_score) ** 2
            if variance == 0
              variance = 0.01
            end
            if reviewer.review_records.count != 0
              reviewer.variance += 1.0 * variance / (reviewer.review_records.count == 0 ? 1 : reviewer.review_records.count)
            end
          end
        end

        # Pass 2: Use reviewer variance to calculate new review score weights
        average_variance = 0
        sum_variance = 0
        reviewers.each do |key, reviewer|
          sum_variance += reviewer.variance
        end
        average_variance = 1.0 * sum_variance / (reviewers.size == 0 ? 1 : reviewers.size)

        reviewers.each do |key, reviewer|
          weight = 1.0 * average_variance / (reviewer.variance == 0 ? 1 : reviewer.variance)
          if weight > 2
            weight = 2 + Math.log10(weight - 1)
          end
          reviewer.weight = weight
          reviewer.reputation = weight
        end

        reviewers.each do |key, reviewer|
          current_weights << reviewer.reputation
        end

        #handle the situation where reputation results cannot convergence.
        iterator += 1
        if iterator % 10000 == 0
          precision -= 1 
          break if precision < 0
        end
      end while ApplicationHelper::convergence?(previous_weights,current_weights, :precision => 4)

      puts "=========================Hamer_extended's final_weights=========================="
      final_reputation = Hash.new
      reviewers.sort_by {|key, reviewer| key.to_i}.to_h.each do |key, reviewer|
          final_reputation[key] = reviewer.reputation.round(3)
          puts 'reviewer' + reviewer.id.to_s + ': ' + reviewer.reputation.to_s
      end

      return final_reputation
    end
end
