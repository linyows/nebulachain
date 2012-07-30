module Chain
  module GotDislike
    extend ActiveSupport::Concern

    included do |base|
      base.field    :got_dislikes_count, type: Integer, default: 0
      base.has_many :got_dislikes, class_name: 'Relationship', as: :got_dislike, dependent: :destroy
    end

    def disliked_by?(model)
      0 < self.got_dislikes.where(target_id: model.id).count
    end

    def all_got_dislikes
      get_got_dislikes_of(self)
    end

    def common_got_dislikes_with(model)
      model_got_dislikes = get_got_dislikes_of(model)
      self_got_dislikes = get_got_dislikes_of(self)
      self_got_dislikes & model_got_dislikes
    end

    private

      def get_got_dislikes_of(model)
        model.got_dislikes.collect do |f|
          f.target_type.constantize.find(f.target_id)
        end
      end
  end
end
