class Mix < ActiveRecord::Base
  belongs_to :user
  has_one :mix_rank
end
