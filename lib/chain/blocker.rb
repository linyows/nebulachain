module Chain
  module Blocker
    extend ActiveSupport::Concern

    included do |base|
      base.field    :blockers_count, type: Integer, default: 0
      base.has_many :blockers, class_name: 'Relationship', as: :blocker, dependent: :destroy
    end

    def blocker?(model)
      0 < self.blockers.find(:all, conditions: {target_id: model.id}).limit(1).count
    end

    def blockers_count
      self.blockers_count
    end

    def all_blockers
      get_blockers_of(self)
    end

    def common_blockers_with(model)
      model_blockers = get_blockers_of(model)
      self_blockers = get_blockers_of(self)
      self_blockers & model_blockers
    end

    private

      def get_blockers_of(model)
        model.blockers.collect do |f|
          f.target_type.constantize.find(f.target_id)
        end
      end
  end
end
