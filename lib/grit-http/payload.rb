module GritHttp
  class Payload
    # Initialize a payload instance
    #   repo => Grit::Repo instance
    #   head => current ref (branch or tag)
    def initialize(repo, head)
      @repo = repo
      @head = head
    end
    
    # Generate JSON payload for commits diff
    #   before => old revision SHA1
    #   after  => new revision SHA1
    def for_commits(before, after)
      commits = @repo.commits_between(before, after)
      diff = @repo.diff(before, after)
      
      {
        :before     => before,
        :after      => after,
        :ref        => @head,
        :commits    => commits.map(&:to_payload_hash),
        :repository => 'REPO_NAME'
      }
    end
  end
end