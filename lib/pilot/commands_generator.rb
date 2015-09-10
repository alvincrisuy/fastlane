# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/AbcSize
require "commander"
require "pilot/options"
require "fastlane_core"

HighLine.track_eof = false

module Pilot
  class CommandsGenerator
    include Commander::Methods

    FastlaneCore::CommanderGenerator.new.generate(Pilot::Options.available_options)

    def self.start
      FastlaneCore::UpdateChecker.start_looking_for_update("pilot")
      new.run
    ensure
      FastlaneCore::UpdateChecker.show_update_status("pilot", Pilot::VERSION)
    end

    def convert_options(options)
      o = options.__hash__.dup
      o.delete(:verbose)
      o
    end

    def handle_email(config, args)
      config[:email] ||= args.first
      config[:email] ||= ask("Email address of the tester: ".yellow)
    end

    def run
      program :version, Pilot::VERSION
      program :description, Pilot::DESCRIPTION
      program :help, "Author", "Felix Krause <pilot@krausefx.com>"
      program :help, "Website", "https://fastlane.tools"
      program :help, "GitHub", "https://github.com/fastlane/pilot"
      program :help_formatter, :compact

      global_option("--verbose") { $verbose = true }

      command :upload do |c|
        c.syntax = "pilot upload"
        c.description = "Uploads a new binary to Apple TestFlight"
        c.action do |args, options|
          config = FastlaneCore::Configuration.create(Pilot::Options.available_options, convert_options(options))
          Pilot::BuildManager.new.upload(config)
        end
      end

      command :builds do |c|
        c.syntax = "pilot builds"
        c.description = "Lists all builds for given application"
        c.action do |args, options|
          config = FastlaneCore::Configuration.create(Pilot::Options.available_options, convert_options(options))
          Pilot::BuildManager.new.list(config)
        end
      end

      command :add do |c|
        c.syntax = "pilot add"
        c.description = "Adds a new external tester to a specific app (if given). This will also add an existing tester to an app."
        c.action do |args, options|
          config = FastlaneCore::Configuration.create(Pilot::Options.available_options, convert_options(options))
          handle_email(config, args)
          Pilot::TesterManager.new.add_tester(config)
        end
      end

      command :list do |c|
        c.syntax = "pilot list"
        c.description = "Lists all registered testers, both internal and external"
        c.action do |args, options|
          config = FastlaneCore::Configuration.create(Pilot::Options.available_options, convert_options(options))
          Pilot::TesterManager.new.list_testers(config)
        end
      end

      command :find do |c|
        c.syntax = "pilot find"
        c.description = "Find a tester (internal or external) by their email address"
        c.action do |args, options|
          config = FastlaneCore::Configuration.create(Pilot::Options.available_options, convert_options(options))
          handle_email(config, args)
          Pilot::TesterManager.new.find_tester(config)
        end
      end

      command :remove do |c|
        c.syntax = "pilot remove"
        c.description = "Remove an external tester by their email address"
        c.action do |args, options|
          config = FastlaneCore::Configuration.create(Pilot::Options.available_options, convert_options(options))
          handle_email(config, args)
          Pilot::TesterManager.new.remove_tester(config)
        end
      end

      command :export do |c|
        c.syntax = "pilot export"
        c.description = "Exports all external testers to a CSV file"
        c.action do |args, options|
          config = FastlaneCore::Configuration.create(Pilot::Options.available_options, convert_options(options))
          Pilot::TesterExporter.new.export_testers(config)
        end
      end

      command :import do |c|
        c.syntax = "pilot import"
        c.description = "Create external testers from a CSV file"
        c.action do |args, options|
          config = FastlaneCore::Configuration.create(Pilot::Options.available_options, convert_options(options))
          Pilot::TesterImporter.new.import_testers(config)
        end
      end

      default_command :help

      run!
    end
  end
end
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize
