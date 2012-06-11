module Chain
  module GaveDislike
    extend ActiveSupport::Concern

    included do |base|
      base.field    :gave_dislikes_count, type: Integer, default: 0
      base.has_many :gave_dislikes, class_name: 'Relationship', as: :gave_dislike, dependent: :destroy
    end

    def toggle_dislike(model)
      # undislike
      if self.gave_dislikes?(model)
        self.undislike!(model)
      # dislike
      else
        self.unlike(model)
        self.dislike!(model)
      end
    end

    def dislike(model)
      if !self.gave_dislikes?(model)
        self.unlikes(model)
        self.dislike!(model)
      else
        false
      end
    end

    def dislike!(model)
      model.before_disliked_by(self) if model.respond_to?('before_disliked_by')
      model.got_dislikes.create!(target_type: self.class.name, target_id: self.id)
      model.inc(:got_dislikes_count, 1)
      model.after_disliked_by(self) if model.respond_to?('after_disliked_by')
      self.before_dislike(model) if self.respond_to?('before_dislike')
      self.gave_dislikes.create!(target_type: model.class.name, target_id: model.id)
      self.inc(:gave_dislikes_count, 1)
      self.after_dislike(model) if self.respond_to?('after_dislike')
    end

    def undislike(model)
      if self.gave_dislikes?(model)
        self.undislike!(model)
      else
        false
      end
    end

    def undislike!(model)
      model.before_undisliked_by(self) if model.respond_to?('before_undisliked_by')
      model.got_dislikes.where(target_type: self.class.name, target_id: self.id).destroy
      model.inc(:got_dislikes_count, -1)
      model.after_undisliked_by(self) if model.respond_to?('after_undisliked_by')
      self.before_undislike(model) if self.respond_to?('before_undislike')
      self.gave_dislikes.where(target_type: model.class.name, target_id: model.id).destroy
      self.inc(:gave_dislikes_count, -1)
      self.after_undislike(model) if self.respond_to?('after_undislike')
    end

    def gave_dislikes?(model)
      0 < self.gave_dislikes.find(:all, conditions: {target_id: model.id}).limit(1).count
    end

    def all_gave_dislikes
      get_gave_dislikes_of(self)
    end

    def common_gave_dislikes_with(model)
      model_gave_dislikes = get_gave_dislikes_of(model)
      self_gave_dislikes = get_gave_dislikes_of(self)
      self_gave_dislikes & model_gave_dislikes
    end

    private

      def get_gave_dislikes_of(model)
        model.gave_dislikes.collect do |f|
          f.target_type.constantize.find(f.target_id)
        end
      end
  end
end
