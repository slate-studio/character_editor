module Character
  module Editor
    class Engine < ::Rails::Engine
      config.before_configuration do
      end
    end

    class << self
      def configure(&block)
        block.call(self)
      end
    end
  end
end