module Chain
  module Followee
    extend ActiveSupport::Concern

    included do |base|
      base.field    :followees_count, type: Integer, default: 0
      base.has_many :followers, class_name: 'Relationship', as: :follower, dependent: :destroy
    end

    def followed_by?(model)
      0 < self.followers.where(followee_type: model.class.name, followee_id: model.id).count
    end

    # followers
    def followed_by(model_name = nil, methods = {})
      methods = model_name and model_name = nil if model_name.is_a?(Hash)
      criteria = methods.present? ?
        self.followers.eval(methods.to_s_of_method_chaining) : self.followers

      if model_name.nil?
        criteria.collect do |doc|
          doc.followee_type.constantize.find(doc.followee_id)
        end
      else
        ids = criteria.where(followee_type: model_name).map { |d| d.followee_id }
        model_name.constantize.any_in(_id: ids)
      end
    end

    private

    def method_missing(missing_method, *args, &block)
      if missing_method.to_s =~ /^followed_by_(.+)$/
        followed_by($1.singularize.titleize, args[0])
      else
        super
      end
    end
  end
end
