require 'bundler/setup'
require 'sinatra'
require 'yaml'
require 'yajl'
require 'yajl/json_gem'
require 'uuidtools'
require 'grit'
require 'linguist'

$LOAD_PATH << '.' if RUBY_VERSION > '1.9'

require './lib/utils'
require './lib/grit'
require './lib/grit-http'
require './app/environment'
require './app/helpers'

GritHttp.load_config('config/grit-http.yml')
GritHttp.setup

# ------------------------------------------------------------------------------

before do
  content_type :json, :charset => 'utf-8'
  
  check_api_request
  check_api_auth
end

# Returns a current time response
# GET /
# Params: none
get '/' do
  success_response(:time => Time.now)
end

# Returns a pong response
# GET /ping
# Params: none
get '/ping' do
  success_response(:pong => true)
end

# Returns a list of application versions
# GET /versions
# Params: none
get '/versions' do
  resp = {
    :app => GritHttp::VERSION,
    :git => `git --version`.strip.split(' ').last
  }
  success_response(:versions => resp)
end

# Returns a list of all available repositories
# GET /repositories
# Params: none
get '/repositories' do
  success_response(:repositories => GritHttp.repositories)
end

# Returns an informations for the requested repository
# GET /repository
# Params:
#   repo => Repository name (from config file, required)
get '/repository' do
  load_repository
  
  success_response(
    :name => @repo_id,
    :bare => @repo.bare,
    :filesize => @repo.capacity
  )
end

# GET /authors
#   repo => Repository (required)
get '/authors' do
  load_repository
  authors = []
  @repo.authors.each_with_index do |a, i|
    unless a.empty?
      authors << {
        :name     => a.last,
        :commits  => Integer(a.first),
        :position => i+1
      }
    end
  end
  success_response(authors)
end

# GET /tags
#   repo => Repository (required)
get '/tags' do
  load_repository
  success_response(@repo.tags.map(&:to_hash))
end

# GET /heads
#   repo => Repository (required)
get '/heads' do
  load_repository
  success_response(@repo.heads.map(&:to_hash))
end

# GET /refs
#   repo => Repository (required)
get '/refs' do
  load_repository
  success_response(@repo.refs.map(&:to_hash))
end

# GET /commits
#   repo => Repository (required)
#   head => HEAD (optional, default to 'master')
get '/commits' do
  load_repository
  
  max_count = Integer(params['max_count'] || 25).abs || 10
  max_count = 25 if max_count == 0
  skip = Integer(params['skip'] || 0).abs || 0
  
  commits = @repo.log(@head, @path, {:max_count => max_count, :skip => skip})
  success_response(
    :head    => @head,
    :path    => @path,
    :commits => commits.map(&:to_hash)
  )
end

# GET /commits/stats
#   repo => Repository (required)
#   head => HEAD (optional, default to 'master')
get '/commits/stats' do
  load_repository
  
  days = params[:days] || 30
  days = Integer(days) unless days.kind_of?(Fixnum)

  success_response(
    @repo.commits_count_for_days(days)
  )
end

# Fetch total amount of commits for the ref
# GET /commits/count
#   repo => Repository
#   head => HEAD (optional, defaults to 'master')
get '/commits/count' do
  load_repository
  success_response(:count => Grit::Commit.count(@repo, @head))
end

# GET /commit
#   repo => Repository (required)
#   head => HEAD (optional, default to 'master')
#   id   => Commit ID (full or short) (required)
get '/commit' do
  load_repository
  load_commit
    
  resp = {
    :head   => @head,
    :path   => @path,
    :stats  => @commit.stats.to_hash,
    :diffs  => @commit.diffs.map(&:to_hash),
    :commit => @commit.to_hash
  }
    
  success_response(resp)    
end

# GET /commit/diff
#   repo => Repository (required)
#   head => HEAD (optional, default to 'master')
#   id   => Commit ID (full or short) (required)
get '/commit/diff' do
  load_repository
  load_commit
  
  resp = {
    :head => @head,
    :diff => @commit.diffs.map(&:to_hash)
  }
  
  success_response(resp)
end

# GET /compare
#   repo => Repository (required)
#   head => HEAD (optional, default to 'master')
#   from => Base object for compartion
#   to   => Target object for compartion
get '/compare' do
  load_repository
  
  obj_from = params['obj_from']
  obj_to = params['obj_to']
    
  halt 400, error_response(ERROR_OBJECT_BASE_REQUIRED) if obj_from.nil?
  halt 400, error_response(ERROR_OBJECT_TARGET_REQUIRED) if obj_to.nil?
    
  commits = @repo.commits_between(obj_from, obj_to)
  diff = @repo.diff(obj_from, obj_to)
    
  success_response(
    :commits => commits.map { |c| @repo.commit(c.id).to_hash },
    :diff    => diff.map(&:to_hash)
  )
end

# GET /payload
#   repo   => Repository (required)
#   head   => HEAD (optional, default to 'master')
#   before => Before SHA
#   after  => After SHA1
get '/payload' do
  load_repository
  
  sha_before = params[:before].to_s
  sha_after = params[:after].to_s
  
  halt 400, error_response(ERROR_OBJECT_BASE_REQUIRED) if sha_before.empty?
  halt 400, error_response(ERROR_OBJECT_TARGET_REQUIRED) if sha_after.empty?
  
  payload = GritHttp::Payload.new(@repo, @head)
  success_response(payload.for_commits(sha_before, sha_after))
end

# Get a payload for the single commit
# GET /commit/payload
#   repo => Repository (required)
#   head => HEAD (optional, defaults to 'master')
#   id   => Commit SHA
get '/commit/payload' do
  load_repository
  load_commit
  
  success_response(
    :repository => @repo_id,
    :head       => @head,
    :commits    => @commit.to_payload_hash
  )
end

# GET /tree
#   repo    => Repository (required)
#   head    => HEAD (optional)
#   path    => Tree path (optional, default to root)
#   history => Include object history (default no 0)
get '/tree' do
  load_repository
  load_tree
  
  include_history = params['history'] || false
  
  items = (@tree.trees + @tree.blobs).map do |obj|
    {
      :id       => obj.id,
      :type     => object_type(obj),
      :name     => obj.name,
      :mode     => obj.mode,
      :filesize => obj.kind_of?(Grit::Tree) ? nil : obj.size,
      :commit   => include_history ? @repo.log(@head, "#{obj.name}", {:max_count => 1}).first.to_hash : {}
    }
  end
  
  success_response(
    :head     => @head,
    :path     => @path,
    :commit   => @commit.to_hash,
    :tree     => items
  )
end

# GET /tree/history
#   repo => Repository(required)
#   head => HEAD (optional)
#   path => Tree path(optional, default to root)
get '/tree/history' do
  load_repository
  load_tree
  
  items = {}
  (@tree.trees + @tree.blobs).map do |obj|
    items[obj.id] = @repo.log(@head, "#{obj.name}", {:max_count => 1}).first.to_hash
  end
  success_response(items)
end

# GET /blob
#   repo => Repository (required)
#   head => HEAD (optional, default to 'master')
#   path => Blob path (required)
get '/blob' do
  load_repository
  load_tree
  load_blob
    
  success_response(
    :head   => @head,
    :commit => @commit.to_hash,
    :path   => @path,
    :blob   => @blob.to_hash
  )
end

# GET /raw - Returns RAW blob content
#   repo => Repository (required)
#   head => HEAD (optional, default to 'master')
#   path => Blob path (required)
get '/raw' do
  load_repository
  load_tree
  load_blob
  
  # content_type(@blob.mime_type)
  content_type('text/plain')
  last_modified(@commit.committed_date)
  headers \
    'Content-Disposition' => 'inline'
  
  @blob.data
end

# GET /blame - Returns blob blame 
#   repo => Repository (required)
#   head => HEAD (optional, default to 'master')
#   path => Blob path (required)
get '/blame' do
  load_repository
  load_tree
  load_blob

  blame = []
  Grit::Blob.blame(@repo, @head, @path).each_with_index do |row, i|
    blame << {
      :commit => row.shift.to_hash,
      :lines => row
    }
  end
  
  success_response(
    :head  => @head,
    :path  => @path,
    :blob  => @blob.to_hash,
    :blame => blame
  )
end