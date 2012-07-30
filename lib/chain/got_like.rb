module Chain
  module GotLike
    extend ActiveSupport::Concern

    included do |base|
      base.field    :got_likes_count, type: Integer, default: 0
      base.has_many :got_likes, class_name: 'Relationship', as: :got_like, dependent: :destroy
    end

    def liked_by?(model)
      0 < self.got_likes.where(target_id: model.id).count
    end

    def all_got_likes
      get_got_likes_of(self)
    end

    def common_got_likes_with(model)
      model_got_likes = get_got_likes_of(model)
      self_got_likes = get_got_likes_of(self)
      self_got_likes & model_got_likes
    end

    private

      def get_got_likes_of(model)
        model.got_likes.collect do |f|
          f.target_type.constantize.find(f.target_id)
        end
      end
  end
end
