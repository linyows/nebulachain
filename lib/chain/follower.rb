module Chain
  module Follower
    extend ActiveSupport::Concern

    included do |base|
      base.field    :followees_count, type: Integer, default: 0
      base.has_many :followees, class_name: 'Relationship', as: :followee, dependent: :destroy
    end

    def toggle_follow(model)
      return false if self.id == model.id
      # unfollow
      if self.following?(model)
        self.unfollow!(model)
      # follow
      else
        if defined?(::Chain::Blockee) && self.is_a?(::Chain::Blockee)
          return false if self.blocked_by?(model)
        end
        self.follow!(model)
      end
    end

    def follow(model)
      if self.id != model.id && !self.following?(model)
        if defined?(::Chain::Blockee) && self.is_a?(::Chain::Blockee)
          return false if self.blocked_by?(model)
        end
        self.follow!(model)
      else
        false
      end
    end

    def follow!(model)
      self.before_follow(model) if self.respond_to?('before_follow')
      self.followees.create!(follower_type: model.class.name, follower_id: model.id)
      self.inc(:followees_count, 1)
      model.inc(:followers_count, 1)
      self.after_follow(model) if self.respond_to?('after_follow')
      true
    end

    def unfollow(model)
      if self.id != model.id && self.following?(model)
        self.unfollow!(model)
      else
        false
      end
    end

    def unfollow!(model)
      self.before_unfollow(model) if self.respond_to?('before_unfollow')
      self.followees.where(follower_type: model.class.name, follower_id: model.id).destroy
      self.inc(:followees_count, -1)
      model.inc(:followers_count, -1)
      self.after_unfollow(model) if self.respond_to?('after_unfollow')
      true
    end

    def following?(model)
      0 < self.followees.where(followee_type: model.class.name, followee_id: model.id).count
    end
  end
end
