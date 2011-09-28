module PgxnUtils
  class CLI < Thor
    attr_accessor :extension_name, :target, :maintainer #, :maintainer_mail
    attr_accessor :abstract, :description, :version, :tags
    attr_accessor :license, :release_status, :generated_by
    attr_accessor :pgxn_username, :pgxn_password

    include Thor::Actions
    include PgxnUtils::NoTasks
	include Grit

    desc "skeleton extension_name", "Creates an extension skeleton in current directory"

    method_option :target,            :aliases => "-p", :default => ".",  :desc => "Define the target directory"

    # META required fields
    method_option :maintainer,        :aliases => "-m", :type => :string, :desc => "Maintainer's name <maintainer@email>"
    method_option :abstract,          :aliases => "-a", :type => :string, :desc => "Defines a short description to abstract"
    method_option :license,           :aliases => "-l", :type => :string, :desc => "The extension license"
    method_option :version,           :aliases => "-v", :type => :string, :desc => "Initial version"

    # META optional fields
    method_option :description,       :aliases => "-d", :type => :string, :desc => "A long text that contains more information about extension"
    method_option :generated_by,      :aliases => "-b", :type => :string, :desc => "Name of extension's generator"
    method_option :tags,              :aliases => "-t", :type => :array,  :desc => "Defines extension's tags"
    method_option :release_status,    :aliases => "-r", :type => :string, :desc => "Initial extension's release status"
	method_option :git,				  :type => :boolean, :default => false, :desc => "Initialize a git repository after create the extension"

    def skeleton(extension_name,target=nil)
      self.target = options[:target] || target || "."

      if is_extension?("#{self.target}/#{extension_name}")
        say "'#{extension_name}' already exists. Please, use 'change' instead 'skeleton'.", :red
      elsif is_extension?(".")
        say "You are inside a extension directory, already. Consider use 'change' instead.", :red
      elsif is_dir?("#{self.target}/#{extension_name}")
        say "Can't create an extension overwriting an existing directory.", :red
      else
        self.set_accessors extension_name
        directory "root", extension_name

		Repo.init("#{self.target}/#{extension_name}") if options[:git]
      end
    end

    desc "change [extension_name]", "Changes META's attributes in current extension"

    method_option :target,            :aliases => "-p", :type => :string, :default => ".", :desc => "Define the target directory"

    # META required fields
    method_option :maintainer,        :aliases => "-m", :type => :string, :desc => "Maintainer's name <maintainer@email>"
    method_option :abstract,          :aliases => "-a", :type => :string, :desc => "Defines a short description to abstract"
    method_option :license,           :aliases => "-l", :type => :string, :desc => "The extension license."
    method_option :version,           :aliases => "-v", :type => :string, :desc => "Initial version"

    # META optional fields
    method_option :description,       :aliases => "-d", :type => :string, :desc => "A long text that contains more information about extension"
    method_option :generated_by,      :aliases => "-b", :type => :string, :desc => "Name of extension's generator"
    method_option :tags,              :aliases => "-t", :type => :array,  :desc => "Defines extension's tags"
    method_option :release_status,    :aliases => "-r", :type => :string, :desc => "Initial extension's release status"

    def change(extension_name=".")
      extension_path, extension_name = resolve_extension_path_and_name(extension_name)

      self.target = extension_path
      self.extension_name = extension_name

      set_accessors(extension_name)

      if is_extension?(extension_path)
        template "root/META.json.tt", "#{extension_path}/META.json"
        template "root/%extension_name%.control.tt", "#{extension_path}/%extension_name%.control"
      else
        say "'#{extension_name}' doesn't appears to be an extension. Please, supply the extension's name", :red
      end
    end

    desc "bundle [extension_name]", "Bundles the extension in a zip file"

    def bundle(extension_name=".")
      unless is_extension?(extension_name)
        say "'#{extension_name}' doesn't appears to be an extension. Please, supply the extension's name", :red
      else
        path = File.expand_path(extension_name)
        extension_name = File.basename(path)

        self.target = path
        archive_name = "#{path}-#{config_options['version']}"
        ext = "zip"
        archive = "#{archive_name}.#{ext}"

        if can_zip?(archive)
          make_dist_clean(path)

          Zippy.create(archive) do |zip|
            Dir["#{path}/**/**"].each do |file|
              zip["#{extension_name}-#{config_options['version']}/#{file.sub(path+'/','')}"] = File.open(file) unless File.directory?(file)
            end
          end
          say_status :create, archive, :green
        end
      end
    end

    desc "release filename", "Release an extension to PGXN"

    def release(filename)
      send_file_to_pgxn(filename)
    end

    def self.source_root
      @_source_root ||= File.expand_path('../templates', __FILE__)
    end
  end
end
