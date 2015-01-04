require "utils"

def version_euristic urls, regex=nil
  urls.each do |url|
    puts "Trying with url #{url}" if ARGV.debug?
    versions = case
    when DownloadStrategyDetector.detect(url) == GitDownloadStrategy
      puts "Possible git repo detected at #{url}" if ARGV.debug?

      git_tags(url, regex).map do |tag|
        begin
          Version.detect(url, {:tag => tag})
        rescue TypeError
          nil
        end
      end.compact
    when url =~ /(sourceforge\.net|sf\.net)\//
      project_name = url.match(/\/projects?\/(.*?)\//)[1]
      page_url = "http://sourceforge.net/api/file/index/project-name/#{project_name}/rss"

      puts "Possible SourceForge project [#{project_name}] detected at #{url}" if ARGV.debug?

      if regex.nil?
        regex = /\/#{project_name}\/([a-zA-Z0-9.]+(?:\.[a-zA-Z0-9.]+)*)/
      end

      page_matches(page_url, regex).map { |v| Version.new(v) }
    when url =~ /gnu\.org/
      project_name_regexps = [
        /\/(?:software|gnu)\/(.*?)\//,
        /\/\/(.*?)\.gnu\.org(?:\/)?$/
      ]
      match_list = project_name_regexps.map do |regex|
        url.match(regex)
      end.compact

      if match_list.length > 1
        puts "Multiple project names found: #{match_list}"
      end

      if match_list.empty?
        []
      else
        project_name = match_list[0][1]
        page_url = "http://ftp.gnu.org/gnu/#{project_name}/?C=M&O=D"

        puts "Possible GNU project [#{project_name}] detected at #{url}" if ARGV.debug?

        if regex.nil?
          regex = /#{project_name}-(\d+(?:\.\d+)*)/
        end

        page_matches(page_url, regex).map { |v| Version.new(v) }
      end
    when regex
      # Failback
      page_matches(url, regex).map { |v| Version.new(v) }
    else
      []
    end
    
    return versions.max unless versions.empty?
  end

  raise TypeError, "Unable to get versions for #{Tty.blue}#{name}#{Tty.reset}"
end