module Chain
  module Follower
    extend ActiveSupport::Concern

    included do |base|
      base.field    :followers_count, type: Integer, default: 0
      base.has_many :followers, class_name: 'Relationship', as: :follower, dependent: :destroy
    end

    def follower?(model)
      0 < self.followers.find(:all, conditions: {target_id: model.id}).limit(1).count
    end

    def all_followers
      get_followers_of(self)
    end

    def all_followers_by_model(model)
      get_followers_of(self, model)
    end

    def common_followers_with(model)
      model_followers = get_followers_of(model)
      self_followers = get_followers_of(self)
      self_followers & model_followers
    end

    private

    def get_followers_of(me, model = nil)
      followers = !model ? me.followers : me.followers.where(target_type: model.to_s)
      followers.collect do |f|
        f.target_type.constantize.find(f.target_id)
      end
    end

    def method_missing(missing_method, *args, &block)
      if missing_method.to_s =~ /^(.+)_followers_count$/
        followers_count_by_model($1.camelize)
      elsif missing_method.to_s =~ /^all_(.+)_followers$/
        all_followers_by_model($1.camelize)
      else
        super
      end
    end
  end
end
