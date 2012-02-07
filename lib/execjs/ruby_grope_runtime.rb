require 'json'

module ExecJS
  class GropeRuntime
    class Context
      def initialize(source = "")
        source = source.encode('UTF-8') if source.respond_to?(:encode)

        @env = Grope::Env.new
        @env.load 'about:blank'
        @env.eval(source)
      end

      def exec(source, options = {})
        source = source.encode('UTF-8') if source.respond_to?(:encode)

        if /\S/ =~ source
          eval "(function(){#{source}})()", options
        end
      end

      def eval(source, options = {})
        source = source.encode('UTF-8') if source.respond_to?(:encode)

        if /\S/ =~ source
          unbox @env.eval("return JSON.stringify(#{source})")
        end
      rescue => e
        if e.message == "syntax error"
          raise RuntimeError, e.message
        else
          raise ProgramError, e.message
        end
      end

      def call(properties, *args)
      #   unbox @rhino_context.eval(properties).call(*args)
      # rescue ::Rhino::JavascriptError => e
      #   if e.message == "syntax error"
      #     raise RuntimeError, e.message
      #   else
      #     raise ProgramError, e.message
      #   end
      end

      def unbox(value)
        JSON.parse('[%s]' % value.to_s)[0]
      rescue JSON::ParserError
        nil
      end
    end

    def name
      "Grope"
    end

    def exec(source)
      context = Context.new
      context.exec(source)
    end

    def eval(source)
      context = Context.new
      context.eval(source)
    end

    def compile(source)
      Context.new(source)
    end

    def available?
      require "grope"
      true
    rescue LoadError
      false
    end
  end
end
