module PgxnUtils
  class CLI < Thor
    attr_accessor :extension_name, :target, :maintainer, :maintainer_mail
    attr_accessor :abstract, :description, :tags

    include Thor::Actions

    desc "skeleton extension_name", "Creates an extension skeleton in current directory."

    method_option :target,            :aliases => "-p", :default => "."

    # META required fields
    method_option :maintainer,        :aliases => "-m", :type => :string,   :default => "The maintainer's name"
    method_option :maintainer_mail,   :aliases => "-e", :type => :string,   :default => "maintainer@email.here"
    method_option :abstract,          :aliases => "-a", :type => :string,   :default => "A short description"
    method_option :license,           :aliases => "-l", :type => :string,   :default => "postgresql"
    method_option :version,           :aliases => "-v", :type => :string,   :default => "0.0.1"

    # META optional fields
    method_option :description,       :aliases => "-d", :type => :string,  :default => "A long description"
    method_option :generated_by,      :aliases => "-b", :type => :string,  :default => "Generator's name"
    method_option :tags,              :aliases => "-t", :type => :array
    method_option :release_status,    :aliases => "-r", :type => :string,  :default => "unstable"

    def skeleton(extension_name)
      self.set_accessors extension_name

      directory "root", extension_name
    end

    no_tasks do
      def set_accessors(extension_name="your_extension_name")
        self.extension_name = extension_name

        self.target = options[:target]
        self.maintainer = options[:maintainer]
        self.maintainer_mail = options[:maintainer_mail]
        self.tags = options[:tags]
        self.abstract = options[:abstract]
        self.description = options[:description]

        self.destination_root = target
      end
    end

    def self.source_root
      @_source_root ||= File.expand_path('../templates', __FILE__)
    end
  end
end
