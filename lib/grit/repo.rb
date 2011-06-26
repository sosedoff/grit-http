module Grit
  class Repo
    def authors
      list = git.shortlog({}, '--all', '-n', '-s').split("\n").map { |s| s.strip }
      list.map { |s| s.scan(/^([\d]{1,})\s+(.*)/).flatten }
    end
    
    def commits_count_for_days(n=14)
      dt_end = Date.today ; dt_start = dt_end - n
      days = {} 
      (dt_start..dt_end).to_a.map { |d| days[d.strftime("%Y-%m-%d")] = 0 }
      git.log({}, '--all', "--since='#{dt_start.strftime("%Y-%m-%d")}'", '--format="%cD"').split("\n").each do |c|
        dt = Time.parse(c).strftime("%Y-%m-%d")
        days[dt] += 1
      end
      days    
    end
    
    # Returns repository size in bytes
    def capacity
      Integer(`du -sk #{self.path}`.strip.split(' ').first) * 1024
    end
  end
end