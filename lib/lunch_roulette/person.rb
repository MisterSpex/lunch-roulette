class LunchRoulette
  class Person
    attr_accessor :name, :lunchable, :previous_lunches, :features, :team, :specialty, :user_id, :start_date, :table, :email
    def initialize(hash)
      @lunchable = %w(true TRUE).include? hash['lunchable']
      @team = hash['team']
      @user_id = hash['user_id']
      @email = hash['email']
      @name = hash['name']
      @previous_lunches = []
      if hash['previous_lunches']
        @previous_lunches = hash['previous_lunches'].split(',').map{|i| i.to_i }
        config.maxes['lunch_id'] = @previous_lunches.max if @previous_lunches && (@previous_lunches.max > config.maxes['lunch_id'].to_i)
        # Generate previous lunches to person mappings:
        
      end
    end

    def inspect
      s = @name
      if @specialty
        s += " (#{@team} - #{@specialty}"
      else
        s += " (#{@team}"
      end
      s += ", Table #{@table})"
      s
    end

    def config
      LunchRoulette::Config
    end

  end
end
