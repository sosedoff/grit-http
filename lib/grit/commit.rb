module Grit
  class Commit
    def to_hash
      {
        'id'       => id,
        'parents'  => parents.map { |p| { 'id' => p.id } },
        'tree'     => tree.id,
        'message'  => message,
        'author'   => author.to_hash,
        'committer' => committer.to_hash,
        'authored_date'  => authored_date.xmlschema,
        'committed_date' => committed_date.xmlschema,
      }
    end
    
    def to_payload_hash
      diffs = self.diffs
      files = self.stats.files || []
      
      added_paths = []
      removed_paths = []
      modified_paths = []
      
      diffs.each do |diff|
        if diff.new_file
          added_paths << diff.a_path
        elsif diff.deleted_file
          removed_paths << diff.a_path
        else
          modified_paths << diff.a_path
        end
      end
      
      {
        :id        => self.id,
        :message   => self.message,
        :timestamp => self.committed_date.xmlschema,
        :author    => self.author.to_hash,
        :added     => added_paths,
        :removed   => removed_paths,
        :modified  => modified_paths
      }
    end
  end
end
