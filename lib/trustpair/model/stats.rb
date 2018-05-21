class Stats
  attr_accessor :total_input,
                :valid_sirets_count,
                :companies_before_1950,
                :companies_1950_1975,
                :companies_1976_1995,
                :companies_before_1995_and_2005,
                :companies_after_2005

  def initialize
    self.total_input = 0
    self.valid_sirets_count = 0
    self.companies_before_1950 = 0
    self.companies_1950_1975 = 0
    self.companies_1976_1995 = 0
    self.companies_before_1995_and_2005 = 0
    self.companies_after_2005 = 0
  end

end