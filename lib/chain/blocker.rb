module Chain
  module Blocker
    extend ActiveSupport::Concern

    included do |base|
      base.field    :blockees_count, type: Integer, default: 0
      base.has_many :blockees, class_name: 'Relationship', as: :blockee, dependent: :destroy
    end

    def block(model)
      if self.id != model.id && !self.blocking?(model)
        self.before_block(model) if self.respond_to?('before_block')
        self.blockees.create!(blocker_type: model.class.name, blocker_id: model.id)
        self.inc(:blockees_count, 1)
        model.inc(:blockers_count, 1)
        self.after_block(model) if self.respond_to?('after_block')
        true
      else
        false
      end
    end

    def unblock(model)
      if self.id != model.id && self.blocking?(model)
        self.before_unblock(model) if self.respond_to?('before_unblock')
        self.blockees.where(blocker_type: model.class.name, blocker_id: model.id).destroy
        self.inc(:blockees_count, -1)
        model.inc(:blockers_count, -1)
        self.after_unblock(model) if self.respond_to?('after_unblock')
        true
      else
        false
      end
    end

    def blocking?(model)
      0 < self.blockees.where(blocker_type: model.class.name, blocker_id: model.id).count
    end
  end
end
