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
  end
end
