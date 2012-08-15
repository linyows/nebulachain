module Chain
  module Blockee
    extend ActiveSupport::Concern

    included do |base|
      base.field    :blockers_count, type: Integer, default: 0
      base.has_many :blockers, class_name: 'Relationship', as: :blocker, dependent: :destroy
    end

    def blocked_by?(model)
      0 < self.blockers.where(blockee_type: model.class.name, blockee_id: model.id).count
    end
  end
end
