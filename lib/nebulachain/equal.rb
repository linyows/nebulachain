module Nebulachain
  module Equal
    extend ActiveSupport::Concern

    included do |base|
      base.belongs_to :equalable, polymorphic: true, class_name: 'Relationship'
    end

    def equals
      return self.equalable if self.equalable.blank?
      self.equalable.send(:"#{self.equalable.equal_type.to_s.pluralize}").excludes(_id: self.id)
    end

    def equalize(model, owner = nil)
      self.unequalize if self.equals.present?
      if model.equalable.present?
        self.equalable = model.equalable
      else
        data = { equal_type: :"#{self.class.name.downcase}" }
        unless owner.nil?
          data.merge!({
            equal_owner_id: "#{owner.id}",
            equal_owner_type: "#{owner.class.name}"
          })
        end
        self.equalable = model.create_equalable(data)
        model.save
      end
      self.save
    end

    def unequalize
      return nil if self.equals.blank?
      if self.equals.count <= 2
        self.equalable.delete
      else
        self.update_attributes(
          equalable_type: nil,
          equalable_field: nil,
          equalable_id: nil
        )
      end
    end
  end
end
