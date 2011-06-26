module Grit
  class Tag
    def to_hash
      {:name => self.name, :commit => self.commit.id}
    end
  end
end