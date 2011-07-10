module Grit
  class Diff
    def to_hash
      path = self.a_path || self.b_path
      
      {
        :a_path       => self.a_path,
        :b_path       => self.b_path,
        :deleted_file => self.deleted_file,
        :new_file     => self.new_file,
        :content      => Linguist::FileBlob.new(path).binary? ? '' : self.diff
      }
    end
  end
end