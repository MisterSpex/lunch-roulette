class LunchRoulette
  class Output

    def initialize(result)
      @result = result
      @all_valid_sets
    end

    def config
      LunchRoulette::Config
    end

    def print_result
      @result.each {|pair|
        o = [ "#{pair.first_person.name} (#{pair.first_person.user_id})", "#{pair.second_person.name} (#{pair.second_person.user_id})" ]
        puts o.join("\t")
      }
    end

    def write_new_staff_csv(staff)
      person_lunch_mapping = Hash.new
      @result.each{|pair|
          pair.people.each{|person|
            person_lunch_mapping[person.user_id] = pair.partner(person).user_id
          }
      }

      if config.options[:dont_write]
        file = "/dev/null"
      else
        timestamp = Time.now.strftime "%Y%m%d-%H%M%S"
        file = "data/output/#{timestamp}.csv"
      end
      CSV.open(file, "w") do |csv|
        csv << %w(user_id name team lunchable previous_lunches)
        staff.each do |luncher|
          o = [ luncher.user_id, luncher.name, luncher.team, luncher.lunchable, [luncher.previous_lunches, person_lunch_mapping[luncher.user_id]].flatten.join(",") ]
          puts o.join("\t") if config.options[:verbose_output]
          csv << o
        end
        puts "\nStaff file written to: #{file}\n" unless config.options[:dont_write]
      end
    end

  end
end
