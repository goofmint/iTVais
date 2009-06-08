require 'lib/rewindable_input'
use ITVais::RewindableInput
use Rack::CommonLogger
require 'app'
run Sinatra::Application
