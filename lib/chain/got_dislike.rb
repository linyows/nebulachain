module Chain
  module GotDislike
    extend ActiveSupport::Concern

    included do |base|
      base.field    :gave_dislikes_count, type: Integer, default: 0
      base.has_many :gave_dislikes, class_name: 'Relationship', as: :gave_dislike, dependent: :destroy
    end

    def disliked_by?(model)
      0 < self.gave_dislikes.where(got_dislike_type: model.class.name, got_dislike_id: model.id).count
    end

    # disliked
    def disliked_by(model_name = nil, methods = {})
      methods = model_name and model_name = nil if model_name.is_a?(Hash)
      criteria = methods.present? ?
        self.gave_dislikes.eval(methods.to_s_of_method_chaining) : self.gave_dislikes

      if model_name.nil?
        criteria.collect do |doc|
          doc.got_dislike_type.constantize.find(doc.got_dislike_id)
        end
      else
        ids = criteria.where(got_dislike_type: model_name).map { |d| d.got_dislike_id }
        model_name.constantize.any_in(_id: ids)
      end
    end

    private

    def method_missing(missing_method, *args, &block)
      if missing_method.to_s =~ /^disliked_by_(.+)$/
        dislikes($1.singularize.titleize, args[0])
      else
        super
      end
    end
  end
end
