module Nebulachain
  module Blocker
    extend ActiveSupport::Concern

    included do |base|
      base.field    :blockers_count, type: Integer, default: 0
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

    # blockees
    def blocking(model_name = nil, methods = {})
      methods = model_name and model_name = nil if model_name.is_a?(Hash)
      criteria = methods.present? ?
        self.blockees.eval(methods.to_s_of_method_chaining) : self.blockees

      if model_name.nil?
        criteria.collect do |doc|
          doc.blocker_type.constantize.find(doc.blocker_id)
        end
      else
        ids = criteria.where(blocker_type: model_name).map { |d| d.blocker_id }
        model_name.constantize.any_in(_id: ids)
      end
    end

    private

    def method_missing(missing_method, *args, &block)
      if missing_method.to_s =~ /^blocking_(.+)$/
        blocking($1.singularize.titleize, args[0])
      else
        super
      end
    end
  end
end
