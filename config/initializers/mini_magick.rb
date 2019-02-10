require 'mini_magick'

MiniMagick.configure do |config|
  config.shell_api = "posix-spawn"
  config.whiny = false
end
