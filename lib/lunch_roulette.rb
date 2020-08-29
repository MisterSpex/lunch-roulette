$:.push "./lib"

require 'csv'
require 'optparse'
require 'set'

require 'lunch_roulette/lunch_pair'
require 'lunch_roulette/person'
require 'lunch_roulette/output'

class LunchRoulette

  def initialize(*args)
    o = OptionParser.new do |o|
      o.banner = "Usage: ruby lunch_roulette_generator.rb staff.csv"
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
      exit 1
    end
  end


  def iterate(participants)
    # Shuffle participants to make lunch set unpredictable
    participants.shuffle!
    @lunch_set = nil
    # Break after first iteration for optimization reasons (true)
    # Explaination: After first iteration without match for the first person there will be no more valid lunch set
    create_pairs([], participants, true)

    @lunch_set
  end

  def create_pairs(existing_pairs = [], remaining_people, break_without_deep_recursion)
    # Stop working if there is already a possible lunch set
    if !@lunch_set.nil?
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
          create_pairs(lunch_set, reduced_remaining_people, false)
        else
          # Create all possible combinations of remaining people and create
          create_remaining_pairs(reduced_remaining_people).each {|remaining_set|
            if remaining_set.first.matches && remaining_set.last.matches
              @lunch_set = lunch_set + remaining_set
              break_without_deep_recursion = true
              break
            end
          }
        end
        # Optimization: # Stop working if there is already a possible lunch set
        break if !@lunch_set.nil?
      }
      break if break_without_deep_recursion
    }
  end

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

  def load_staff_list
    staff = []
    CSV.foreach(@staff_csv, headers: true) do |row|
      staffer = Person.new(Hash[row])
      staff << staffer
    end
    staff
  end
end


####
l = LunchRoulette.new(ARGV)

# Load staff list and filter for "unlunchables"
staff = l.load_staff_list
participants = staff.select{ |s| s.lunchable }
if participants.size % 2 != 0
  puts "Odd number of participants"
  exit 1
end

# Calculate lunch set
set = l.iterate(participants)

# Print & save result
if set.nil?
  puts "No possible lunch set found"
else
  o = LunchRoulette::Output.new(set)
  o.print_result
  o.write_new_staff_csv(staff)
end
