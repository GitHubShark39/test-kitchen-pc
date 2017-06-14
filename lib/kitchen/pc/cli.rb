require "kitchen"
require "kitchen/cli"
require "kitchen/config"
require "kitchen/loader/yaml"
require "tempfile"
require "yaml"

module Kitchen
  module PC
    class CLI < Kitchen::CLI
      # Intercept the CLI call and merge project and parent configs
      # before firing off the proper CLI intialization
      def initialize(*args)
        # Read the configs as provided
        loader = Kitchen::Loader::YAML.new(
          project_config: ENV["KITCHEN_YAML"],
          local_config: ENV["KITCHEN_LOCAL_YAML"],
          global_config: ENV["KITCHEN_GLOBAL_YAML"]
        )
        # For any configs that have parents, merge in the parents
        # and write out to a temporary file, then set the associated
        # environment variable for Test Kitchen to use that file
        tmp_files = []
        configs = [
          { :path_fn => :config_file, :yaml_fn => :yaml, :env_var => 'KITCHEN_YAML' },
          { :path_fn => :local_config_file, :yaml_fn => :local_yaml, :env_var => 'KITCHEN_LOCAL_YAML' },
          { :path_fn => :global_config_file, :yaml_fn => :global_yaml, :env_var => 'KITCHEN_GLOBAL_YAML' },
        ].each do |params|
          config_path = loader.send params[:path_fn]
          config = loader.send params[:yaml_fn]
          if config.key?('parent')
            merged_file = self.class.merge_parent(config)
            ENV[params[:env_var]] = merged_file
            tmp_files.push(merged_file)
          else
            ENV[params[:env_var]] = config_path
          end
        end

        # Cleanup the temp config files on exit
        at_exit do
          begin
            File.unlink(*tmp_files)
          rescue
            # ignore cleanup errors
          end
        end

        # Finally delegate to super
        super
      end

      def self.merge_parent(config)
        # If the config doesn't have a parent, except
        if !config.key?('parent')
          raise "Bad Programmer! merge_parent called on a config without a parent: #{config.to_s}"
        end
        # Create a temp file to write the merged config
        file = Tempfile.new(['test-kitchen-config', '.yml'])
        begin
          parent = parse_config(File.expand_path(config['parent']))
          merged = merge_configs(parent, config)
          merged.delete('parent')
          file.write merged.to_yaml
        rescue
          file.unlink # Only unlink here if an error occurred,
                      #  otherwise we'll leave that up to the caller
                      #  to unlink eonce finished processing the file
          raise       # Re-raise the original exception
        ensure
          file.close
        end
        return file.path
      end

      def self.parse_config(config_path)
        str = Kitchen::Loader::YAML.new.send(:yaml_string, config_path)
        Kitchen::Loader::YAML.new.send(:parse_yaml_string, str, config_path)
      end

      def self.merge_configs(parent, child)
        normalize(parent).rmerge(normalize(child))
      end

      def self.normalize(obj)
        Kitchen::Loader::YAML.new.send(:normalize, obj)
      end
    end
  end
end
