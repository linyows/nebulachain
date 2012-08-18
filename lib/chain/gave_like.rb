module Chain
  module GaveLike
    extend ActiveSupport::Concern

    included do |base|
      base.field    :gave_likes_count, type: Integer, default: 0
      base.has_many :got_likes, class_name: 'Relationship', as: :got_like, dependent: :destroy
    end

    def toggle_like(model)
      # unlike
      if self.like?(model)
        self.unlike!(model)
      # like
      else
        self.undislike(model)
        self.like!(model)
      end
    end

    def like(model)
      if !self.like?(model)
        self.undislike(model)
        self.like!(model)
      else
        false
      end
    end

    def like!(model)
      self.before_like(model) if self.respond_to?('before_like')
      self.got_likes.create!(gave_like_type: model.class.name, gave_like_id: model.id)
      self.inc(:gave_likes_count, 1)
      model.inc(:got_likes_count, 1)
      self.after_like(model) if self.respond_to?('after_like')
    end

    def unlike(model)
      self.like?(model) ? self.unlike!(model) : false
    end

    def unlike!(model)
      self.before_unlike(model) if self.respond_to?('before_unlike')
      self.got_likes.where(gave_like_type: model.class.name, gave_like_id: model.id).destroy
      self.inc(:gave_likes_count, -1)
      model.inc(:got_likes_count, -1)
      self.after_unlike(model) if self.respond_to?('after_unlike')
    end

    def like?(model)
      0 < self.got_likes.where(gave_like_type: model.class.name, gave_like_id: model.id).count
    end

    # likes
    def likes(model_name = nil, methods = {})
      methods = model_name and model_name = nil if model_name.is_a?(Hash)
      criteria = methods.present? ?
        self.got_likes.eval(methods.to_s_of_method_chaining) : self.got_likes

      if model_name.nil?
        criteria.collect do |doc|
          doc.gave_like_type.constantize.find(doc.gave_like_id)
        end
      else
        ids = criteria.where(gave_like_type: model_name).map { |d| d.gave_like_id }
        model_name.constantize.any_in(_id: ids)
      end
    end

    private

    def method_missing(missing_method, *args, &block)
      if missing_method.to_s =~ /^likes_(.+)$/
        likes($1.singularize.titleize, args[0])
      else
        super
      end
    end
  end
end
