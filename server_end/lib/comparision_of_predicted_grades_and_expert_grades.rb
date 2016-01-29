require 'pry'
require 'json'

peer_review_records = Hash.new
init_repu_one = Hash.new
init_repu_not_one = Hash.new
predicted_grades_init_repu_one = Hash.new
predicted_grades_init_repu_not_one = Hash.new

f = File.open("OSS_f15_peer_review_records.txt", "r")
f.each_line{ |line| peer_review_records = JSON.parse(line) }
f.close

f = File.open("reputation_values_for_OSS_with_init_repu_not_equal_to_one.txt", "r")
f.each_line{ |line| init_repu_not_one = JSON.parse(line) }
f.close

f = File.open("reputation_values_for_OSS_with_init_repu_equal_to_one.txt", "r")
f.each_line{ |line| init_repu_one = JSON.parse(line) }
f.close

peer_review_records.each do |submission, value|
	sum_init_repu_one = 0
	sum_init_repu_not_one = 0
	weight_init_repu_one = 0
	weight_init_repu_not_one = 0

	value.each do |stu, grade|
		stu = stu.gsub(/stu/,'')
		if init_repu_one.has_key?(stu)
			sum_init_repu_one += grade * init_repu_one[stu]
			weight_init_repu_one += init_repu_one[stu]
		end

		if init_repu_not_one.has_key?(stu)
			sum_init_repu_not_one += grade * init_repu_not_one[stu]
			weight_init_repu_not_one += init_repu_not_one[stu]
		end
	end

	predicted_grades_init_repu_one[submission] = (1.0 * sum_init_repu_one / weight_init_repu_one).round(3)
	predicted_grades_init_repu_not_one[submission] = (1.0 * sum_init_repu_not_one / weight_init_repu_not_one).round(3)
end

puts "=====init_repu_one==================="
puts predicted_grades_init_repu_one
puts "=====init_repu_not_one==================="
puts predicted_grades_init_repu_not_one