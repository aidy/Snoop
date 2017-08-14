require 'cinchplugin.rb'
require 'cinchthread.rb'
require 'settings.rb'

module Snoop
  class Bot
    ##load the plugins
      def initialize(options)
        config(options)
        threads
        run
      end

      def config(options)
        if options[:config_file] == nil
          puts 'Please suply config file as option'
          exit 1
        end
        Settings.path(options[:config_file])
        plugins = getallplugins
        puts plugins.inspect
        @bot = Cinch::Bot.new do
          configure do |c|
            c.server   = Settings.bot.server
            c.port     = Settings.bot.port
            c.nick     = Settings.bot.nick
            c.channels = Settings.bot.channels
            c.verbose  = Settings.bot.verbose
            c.plugins.plugins  = plugins
          end
        end
      end

      def getallplugins
        Dir.glob(File.expand_path(".")+'/lib/plugins/*.rb') do |item|
          require item
        end

        plugins = Array.new()
        Object.constants().map do |const|
          begin
            klass = eval("#{const}")
            if klass.superclass.to_s == "CinchPlugin"
             plugins << klass
            end
          rescue
          end
        end
        return plugins
      end

      def run
        @bot.start
      end

      def threads
        Dir.glob(File.expand_path(".")+'/lib/threads/*.rb') do |item|
          require item
        end
        Object.constants().map do |const|
          begin
            klass = eval("#{const}")
            if klass.superclass.to_s == "CinchThread"
             Thread.new{ klass.new(@bot).start }
            end
          rescue
          end
        end
      end
  end
end
