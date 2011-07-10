module Grit
  class Blob
    def to_hash
      {
        :id        => self.id,
        :name      => self.basename,
        :mime_type => self.mime_type,
        :mode      => self.mode,
        :filesize  => self.size,
        :binary    => self.is_binary?,
        :data      => self.is_binary? ? nil : self.data
      }
    end
    
    # Returns true if blob has a binary mime type
    def is_binary?
      Linguist::FileBlob.new(self.basename).binary?
    end
  end
end