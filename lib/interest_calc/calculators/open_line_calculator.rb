require 'ostruct'
require 'active_support'
require 'active_support/core_ext'

require 'date'


module InterestCalc
  class OpenLineCalculator

    attr_accessor :interest_rate

    def initialize(interest_rate = 0.05)
      @interest_rate = interest_rate
    end

    # calculates the interest per month for an open line of credit
    def calculate(data)

      return_values = []
      nitem = nil
      changes = data[:changes]

      if changes.nil? || changes.count < 1
        raise Exception.new "No changes to the line of credit provided. Please provide an array of changes data[:changes]"
      end

      changes = changes.reverse # allows us to use #pop
      citem = changes.pop
      cdate = citem[:date]
      camount = citem[:amount]

      puts "#{self.class.name}##{__method__}:calculation starts: #{cdate.at_beginning_of_month}"


      return_values << {year: cdate.year,
        month: cdate.month,
        interest: self.calculate_interest(camount, cdate)
      }

      # after this point the calculations for the first month are done

      cdate = cdate.at_beginning_of_month # normalize value to always be the first of the month
      i = 0

      # at the start changes won't be empty and
      # when all the changes have been popped from the stack nitem won't be empty
      while(!changes.empty? || !nitem.nil?)
        puts
        puts
        puts "#{self.class.name}##{__method__}: RUN #{i}"
        i+=1
        # only pop the next item if the previously popped item was used
        nitem = nitem || changes.pop
        ndate = nitem[:date]
        cdate = cdate.next_month
        new_return_value = {year: cdate.year, month: cdate.month}
        # the whole month needs to be calculated at the old amount
        if(ndate.at_beginning_of_month != cdate)
          puts "#{self.class.name}##{__method__}: FULL month calculation"
          return_values << {
            year: cdate.year,
            month: cdate.month,
            interest: self.calculate_interest(camount,cdate)
          }
        else # withdrawal/deposit within this month
          puts "#{self.class.name}##{__method__}: SPLIT month calculation"
          # calculate for first half of month with the old amount

          interest = calculate_interest(camount, cdate, ndate )
          puts "#{self.class.name}##{__method__}: amount changing. OLD:#{camount} -- change:#{nitem[:amount]} -- NEW:#{camount + nitem[:amount]}"
          # change the calculation amount by adding the withdrawal/deposit
          camount += nitem[:amount]

          # calculate interest for 2nd half of month
          interest += calculate_interest(camount, ndate)

          return_values << {
            year: cdate.year,
            month: cdate.month,
            interest: interest
          }

          # reset these variables to pop the next changes-item from the stack
          ndate = nil
          nitem = nil

          # do NOT change cdate as this is already on the 1st of the month and will
          # increase in the while loop

        end


      end # while !changes.empty?
      cdate = cdate.next_month
      # add one final month after the last month with changes
      # so that users know how much interest is per month going forward
      return_values << {year: cdate.year,
        month: cdate.month,
        interest: self.calculate_interest(camount, cdate)
      }

      return return_values

    end


    def print(data)
      values = calculate data

      puts "--------------------------------------"
      puts "|    year-month  |     interest      |"
      puts "--------------------------------------"
      values.each do |item|
        ym = "#{item[:year]}-#{item[:month]}".ljust(16)
        i = item[:interest].to_f.round(2).to_s.rjust(19)
        puts "|#{ym}|#{i}|"
      end
      puts "--------------------------------------"
      return values
    end

    private
    # calculates the interest for current time until either the end of the month (if no end_date given)
    # or the given end_date
    def calculate_interest(camount, cdate, end_date = nil)
      if camount.nil?
        raise "amount can't be nil"
      end

      puts "#{self.class.name}##{__method__}: date:#{cdate} -- end_date:#{end_date}"
      # calculate until end of month if no end_date given.
      # Add one day to include last day in calculations
      end_date = end_date || (cdate.at_end_of_month)

      puts "#{self.class.name}##{__method__}: interest rate: #{@interest_rate}"

      result = interest_days_counter_factor(cdate, end_date) * @interest_rate * camount

      puts "#{self.class.name}##{__method__}: calculated interest: #{result}"
      return result
    end

    # returns the days counter factor based on European act/360 calculation strategy
    def interest_days_counter_factor(date, end_date)

      # use European style of calculation where any date on the 31st is
      # counted as 30st
      date = date - 1.day if 31 == date.mday
      end_date = end_date - 1.day if 31 == end_date.mday

      # add 1 to count the first day as well
      days = ((end_date - date).to_i + 1)
      factor = days / 360.0
      puts "#{self.class.name}##{__method__}: days #{days}-- factor:#{factor}"
      factor
    end
  end
end
