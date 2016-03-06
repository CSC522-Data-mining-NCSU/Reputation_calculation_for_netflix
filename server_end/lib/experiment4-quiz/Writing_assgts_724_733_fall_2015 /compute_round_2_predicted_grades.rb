require 'pry'
require 'json'

peer_review_records = Hash.new
hamer_repu_round_2 = Hash.new
lauw_repu_round_2 = Hash.new
hamer_repu_round_1 = Hash.new
lauw_repu_round_1 = Hash.new
quiz_takers = Hash.new
predicted_grades_naive_average = Hash.new
predicted_grades_hamer_repu_round_2 = Hash.new
predicted_grades_lauw_repu_round_2 = Hash.new

# these writing assgts peer review records are different from normal ones.
# since it already exclude peer reviewers who did not do quizzes.
f = File.open("writing_assgts_round_2_peer_review_records.txt", "r")
f.each_line{ |line| peer_review_records = JSON.parse(line) }
f.close

f = File.open("[quiz]quiz_takers_from_writing_assgts.txt", "r")
f.each_line{ |line| quiz_takers = JSON.parse(line) }
f.close

f = File.open("[hamer]reputation_values_for_writing_assgts_round_2_without_expert_grades.txt", "r")
f.each_line{ |line| hamer_repu_round_2 = JSON.parse(line) }
f.close

f = File.open("[lauw]reputation_values_for_writing_assgts_round_2_without_expert_grades.txt", "r")
f.each_line{ |line| lauw_repu_round_2 = JSON.parse(line) }
f.close

f = File.open("[hamer]reputation_values_for_writing_assgts_round_1_without_expert_grades.txt", "r")
f.each_line{ |line| hamer_repu_round_1 = JSON.parse(line) }
f.close

f = File.open("[lauw]reputation_values_for_writing_assgts_round_1_without_expert_grades.txt", "r")
f.each_line{ |line| lauw_repu_round_1 = JSON.parse(line) }
f.close

total_stu_num =Array.new
peer_grades_for_each_submission = Array.new

peer_review_records.each do |submission, value|
	sum_naive_average = 0
	sum_hamer_repu_round_2 = 0
	sum_lauw_repu_round_2 = 0
	weight_naive_average = 0
	weight_hamer_repu_round_2 = 0
	weight_lauw_repu_round_2 = 0
	all_reputation_values_available = true
	value.each do |stu, grade|
		stu = stu.gsub(/stu/,'')
		all_reputation_values_available = (hamer_repu_round_2.has_key?(stu) and lauw_repu_round_2.has_key?(stu) and quiz_takers.has_key?(stu) and hamer_repu_round_1.has_key?(stu) and lauw_repu_round_1.has_key?(stu))
		if all_reputation_values_available == true
			total_stu_num << stu if !total_stu_num.include? stu
			peer_grades_for_each_submission << grade

			sum_naive_average += grade
			weight_naive_average += 1

			sum_hamer_repu_round_2 += grade * hamer_repu_round_2[stu]
			weight_hamer_repu_round_2 += hamer_repu_round_2[stu]

			sum_lauw_repu_round_2 += grade * lauw_repu_round_2[stu]
			weight_lauw_repu_round_2 += lauw_repu_round_2[stu]
		end
	end

    sorted = peer_grades_for_each_submission.sort
  	len = sorted.length
  	predicted_grades_naive_average[submission] = (1.0 * sum_naive_average / weight_naive_average).round(3)
	predicted_grades_hamer_repu_round_2[submission] = (1.0 * sum_hamer_repu_round_2 / weight_hamer_repu_round_2).round(3)
	predicted_grades_lauw_repu_round_2[submission] = (1.0 * sum_lauw_repu_round_2 / weight_lauw_repu_round_2).round(3)

	peer_grades_for_each_submission = []
end

puts "=====naive_average_round_2==================="
puts predicted_grades_naive_average
puts "=====hamer_repu_round_2==================="
puts predicted_grades_hamer_repu_round_2
puts "=====lauw_repu_round_2==================="
puts predicted_grades_lauw_repu_round_2
puts "=====total_stu_num==================="
print total_stu_num.sort
puts
puts total_stu_num.size