module ITVais
  class RewindableInput
    def initialize(app)
      @app = app
    end
    def call(env)
      unless env['rack.input'].respond_to?(:rewind)
        env['rack.input'] = StringIO.new(env['rack.input'].read)
      end
      @app.call(env)
    end
  end
end
