module Nebulachain
  module GaveDislike
    extend ActiveSupport::Concern

    included do |base|
      base.field    :gave_dislikes_count, type: Integer, default: 0
      base.has_many :got_dislikes, class_name: 'Relationship', as: :got_dislike, dependent: :destroy
    end

    def toggle_dislike(model)
      # undislike
      if self.dislike?(model)
        self.undislike!(model)
      # dislike
      else
        self.unlike(model)
        self.dislike!(model)
      end
    end

    def dislike(model)
      if !self.dislike?(model)
        self.unlikes(model)
        self.dislike!(model)
      else
        false
      end
    end

    def dislike!(model)
      self.before_dislike(model) if self.respond_to?('before_dislike')
      self.got_dislikes.create!(gave_dislike_type: model.class.name, gave_dislike_id: model.id)
      self.inc(:gave_dislikes_count, 1)
      model.inc(:got_dislikes_count, 1)
      self.after_dislike(model) if self.respond_to?('after_dislike')
    end

    def undislike(model)
      if self.dislike?(model)
        self.undislike!(model)
      else
        false
      end
    end

    def undislike!(model)
      self.before_undislike(model) if self.respond_to?('before_undislike')
      self.got_dislikes.where(gave_dislike_type: model.class.name, gave_dislike_id: model.id).destroy
      self.inc(:gave_dislikes_count, -1)
      model.inc(:got_dislikes_count, -1)
      self.after_undislike(model) if self.respond_to?('after_undislike')
    end

    def dislike?(model)
      0 < self.got_dislikes.where(gave_dislike_type: model.class.name, gave_dislike_id: model.id).count
    end

    # dislikes
    def dislikes(model_name = nil, methods = {})
      methods = model_name and model_name = nil if model_name.is_a?(Hash)
      criteria = methods.present? ?
        self.got_dislikes.eval(methods.to_s_of_method_chaining) : self.got_dislikes

      if model_name.nil?
        criteria.collect do |doc|
          doc.gave_dislike_type.constantize.find(doc.gave_dislike_id)
        end
      else
        ids = criteria.where(gave_dislike_type: model_name).map { |d| d.gave_dislike_id }
        model_name.constantize.any_in(_id: ids)
      end
    end

    private

    def method_missing(missing_method, *args, &block)
      if missing_method.to_s =~ /^dislikes_(.+)$/
        dislikes($1.singularize.titleize, args[0])
      else
        super
      end
    end
  end
end
