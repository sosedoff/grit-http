module Grit
  class Diff
    def to_hash
      {
        :a_path       => self.a_path,
        :b_path       => self.b_path,
        :deleted_file => self.deleted_file,
        :new_file     => self.new_file,
        :content      => self.diff
      }
    end
  end
end