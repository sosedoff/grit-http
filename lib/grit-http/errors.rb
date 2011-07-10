module GritHttp
  module Errors
    ERROR_API_KEY_REQUIRED        = 1
    ERROR_API_KEY_INVALID         = 2
    ERROR_NOT_IMPLEMENTED         = 3
    ERROR_UNKNOWN_ERROR           = 4
    ERROR_INVALID_REQUEST_METHOD  = 5
    ERROR_INVALID_REQUEST_PATH    = 6
    ERROR_REPO_REQUIRED           = 100
    ERROR_REPO_NOT_FOUND          = 101
    ERROR_REPO_NAME_REQUIRED      = 102
    ERROR_BRANCH_REQUIRED         = 200
    ERROR_BRANCH_NOT_FOUND        = 201
    ERROR_TAG_REQUIRED            = 300
    ERROR_TAG_NOT_FOUND           = 301
    ERROR_COMMIT_REQUIRED         = 400
    ERROR_COMMIT_NOT_FOUND        = 401
    ERROR_BLOB_REQUIRED           = 500
    ERROR_BLOB_NOT_FOUND          = 501
    ERROR_OBJECT_BASE_REQUIRED    = 700
    ERROR_OBJECT_TARGET_REQUIRED  = 701
    ERROR_INVALID_PATH            = 600
    ERROR_INVALID_HEAD            = 601
    ERROR_INVALID_REF             = 90
    ERROR_INVALID_ID              = 91
    
    ERROR_MESSAGES = {
      ERROR_API_KEY_REQUIRED        => "API key required.",
      ERROR_API_KEY_INVALID         => "Invalid API key.",
      ERROR_NOT_IMPLEMENTED         => "Feature is not implemented.",
      ERROR_UNKNOWN_ERROR           => "Unknown error.",
      ERROR_INVALID_REQUEST_METHOD  => "Only GET requests are allowed.",
      ERROR_INVALID_REQUEST_PATH    => "Invalid request path.",
      ERROR_REPO_REQUIRED           => "Repository required!",
      ERROR_REPO_NOT_FOUND          => "Repository was not found!",
      ERROR_REPO_NAME_REQUIRED      => "Repository name required.",
      ERROR_BRANCH_REQUIRED         => "Branch required.",
      ERROR_BRANCH_NOT_FOUND        => "Branch with such ID was not found.",
      ERROR_TAG_REQUIRED            => "Tag required.",
      ERROR_TAG_NOT_FOUND           => "Tag was not found.",
      ERROR_COMMIT_REQUIRED         => "Commit ID required.",
      ERROR_COMMIT_NOT_FOUND        => "Commit was not found.",
      ERROR_BLOB_NOT_FOUND          => "Blob with such ID was not found.",
      ERROR_BLOB_REQUIRED           => "Blob path required.",
      ERROR_OBJECT_BASE_REQUIRED    => "Base object required.",
      ERROR_OBJECT_TARGET_REQUIRED  => "Target object required.",
      ERROR_INVALID_PATH            => "No such path!",
      ERROR_INVALID_HEAD            => "Invalid HEAD reference.",
      ERROR_INVALID_REF             => "Invalid REF.",
      ERROR_INVALID_ID              => "Invalid ID."
    }.freeze
    
    # Returns an error message for the code
    def self.error_message(code)
      ERROR_MESSAGES[code]
    end
  end
end