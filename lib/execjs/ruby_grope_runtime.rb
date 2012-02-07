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
        f = @env.eval('return ' + properties)
        raise ProgramError if f.wso.class == OSX::WebUndefined

        unbox @env.eval('return function() { return JSON.stringify(' +
          properties +
          '.apply(this, arguments))}').
          call(f, *args)
      rescue => e
        raise ProgramError
      end

      def unbox(value)
        value = '[%s]' % value.to_s
        JSON.parse(value)[0]
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
