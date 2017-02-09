class LunchRoulette
  class Config

    def initialize
      @@config = YAML::load(File.open('config/mappings_and_weights.yml'))
      @@maxes = {}
      @@previous_lunches = {}
    end

    def self.team_mappings
      @@config['team_mappings']
    end

    def self.maxes=(m)
      @@maxes = m
    end

    def self.maxes
      @@maxes
    end

    def self.previous_lunches=(p)
      @@previous_lunches = p
    end

    def self.previous_lunches
      @@previous_lunches
    end

    def self.options=(o)
      @@options = o
    end

    def self.options
      @@options
    end

  end
end
