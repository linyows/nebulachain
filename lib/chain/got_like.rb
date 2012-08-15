module Chain
  module GotLike
    extend ActiveSupport::Concern

    included do |base|
      base.field    :gave_likes_count, type: Integer, default: 0
      base.has_many :gave_likes, class_name: 'Relationship', as: :gave_like, dependent: :destroy
    end

    def liked_by?(model)
      0 < self.gave_likes.where(got_like_type: model.class.name, got_like_id: model.id).count
    end
  end
end
