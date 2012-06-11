module Chain
  module Followee
    extend ActiveSupport::Concern

    included do |base|
      base.field    :followees_count, type: Integer, default: 0
      base.has_many :followees, class_name: 'Relationship', as: :followee, dependent: :destroy
    end

    def toggle_follow(model)
      return false if self.id == model.id
      # unfollow
      if self.followees?(model)
        self.unfollow!(model)
      # follow
      else
        return false if self.blocker?(model)
        self.follow!(model)
      end
    end

    def follow(model)
      if self.id != model.id && !self.followees?(model)
        return false if self.blocker?(model)
        self.follow!(model)
      else
        false
      end
    end

    def follow!(model)
      model.before_followed_by(self) if model.respond_to?('before_followed_by')
      model.followers.create!(target_type: self.class.name, target_id: self.id)
      model.inc(:followers_count, 1)
      model.after_followed_by(self) if model.respond_to?('after_followed_by')
      self.before_follow(model) if self.respond_to?('before_follow')
      self.followees.create!(target_type: model.class.name, target_id: model.id)
      self.inc(:followees_count, 1)
      self.after_follow(model) if self.respond_to?('after_follow')
    end

    def unfollow(model)
      if self.id != model.id && self.followees?(model)
        self.unfollow!(model)
      else
        false
      end
    end

    def unfollow!(model)
      model.before_unfollowed_by(self) if model.respond_to?('before_unfollowed_by')
      model.followers.where(target_type: self.class.name, target_id: self.id).destroy
      model.inc(:followers_count, -1)
      model.after_unfollowed_by(self) if model.respond_to?('after_unfollowed_by')
      self.before_unfollow(model) if self.respond_to?('before_unfollow')
      self.followees.where(target_type: model.class.name, target_id: model.id).destroy
      self.inc(:followees_count, -1)
      self.after_unfollow(model) if self.respond_to?('after_unfollow')
    end

    def followees?(model)
      0 < self.followees.find(:all, conditions: {target_id: model.id}).limit(1).count
    end

    def followees_count_by_model(model)
      self.followees.where(target_type: model.to_s).count
    end

    def all_followees
      get_followees_of(self)
    end

    def all_followees_by_model(model)
      get_followers_of(self, model)
    end

    def common_followees_with(model)
      model_followees = get_followees_of(model)
      self_followees = get_followees_of(self)
      self_followees & model_followees
    end

    private

    def get_followees_of(me, model = nil)
      followees = !model ? me.followees : me.followees.where(target_type: model.to_s)
      followees.collect do |f|
        f.target_type.constantize.find(f.target_id)
      end
    end

    def method_missing(missing_method, *args, &block)
      if missing_method.to_s =~ /^(.+)_followees_count$/
        followees_count_by_model($1.camelize)
      elsif missing_method.to_s =~ /^all_(.+)_followees$/
        all_followees_by_model($1.camelize)
      else
        super
      end
    end
  end
end
