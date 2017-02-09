class LunchRoulette

  class LunchPair

    attr_accessor :first_person, :second_person

    def initialize(first_person, second_person)
      @first_person = first_person
      @second_person = second_person
    end

    public
    def matches
      never_had_lunch_together & are_from_different_departments
    end

    def never_had_lunch_together
      check = !(@first_person.previous_lunches.include?(@second_person.user_id.to_i))

      if(!check)
        puts "#{@first_person.previous_lunches} --> #{second_person.user_id.to_i}"
      else
        puts "x"
      end

      check
    end

    def are_from_different_departments
      @first_person.team != @second_person.team
    end
  end

end
