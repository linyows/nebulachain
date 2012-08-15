module Chain
  module Followee
    extend ActiveSupport::Concern

    included do |base|
      base.field    :followers_count, type: Integer, default: 0
      base.has_many :followers, class_name: 'Relationship', as: :follower, dependent: :destroy
    end

    def followed_by?(model)
      0 < self.followers.where(followee_type: model.class.name, followee_id: model.id).count
    end
  end
end
