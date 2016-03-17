require 'pry'
require 'json'

peer_review_records = Hash.new
hamer_repu_with_expert = Hash.new
lauw_repu_with_expert = Hash.new
hamer_repu_no_expert = Hash.new
lauw_repu_no_expert = Hash.new
predicted_grades_hamer_repu_with_expert = Hash.new
predicted_grades_hamer_repu_no_expert = Hash.new
predicted_grades_lauw_repu_with_expert = Hash.new
predicted_grades_lauw_repu_no_expert = Hash.new

# these writing assgts peer review records are different from normal ones.
# since it already exclude peer reviewers who did not do quizzes.
f = File.open("writing_assgts_round_2_peer_review_records.txt", "r")
f.each_line{ |line| peer_review_records = JSON.parse(line) }
f.close

f = File.open("[hamer]reputation_values_for_writing_assgts_round_2_without_expert_grades.txt", "r")
f.each_line{ |line| hamer_repu_no_expert = JSON.parse(line) }
f.close

f = File.open("[lauw]reputation_values_for_writing_assgts_round_2_without_expert_grades.txt", "r")
f.each_line{ |line| lauw_repu_no_expert = JSON.parse(line) }
f.close

f = File.open("[hamer]reputation_values_for_writing_assgts_round_2_with_expert_grades.txt", "r")
f.each_line{ |line| hamer_repu_with_expert = JSON.parse(line) }
f.close

f = File.open("[lauw]reputation_values_for_writing_assgts_round_2_with_expert_grades.txt", "r")
f.each_line{ |line| lauw_repu_with_expert = JSON.parse(line) }
f.close

peer_review_records.each do |submission, value|
	sum_hamer_repu_with_expert = 0
	sum_hamer_repu_no_expert = 0
	sum_lauw_repu_with_expert = 0
	sum_lauw_repu_no_expert = 0
	weight_hamer_repu_with_expert = 0
	weight_hamer_repu_no_expert = 0
	weight_lauw_repu_with_expert = 0
	weight_lauw_repu_no_expert = 0

	value.each do |stu, grade|
		stu = stu.gsub(/stu/,'')
		all_reputation_values_available = (hamer_repu_with_expert.has_key?(stu) and lauw_repu_with_expert.has_key?(stu) and hamer_repu_no_expert.has_key?(stu) and lauw_repu_no_expert.has_key?(stu))
		if all_reputation_values_available == true

			sum_hamer_repu_with_expert += grade * hamer_repu_with_expert[stu]
			weight_hamer_repu_with_expert += hamer_repu_with_expert[stu]

			sum_lauw_repu_with_expert += grade * lauw_repu_with_expert[stu]
			weight_lauw_repu_with_expert += lauw_repu_with_expert[stu]

			sum_hamer_repu_no_expert += grade * hamer_repu_no_expert[stu]
			weight_hamer_repu_no_expert += hamer_repu_no_expert[stu]

			sum_lauw_repu_no_expert += grade * lauw_repu_no_expert[stu]
			weight_lauw_repu_no_expert += lauw_repu_no_expert[stu]
		end
	end

	predicted_grades_hamer_repu_with_expert[submission] = (1.0 * sum_hamer_repu_with_expert / weight_hamer_repu_with_expert).round(3)
	predicted_grades_lauw_repu_with_expert[submission] = (1.0 * sum_lauw_repu_with_expert / weight_lauw_repu_with_expert).round(3)

	predicted_grades_hamer_repu_no_expert[submission] = (1.0 * sum_hamer_repu_no_expert / weight_hamer_repu_no_expert).round(3)
	predicted_grades_lauw_repu_no_expert[submission] = (1.0 * sum_lauw_repu_no_expert / weight_lauw_repu_no_expert).round(3)

end

puts "=====hamer_repu_no_expert==================="
puts predicted_grades_hamer_repu_no_expert
puts "=====lauw_repu_no_expert==================="
puts predicted_grades_lauw_repu_no_expert
puts "=====hamer_repu_with_expert==================="
puts predicted_grades_hamer_repu_with_expert
puts "=====lauw_repu_with_expert==================="
puts predicted_grades_lauw_repu_with_expert