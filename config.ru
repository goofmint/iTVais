require 'lib/rewindable_input'
use ITVais::RewindableInput
use Rack::CommonLogger
require 'start'
run Sinatra::Application
