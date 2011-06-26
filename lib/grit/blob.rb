module Grit
  class Blob
    MIME_BINARY = [
      /^image/i,
      /^application\/x-/i,
      /^stream/i,
      /^application\/(zip|gzip)/
    ]
    
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
      return @is_binary unless @is_binary.nil?
      result = false
      MIME_BINARY.each { |r| result = self.mime_type =~ r ; break if result }
      @is_binary = result
      result
    end
  end
end