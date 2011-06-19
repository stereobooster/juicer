require "juicer"
require "juicer/install/base"
require "zip/zip"

module Juicer
  module Install
    #
    # Install and uninstall routines for the CSSLint library by Nicole Sullivan.
    # Installation downloads the jcsslint-rhino.js file and stores
    # them in the Juicer installation directory.
    #
    class CSSLintInstaller < Base
      attr_reader :latest

      def initialize(install_dir = Juicer.home)
        super(install_dir)
        @latest = "1.0"
        @website = "https://github.com/stubbornella/csslint/blob/master/"
        @path = "lib/csslint"
        @name = "CssLint"
        dependency :rhino
      end

      #
      # Install CSSLint. Downloads the js file and stores them in the
      # installation directory.
      #
      def install(version = nil)
        version = super(version)
        filename = download(File.join(@website, "build/csslint-rhino.js"))
      end

      #
      # Uninstalls CSSSLint
      #
      def uninstall(version = nil)
        super(version) do |dir, version|
          File.delete(File.join(dir, "bin", "csslint.js"))
        end
      end
    end

    #
    # This class makes it possible to do Juicer.install("csslint") instead of
    # Juicer.install("c_s_s_lint"). Sugar, sugar...
    #
    class CsslintInstaller < CSSLintInstaller
    end
  end
end
