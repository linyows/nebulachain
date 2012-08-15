module Chain
  module Blockee
    extend ActiveSupport::Concern

    included do |base|
      base.field    :blockers_count, type: Integer, default: 0
      base.has_many :blockers, class_name: 'Relationship', as: :blocker, dependent: :destroy
      base.alias_attribute :blocking_id, :blockee_id
      base.alias_attribute :blocking_type, :blockee_type
    end

    def blocked_by?(model)
      0 < self.blockers.where(blockee_id: model.id).count
    end
  end
end
