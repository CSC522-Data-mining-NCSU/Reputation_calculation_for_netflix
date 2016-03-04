require 'pry'
require 'json'

peer_review_records = Hash.new
hamer_repu = Hash.new
lauw_repu = Hash.new
quiz_takers = Hash.new
predicted_grades_naive_average = Hash.new
predicted_grades_hamer_repu = Hash.new
predicted_grades_lauw_repu = Hash.new

# these writing assgts peer review records are different from normal ones.
# since it already exclude peer reviewers who did not do quizzes.
f = File.open("writing_assgts_peer_review_records.txt", "r")
f.each_line{ |line| peer_review_records = JSON.parse(line) }
f.close

f = File.open("[quiz]quiz_takers_from_writing_assgts.txt", "r")
f.each_line{ |line| quiz_takers = JSON.parse(line) }
f.close

f = File.open("[hamer]reputation_values_for_writing_assgts_without_expert_grades.txt", "r")
f.each_line{ |line| hamer_repu = JSON.parse(line) }
f.close

f = File.open("[lauw]reputation_values_for_writing_assgts_without_expert_grades.txt", "r")
f.each_line{ |line| lauw_repu = JSON.parse(line) }
f.close

total_stu_num =Array.new
peer_grades_for_each_submission = Array.new

peer_review_records.each do |submission, value|
	sum_naive_average = 0
	sum_hamer_repu = 0
	sum_lauw_repu = 0
	weight_naive_average = 0
	weight_hamer_repu = 0
	weight_lauw_repu = 0
	all_reputation_values_available = true
	value.each do |stu, grade|
		stu = stu.gsub(/stu/,'')
		all_reputation_values_available = (hamer_repu.has_key?(stu) and lauw_repu.has_key?(stu) and quiz_takers.has_key?(stu))
		if all_reputation_values_available == true
			total_stu_num << stu if !total_stu_num.include? stu
			peer_grades_for_each_submission << grade

			sum_naive_average += grade
			weight_naive_average += 1

			sum_hamer_repu += grade * hamer_repu[stu]
			weight_hamer_repu += hamer_repu[stu]

			sum_lauw_repu += grade * lauw_repu[stu]
			weight_lauw_repu += lauw_repu[stu]
		end
	end

    sorted = peer_grades_for_each_submission.sort
  	len = sorted.length
  	predicted_grades_naive_average[submission] = (1.0 * sum_naive_average / weight_naive_average).round(3)
	predicted_grades_hamer_repu[submission] = (1.0 * sum_hamer_repu / weight_hamer_repu).round(3)
	predicted_grades_lauw_repu[submission] = (1.0 * sum_lauw_repu / weight_lauw_repu).round(3)

	peer_grades_for_each_submission = []
end

puts "=====naive_average==================="
puts predicted_grades_naive_average
puts "=====hamer_repu==================="
puts predicted_grades_hamer_repu
puts "=====lauw_repu==================="
puts predicted_grades_lauw_repu
puts "=====total_stu_num==================="
print total_stu_num
puts
puts total_stu_num.size