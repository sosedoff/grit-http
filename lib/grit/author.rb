module Grit
  class Actor
    alias :as_json :to_json
    
    def to_json(opts={})
      self.to_hash.to_json
    end
    
    def to_hash
      {
        :name => self.name,
        :email => self.email,
        :gravatar => Digest::MD5.hexdigest(self.email)
      }
    end
  end
end
