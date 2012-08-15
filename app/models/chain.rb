class Relationship
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

  def self.leader
    map = %Q{
      function() {
        emit(this.follower_id, {
          followers: 1,
          type: this.follower_type
        });
      }
    }

    reduce = %Q{
      function(key, values) {
        var result = {
          followers: 0,
          type: null
        };
        values.forEach(function(value) {
          result.followers += value.followers;
          result.type = value.type;
        });
        return result;
      }
    }

    self.map_reduce(map, reduce).out(inline: true).each_with_object [] do |doc, result|
      next if doc['_id'].nil?
      result << {
        _id: doc['_id'],
        _type: doc['value']['type'],
        followers: doc['value']['followers'].to_i
      }
    end
  end

  def self.popular
    map = %Q{
      function() {
        emit(this.gave_like_id, {
          likes: 1,
          type: this.gave_like_type
        });
      }
    }

    reduce = %Q{
      function(key, values) {
        var result = {
          likes: 0,
          type: null
        };
        values.forEach(function(value) {
          result.likes += value.likes;
          result.type = value.type;
        });
        return result;
      }
    }

    self.map_reduce(map, reduce).out(inline: true).each_with_object [] do |doc, result|
      next if doc['_id'].nil?
      result << {
        _id: doc['_id'],
        _type: doc['value']['type'],
        likes: doc['value']['likes'].to_i
      }
    end
  end
end
