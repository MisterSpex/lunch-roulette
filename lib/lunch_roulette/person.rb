class LunchRoulette
  class Person
    attr_accessor :name, :lunchable, :previous_lunches, :team, :user_id
    def initialize(hash)
      @lunchable = %w(true TRUE).include? hash['lunchable']
      @team = hash['team']
      @user_id = hash['user_id']
      @name = hash['name']
      @previous_lunches = []
      if hash['previous_lunches']
        @previous_lunches = hash['previous_lunches'].split(',').map{|i| i.to_i }
      end
    end
  end
end
