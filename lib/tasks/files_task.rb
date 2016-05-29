require 'rake'
require 'fileutils'

module Athena
  module Tasks
    class FilesTask
      include Rake::DSL if defined? Rake::DSL

      def install_tasks
        path = File.expand_path('../', File.dirname(__FILE__))
        namespace :athena_files do
          desc "delete temp images at every day"
          task :delete_temp_images do
            FileUtils.rm_rf(ENV['TEMP_IMAGES_FOLDER']) if Dir.exists?(ENV['TEMP_IMAGES_FOLDER'])
          end
        end
      end
    end
  end
end