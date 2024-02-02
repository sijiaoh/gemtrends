task :rename_project, [ :name ] => :environment do |_, args|
  ignore_files = [ "rename_project.rake", "README.md" ]

  current_name = Rails.application.class.module_parent_name
  new_name = args[:name]

  replace = proc do |prev_str, new_str|
    paths = `git grep --files-with-matches #{prev_str}`.split "\n"
    paths.each do |path|
      next if ignore_files.include? File.basename(path)

      file = File.read path
      file.gsub! prev_str, new_str

      File.write path, file
    end
  end

  replace.call current_name.camelize, new_name.camelize
  replace.call current_name.underscore, new_name.underscore
  replace.call current_name.underscore.upcase, new_name.underscore.upcase
end
