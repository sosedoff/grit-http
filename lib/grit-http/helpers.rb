module GritHttp
  module Helpers
    include GritHttp::Errors
    
    # Returns true if API keys are required for each request
    def api_key_required?
      GritHttp.config[:protection] == true
    end
    
    # Check API request parameters
    def check_api_request
      halt 400, error_response(ERROR_INVALID_REQUEST_METHOD) unless request.get?
    end
    
    # Check API authentication for each request
    def check_api_auth
      if api_key_required?
        @api_key = params['api_key'].to_s.strip
        halt 400, error_response(ERROR_API_KEY_REQUIRED) if @api_key.empty?
        halt 403, error_response(ERROR_API_KEY_INVALID) unless GritHttp.valid_api_key?(@api_key)
      end
    end
    
    # Find and load REPOSITORY information
    def load_repository
      @repo_id = params['repo'].to_s.strip
      
      halt 400, error_response(ERROR_REPO_REQUIRED) if @repo_id.empty?
      halt 404, error_response(ERROR_REPO_NOT_FOUND) unless GritHttp.repository_exists?(@repo_id)
      
      @repo = GritHttp.repository(@repo_id)
      @head = params['head'] || 'master'
      @path = params['path'] || ''
      @path = nil if @path.empty? # Ruby 1.9.2 fix
    end
  
    # Find and load COMMIT information
    def load_commit
      id = params['id'].to_s
      halt 400, error_response(ERROR_COMMIT_REQUIRED) if id.empty?
      
      @commit = @repo.commit(id)
      halt 404, error_response(ERROR_COMMIT_NOT_FOUND) if @commit.nil?
    end
    
    # Find and load TREE information
    def load_tree
      @commit = @repo.commit(@head)
      halt 404, error_response(ERROR_INVALID_REF) if @commit.nil?
      
      begin
        @tree = @repo.tree(@commit.tree.id, @path)
      rescue Grit::GitRuby::Repository::NoSuchPath
        halt 404, error_response(ERROR_INVALID_PATH)
      end
    end
    
    # Find and load BLOB information
    def load_blob
      halt 400, error_response(ERROR_BLOB_REQUIRED) if @path.to_s.empty?
      @blob = @tree.contents.first
      halt 404, error_response(ERROR_BLOB_NOT_FOUND) if @blob.nil?
      halt 404, error_response(ERROR_BLOB_NOT_FOUND) if !@blob.kind_of?(Grit::Blob)
    end
    
    # Returns an object type name based on class
    def object_type(klass)
      case klass
        when Grit::Blob then 'blob'
        when Grit::Tree then 'tree'
        else 'unknown'
      end
    end
    
    # Generate an error response
    def error_response(code, message=nil)
      Yajl::Encoder.encode({
        :result => false,
        :error => {
          :code => code,
          :message => message || ERROR_MESSAGES[code]
        }
      })
    end
  
    # Generate a successful response
    def success_response(data=nil)
      Yajl::Encoder.encode({:result => true, :data => data.nil? ? {} : data})
    end
  end
end