class Player < ApplicationRecord
  belongs_to :team
  validates_uniqueness_of :name
  validates :name, presence: true,
            length: { minimum: 2 }

  enum role: [ :batsman, :bowler, :wicket_keeper ]
end
