module Nebulachain
  module Blockee
    extend ActiveSupport::Concern

    included do |base|
      base.field    :blockees_count, type: Integer, default: 0
      base.has_many :blockers, class_name: 'Relationship', as: :blocker, dependent: :destroy
    end

    def blocked_by?(model)
      0 < self.blockers.where(blockee_type: model.class.name, blockee_id: model.id).count
    end

    # blockers
    def blocked_by(model_name = nil, methods = {})
      methods = model_name and model_name = nil if model_name.is_a?(Hash)
      criteria = methods.present? ?
        self.blockers.eval(methods.to_s_of_method_chaining) : self.blockers

      if model_name.nil?
        criteria.collect do |doc|
          doc.blockee_type.constantize.find(doc.blockee_id)
        end
      else
        ids = criteria.where(blockee_type: model_name).map { |d| d.blockee_id }
        model_name.constantize.any_in(_id: ids)
      end
    end

    private

    def method_missing(missing_method, *args, &block)
      if missing_method.to_s =~ /^blocked_by_(.+)$/
        blocked_by($1.singularize.titleize, args[0])
      else
        super
      end
    end
  end
end
