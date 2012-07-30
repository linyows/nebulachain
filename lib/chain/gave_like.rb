module Chain
  module GaveLike
    extend ActiveSupport::Concern

    included do |base|
      base.field    :gave_likes_count, type: Integer, default: 0
      base.has_many :gave_likes, class_name: 'Relationship', as: :gave_like, dependent: :destroy
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
      model.before_liked_by(self) if model.respond_to?('before_liked_by')
      model.got_likes.create!(target_type: self.class.name, target_id: self.id)
      model.inc(:got_likes_count, 1)
      model.after_liked_by(self) if model.respond_to?('after_liked_by')
      self.before_like(model) if self.respond_to?('before_like')
      self.gave_likes.create!(target_type: model.class.name, target_id: model.id)
      self.inc(:gave_likes_count, 1)
      self.after_like(model) if self.respond_to?('after_like')
    end

    def unlike(model)
      self.like?(model) ? self.unlike!(model) : false
    end

    def unlike!(model)
      model.before_unliked_by(self) if model.respond_to?('before_unliked_by')
      model.got_likes.where(target_type: self.class.name, target_id: self.id).destroy
      model.inc(:got_likes_count, -1)
      model.after_unliked_by(self) if model.respond_to?('after_unliked_by')
      self.before_unlike(model) if self.respond_to?('before_unlike')
      self.gave_likes.where(target_type: model.class.name, target_id: model.id).destroy
      self.inc(:gave_likes_count, -1)
      self.after_unlike(model) if self.respond_to?('after_unlike')
    end

    def like?(model)
      0 < self.gave_likes.where(target_id: model.id).count
    end

    def all_gave_likes
      get_gave_likes_of(self)
    end

    def common_gave_likes_with(model)
      model_gave_likes = get_gave_likes_of(model)
      self_gave_likes = get_gave_likes_of(self)
      self_gave_likes & model_gave_likes
    end

    private

      def get_gave_likes_of(model)
        model.gave_likes.collect do |f|
          f.target_type.constantize.find(f.target_id)
        end
      end
  end
end
