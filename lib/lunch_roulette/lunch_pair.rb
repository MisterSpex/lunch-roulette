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
    end

    def are_from_different_departments
      @first_person.team != @second_person.team
    end

    def people
      [first_person, second_person]
    end

    # Returns the other person of this pair
    def partner(person)
      if person == first_person
        second_person
      else
        first_person
      end
    end

  end
end
