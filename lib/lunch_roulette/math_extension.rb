class LunchRoulette
	class Math_Extension

		def self.factorial(n)
			(1..n).inject {|product, n| product * n }
		end

	end
end
