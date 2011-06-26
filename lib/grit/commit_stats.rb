module Grit
  class CommitStats
    def to_hash
      {
        :id        => self.id,
        :additions => self.additions,
        :deletions => self.deletions,
        :total     => self.total,
        :files     => self.files
      }
    end
  end
end