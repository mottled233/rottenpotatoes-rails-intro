class Movie < ActiveRecord::Base
    
    def self.get_ratings
       %w[G PG PG-13 R]
    end
end
