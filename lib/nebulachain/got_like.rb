module Nebulachain
  module GotLike
    extend ActiveSupport::Concern

    included do |base|
      base.field    :got_likes_count, type: Integer, default: 0
      base.has_many :gave_likes, class_name: 'Relationship', as: :gave_like, dependent: :destroy
    end

    def liked_by?(model)
      0 < self.gave_likes.where(got_like_type: model.class.name, got_like_id: model.id).count
    end

    # liked
    def liked_by(model_name = nil, methods = {})
      methods = model_name and model_name = nil if model_name.is_a?(Hash)
      criteria = methods.present? ?
        self.gave_likes.eval(methods.to_s_of_method_chaining) : self.gave_likes

      if model_name.nil?
        criteria.collect do |doc|
          doc.got_like_type.constantize.find(doc.got_like_id)
        end
      else
        ids = criteria.where(got_like_type: model_name).map { |d| d.got_like_id }
        model_name.constantize.any_in(_id: ids)
      end
    end

    private

    def method_missing(missing_method, *args, &block)
      if missing_method.to_s =~ /^liked_by_(.+)$/
        likes($1.singularize.titleize, args[0])
      else
        super
      end
    end
  end
end
