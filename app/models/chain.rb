class Chain
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :followee,     polymorphic: true
  belongs_to :follower,     polymorphic: true

  belongs_to :blockee,      polymorphic: true
  belongs_to :blocker,      polymorphic: true

  belongs_to :got_like,     polymorphic: true
  belongs_to :gave_like,    polymorphic: true

  belongs_to :got_dislike,  polymorphic: true
  belongs_to :gave_dislike, polymorphic: true
end
