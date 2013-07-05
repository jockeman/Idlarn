class MixRank < ActiveRecord::Base
  belongs_to :user
  has_one :mix
end
