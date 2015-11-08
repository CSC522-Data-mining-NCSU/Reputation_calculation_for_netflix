module ApplicationHelper
	# Ensure all numbers in lists a and b are equal
	# Options: :precision => Number of digits to round to
	def self.convergence?(a, b, options={:precision => 0.01})
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
