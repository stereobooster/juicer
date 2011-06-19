require "juicer/binary"

module Juicer
  #
  # A Ruby API to Nicole Sullivan genious CssLint program
  # http://csslint.net
  #
  # CssLint parses CSS code and identifies (potential) problems.
  # 
  #
  class CssLint
    include Juicer::Binary

    def initialize(options = {})
      super(options[:java] || "java")
      path << options[:bin_path] if options[:bin_path]
    end

    #
    # Checks if a files has problems. Also includes experimental support for CSS
    # files. CSS files should begin with the line @charset "UTF-8";
    #
    # Returns a Juicer::CssLint::Report object
    #
    def check(file)
      rhino_jar = rhino
      js_file = locate_lib

      raise FileNotFoundError.new("Unable to locate Rhino jar '#{rhino_jar}'") if !rhino_jar || !File.exists?(rhino_jar)
      raise FileNotFoundError.new("Unable to locate CssLint '#{js_file}'") if !js_file || !File.exists?(js_file)
      raise FileNotFoundError.new("Unable to locate input file '#{file}'") unless File.exists?(file)

      lines = execute(%Q{-jar "#{rhino}" "#{locate_lib}" "#{file}"}).split("\n")
      return Report.new if lines.length == 1 && lines[0] =~ /csslint: No problems/

      report = Report.new
      lines = lines.reject { |line| !line || "#{line}".strip == "" }
      report.add_error(lines.shift, lines.shift) while lines.length > 0

      return report
    end

    def rhino
      files = locate("**/rhino*.jar", "RHINO_HOME")
      !files || files.empty? ? nil : files.sort.last
    end

    def locate_lib
      files = locate("**/csslint.js", "CSSLINT_HOME")
      !files || files.empty? ? nil : files.sort.last
    end

    #
    # Represents the results of a CssLint run
    #
    class Report
      attr_accessor :errors

      def initialize(errors = [])
        @errors = errors
      end

      def add_error(message, code)
        @errors << CssLint::Error.new(message, code)
      end

      def ok?
        @errors.nil? || @errors.length == 0
      end
    end

    #
    # A CssLint error
    #
    class Error
      attr_accessor :message, :code

      def initialize(message, code)
        @message = message
        @code = code
      end

      def to_s
        "#@message\n#@code"
      end
    end
  end
end
