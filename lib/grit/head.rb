module Grit
  class Head
    def to_hash
      {:name => self.name, :commit => self.commit.id}
    end
  end
end