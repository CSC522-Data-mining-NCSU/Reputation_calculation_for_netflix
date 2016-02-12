require 'pry'
require 'json'

peer_review_records = Hash.new
init_repu_one = Hash.new
wiki_1a1b_init_repu_not_one = Hash.new
program_1_init_repu_not_one = Hash.new
predicted_grades_init_repu_one = Hash.new
predicted_grades_wiki_1a1b_init_repu_not_one = Hash.new
predicted_grades_program_1_init_repu_not_one = Hash.new

f = File.open("OSS_f15_peer_review_records.txt", "r")
f.each_line{ |line| peer_review_records = JSON.parse(line) }
f.close

f = File.open("reputation_values_for_OSS_with_init_repu_equal_to_one.txt", "r")
f.each_line{ |line| init_repu_one = JSON.parse(line) }
f.close

f = File.open("[wiki1a1b]reputation_values_for_OSS_with_init_repu_not_equal_to_one.txt", "r")
f.each_line{ |line| wiki_1a1b_init_repu_not_one = JSON.parse(line) }
f.close

f = File.open("[program1]reputation_values_for_OSS_with_init_repu_not_equal_to_one.txt", "r")
f.each_line{ |line| program_1_init_repu_not_one = JSON.parse(line) }
f.close

total_stu_num =Array.new

peer_review_records.each do |submission, value|
	sum_init_repu_one = 0
	sum_wiki_1a1b_init_repu_not_one = 0
	sum_program_1_init_repu_not_one = 0
	weight_init_repu_one = 0
	weight_wiki_1a1b_init_repu_not_one = 0
	weight_program_1_init_repu_not_one = 0
	all_reputation_values_available = true
	value.each do |stu, grade|
		stu = stu.gsub(/stu/,'')
		all_reputation_values_available = (wiki_1a1b_init_repu_not_one.has_key?(stu) and program_1_init_repu_not_one.has_key?(stu) and init_repu_one.has_key?(stu))
		if all_reputation_values_available == true
			total_stu_num << stu if !total_stu_num.include? stu
			sum_init_repu_one += grade * init_repu_one[stu]
			weight_init_repu_one += init_repu_one[stu]

			sum_wiki_1a1b_init_repu_not_one += grade * wiki_1a1b_init_repu_not_one[stu]
			weight_wiki_1a1b_init_repu_not_one += wiki_1a1b_init_repu_not_one[stu]

			sum_program_1_init_repu_not_one += grade * program_1_init_repu_not_one[stu]
			weight_program_1_init_repu_not_one += program_1_init_repu_not_one[stu]
		end
	end

	predicted_grades_init_repu_one[submission] = (1.0 * sum_init_repu_one / weight_init_repu_one).round(3)
	predicted_grades_wiki_1a1b_init_repu_not_one[submission] = (1.0 * sum_wiki_1a1b_init_repu_not_one / weight_wiki_1a1b_init_repu_not_one).round(3)
	predicted_grades_program_1_init_repu_not_one[submission] = (1.0 * sum_program_1_init_repu_not_one / weight_program_1_init_repu_not_one).round(3)
end

puts "=====init_repu_one==================="
puts predicted_grades_init_repu_one
puts "=====wiki_1a1b_init_repu_not_one==================="
puts predicted_grades_wiki_1a1b_init_repu_not_one
puts "=====program_1_init_repu_not_one==================="
puts predicted_grades_program_1_init_repu_not_one
puts "=====total_stu_num==================="
print total_stu_num
puts
puts total_stu_num.size