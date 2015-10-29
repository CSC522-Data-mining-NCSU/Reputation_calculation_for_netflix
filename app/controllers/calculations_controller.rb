class CalculationsController < ApplicationController
	def index
		#ratings
		#puts '==Load ratings data complete=========='
		users
		puts '==Load users data complete=========='
		movies
		puts '==Load movies data complete=========='
		calculate_weighted_scores_and_reputation(@movies, @users)
	end
=begin
    #Add data to @ratings
	def ratings
	  return @ratings if @ratings
	  @ratings = Rating.all
	end
=end
	#Add data to @users
	def users
	  return @users if @users
	  @users = User.all
	  @users.each do |user|
    	user.leniency = 0
    	ratings_done = Rating.where(user_id: user.id)
    	user.rating_records = ratings_done
	  end
	end

	#Add data to @movies
	def movies
	  return @movies if @movies
	  @movies = Movie.select(:id)
	  @movies.each do |movie|
	  	ratings_received = Rating.where(movie_id: movie.id)
	  	movie.rating_records = ratings_received
	  	movie.temp_score = 0
	  end
	end

	#Define Lauw's algorithm
	def calculate_weighted_scores_and_reputation(movies, users)
	  alpha = 0.5  #self-defined

	  # Iterate until convergence
	  iterations = 0
	  begin
	    previous_leniency = @users.map(&:leniency)
	    puts "=========================previous_leniencies=========================="
	    #previous_leniency.each_with_index do |leniency, index|
	    #  puts @users[index].to_s + ": " + leniency.to_s
	    #end

	    # Pass 1: calculated weighted grades for each movie
	    @movies.each do |movie|
	      weighted_score = 0.0
	      movie.rating_records.each do |rr|
	      	reviewer = User.find(rr.user_id)
	        weighted_score += rr.rating * (1 - alpha * reviewer.leniency)
	      end
	      movie.temp_score = weighted_score.to_f / movie.rating_records.size
	      movie.save
	      puts "temp_score=" + movie.temp_score.to_s
	    end

	    #Pass 2: calculate leniencies for each reviewer
	    @users.each do |reviewer|
	      sum_leniency=0.0
	      reviewer.rating_records.each do |rr|
	        if rr.rating != 0
	          movie = Movie.find(rr.movie_id)
	          #When converting leniency to reputation, we use absoluate value. 
	          #So here is no matter whether is 'rr.rating - movie.temp_score' or 'movie.temp_score - rr.rating'.
	          temp_leniency = (rr.rating - movie.temp_score) / (rr.rating)
	          if temp_leniency > 1
	            temp_leniency = 1
	          end
	          if temp_leniency < -1
	            temp_leniency = -1
	          end
	          sum_leniency += temp_leniency
	        else
	          #This line is to aviod user rate 0 for one movie and dividing by 0 is meaningless.
	          sum_leniency += (rr.rating - movie.temp_score) / movie.temp_score
	        end
	      end

	      if reviewer.rating_records.size == 0
	        reviewer.leniency = 0
	      else
	        reviewer.leniency = sum_leniency / reviewer.rating_records.size
	        puts "sum_leniency/reviewer.rating_records.size:" + sum_leniency.to_s+"/"+reviewer.rating_records.size.to_s+"="+reviewer.leniency.to_s
	      end
	      reviewer.save
	    end
	    iterations += 1

	    current_leniency = users.map(&:leniency)
	  end while converged?(previous_leniency,current_leniency)
	  #for each reviewer, use absolute value of leniency as reputation. At the same time make 1 the highest reputation and 0 the lowest
	  users.each do |reviewer|
	    reviewer.reputation = 1 - (reviewer.leniency).abs
	    reviewer.save
	  end

	  #for each reviewer, if no peer-review has been done in current task,  reputation =N/A
	  final_reputation = @users.map(&:reputation)
	  puts "=========================final_weights=========================="
	  @users.each_with_index do |reviewer, index|
	    if reviewer.rating_records.size > 0
	      puts @all_users_simple_array[index].to_s + ": " + final_reputation[index].to_s
	    else
	      puts @all_users_simple_array[index].to_s + ": N/A"
	    end
	  end

	  return :iterations => iterations
	end

	# Ensure all numbers in lists a and b are equal
	# Options: :precision => Number of digits to round to
	def self.converged?(a, b, options={:precision => 1})
	  raise "a and b must be the same size" unless a.size == b.size
	  a.flatten!
	  b.flatten!

	  p = options[:precision]
	  a.map! {|num| num.to_f.round(p)}
	  b.map! {|num| num.to_f.round(p)}

	  #judge initial situation
	  if (a.uniq.length == 1) && (b.uniq.length == 1)
	    return true
	  else
	    result = !(a == b)
	    return result
	  end
	end
end
