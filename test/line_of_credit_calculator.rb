require "minitest/autorun"
require "interest_calc"

class LineOfCreditCalculatorTest < Minitest::Test
  def test_one_month
    calc = InterestCalc::LineOfCreditCalculator.new(0.1)
    val = calc.calculate LineOfCreditCalculatorTest.simple_test_data
    assert_equal 1, val.length
    val = val.pop
    
    assert_equal 2022, val[:year], "year is not 2022"
    assert_equal 1, val[:month], "month is not 1"
    assert_equal 8.49315068493151, val[:interest], "interest is not , but instead #{val[:amount]}"
  end

  def test_single_withdrawal_one_year
    calc = InterestCalc::LineOfCreditCalculator.new(0.1)
    val = calc.calculate LineOfCreditCalculatorTest.simple_test_data.merge({end_date: Date.new(2022,12,31)})
    assert_equal 12, val.length
    fields = [:year, :month, :interest]
    LineOfCreditCalculatorTest.expected_result_single_withdrawal_one_year.each_with_index do |el, i|
        fields.each do |field_name|
            assert_equal el[field_name], val[i][field_name], "#{field_name} does not match for element ##{i}, #{el[field_name]} != #{val[i][field_name]}"
        end
    end
  end

  def test_empty_changes_raises_exception
    calc = InterestCalc::LineOfCreditCalculator.new(0.1)
    assert_raises(StandardError) {calc.calculate {}}
    assert_raises(StandardError) {calc.calculate {changes:[]}}
  end


  def self.simple_test_data
    data = {
    changes: [
        {date: Date.new(2022,1,1), amount: 1000.0},
      ]
    }
  end
  

  def self.expected_result_single_withdrawal_one_year

    interest_even = 8.219178082191785
    interest_odd = 8.49315068493151
    [
        {year: 2022, month: 1, interest:interest_odd},
        {year: 2022, month: 2, interest:7.671232876712333},
        {year: 2022, month: 3, interest:interest_odd},
        {year: 2022, month: 4, interest:interest_even},
        {year: 2022, month: 5, interest:interest_odd},
        {year: 2022, month: 6, interest:interest_even},
        {year: 2022, month: 7, interest:interest_odd},
        {year: 2022, month: 8, interest:interest_odd},
        {year: 2022, month: 9, interest:interest_even},
        {year: 2022, month: 10, interest:interest_odd},
        {year: 2022, month: 11, interest:interest_even},
        {year: 2022, month: 12, interest:interest_odd},
    ]
  end
end