$:.push "./lib"

require 'csv'
require 'optparse'
require 'yaml'
require 'set'
require 'digest'

require 'lunch_roulette/config'
require 'lunch_roulette/enumerable_extension'
require 'lunch_roulette/lunch_group'
require 'lunch_roulette/person'
require 'lunch_roulette/output'
require 'lunch_roulette/math_extension'

class LunchRoulette

  attr_reader :results, :staff, :lunch_sets, :participants

  def initialize(*args)
    LunchRoulette::Config.new
    options = Hash.new
    options[:most_varied_sets] = 1

    o = OptionParser.new do |o|
      o.banner = "Usage: ruby lunch_roulette_generator.rb staff.csv [OPTIONS]"
      o.on('-n', '--min-group-size N', 'Minimum Lunch Group Size (default 4)') {|n| options[:min_lunch_group_size] = n.to_i }
      o.on('-i', '--iterations I', 'Number of Iterations (default 1,000)') {|i| options[:iterations] = i.to_i }
      o.on('-m', '--most-varied-sets M', 'Number of most varied sets to generate (default 1)') {|i| options[:most_varied_sets] = i.to_i }
      o.on('-l', '--least-varied-sets L', 'Number of least varied sets to generate (default 0)') {|i| options[:least_varied_sets] = i.to_i }
      o.on('-v', '--verbose', 'Verbose output') { options[:verbose_output] = true }
      o.on('-d', '--dont-write', "Don't write to files") { options[:dont_write] = true }
      o.on('-s', '--output-stats', "Output a csv of stats for all valid generated sets") { options[:output_stats] = true }
      o.on('-h', '--help', 'Print this help') { puts o; exit }
      o.parse!
    end

    begin
      raise OptionParser::MissingArgument if not ARGV[0]
      @staff_csv = "#{ARGV[0]}"
    rescue OptionParser::MissingArgument, NameError
      if !ARGV[0]
        puts "Must specify staff.csv"
      else
        puts "Error attempting to load #{staff_csv}"
      end
      puts o
      exit 1
    end
    config.options = options

    @participants = compile_participants
    if @participants.size % 2 != 0
      puts "Odd number of participants"
      exit 1
    end
  end

  def config
    LunchRoulette::Config
  end

  def iterate
    # Shuffle participants to make lunch set unpredictable
    @participants.shuffle!

    @lunch_sets = Set.new
    create_pairs([], @participants, true)

    @lunch_sets
  end

  def create_pairs(existing_pairs = [], remaining_people, first_level)
     # Stop working if there is already a possible lunch set
    if !@lunch_sets.empty?
      return
    end

    # Take next person to create a new pair
    remaining_people.each {|first_person|
      # Calculate all possible second persons for pair
      possible_combinations = remaining_people - [first_person]

      possible_combinations.each {|second_person|
        lunch_set = Array.new(existing_pairs)

        pair = LunchPair.new(first_person, second_person)

        #Check whether this is a good combination
        if !pair.matches
          next
        end

        lunch_set << pair

        # Recalculate remaining people
        reduced_remaining_people = possible_combinations - [second_person]

        if reduced_remaining_people.size > 4
          result = create_pairs(lunch_set, reduced_remaining_people, false)
        else
          # Create all possible combinations of remaining people and create
          create_remaining_pairs(reduced_remaining_people).each {|remaining_set|
            if remaining_set.first.matches && remaining_set.last.matches
              @lunch_sets << lunch_set + remaining_set
            end
          }
        end
      }
      break if first_level
    }
  end

  private
  def create_remaining_pairs(set)
    combinations = []

    pair1 = LunchPair.new(set[0], set[1])
    pair2 = LunchPair.new(set[0], set[2])
    pair3 = LunchPair.new(set[0], set[3])
    pair4 = LunchPair.new(set[1], set[2])
    pair5 = LunchPair.new(set[1], set[3])
    pair6 = LunchPair.new(set[2], set[3])

    combinations << [pair1, pair6]
    combinations << [pair2, pair5]
    combinations << [pair3, pair4]
    combinations
  end

  private
  def compile_participants
    staff = []
    CSV.foreach(@staff_csv, headers: true) do |row|
      staffer = Person.new(Hash[row])
      staff << staffer
    end
    # Filter "unlunchables"
    staff = staff.select{ |s| s.lunchable }
  end
end

l = LunchRoulette.new(ARGV)
set = l.iterate

set.first.each {|item|
  puts "#{item.first_person.name} (#{item.first_person.user_id}) - #{item.second_person.name} (#{item.second_person.user_id})"
}

#o = LunchRoulette::Output.new(l.results, l.all_valid_sets)
#o.get_results
#o.get_stats_csv if o.config.options[:output_stats]

#if l.results[:top].size > 0 || l.results[:bottom].size > 0
#  o.get_new_staff_csv(l.staff)
#else
  #puts "No valid sets generated, sorry."
#end
