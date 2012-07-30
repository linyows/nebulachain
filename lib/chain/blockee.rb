module Chain
  module Blockee
    extend ActiveSupport::Concern

    included do |base|
      base.field    :blockees_count, type: Integer, default: 0
      base.has_many :blockees, class_name: 'Relationship', as: :blockee, dependent: :destroy
    end

    def block(model)
      if self.id != model.id && !self.blocking?(model)
        model.before_blocked_by(self) if model.respond_to?('before_blocked_by')
        model.unfollow(self) if self.followers?(model)
        model.blockers.create!(target_type: self.class.name, target_id: self.id)
        model.inc(:blockers_count, 1)
        model.after_blocked_by(self) if model.respond_to?('after_blocked_by')
        self.before_block(model) if self.respond_to?('before_block')
        self.blockees.create!(target_type: model.class.name, target_id: model.id)
        self.inc(:blockees_count, 1)
        self.after_block(model) if self.respond_to?('after_block')
        true
      else
        false
      end
    end

    def unblock(model)
      if self.id != model.id && self.blocking?(model)
        model.before_unblocked_by(self) if model.respond_to?('before_unblocked_by')
        model.blockers.where(target_type: self.class.name, target_id: self.id).destroy
        model.inc(:blockers_count, -1)
        model.after_unblocked_by(self) if model.respond_to?('after_unblocked_by')
        self.before_unblock(model) if self.respond_to?('before_unblock')
        self.blockees.where(target_type: model.class.name, target_id: model.id).destroy
        self.inc(:blockees_count, -1)
        self.after_unblock(model) if self.respond_to?('after_unblock')
        true
      else
        false
      end
    end

    def blocking?(model)
      0 < self.blockees.where(target_id: model.id).count
    end

    def blockees_count
      self.blockees_count
    end

    def all_blockees
      get_blockees_of(self)
    end

    def common_blockees_with(model)
      model_blockees = get_blockees_of(model)
      self_blockees = get_blockees_of(self)
      self_blockees & model_blockees
    end

    private

      def get_blockees_of(model)
        model.blockees.collect do |f|
          f.target_type.constantize.find(f.target_id)
        end
      end
  end
end
