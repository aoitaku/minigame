require 'dxruby'
require_relative 'src/config'

APP_DIR = __dir__
CONFIG_FILE = APP_DIR + ?\\ + "config.json"
CONFIG = Config.load(CONFIG_FILE)
tmx_file = CONFIG.last_file || Window.open_filename(
  [["TMX ファイル(*.tmx)","*.tmx"]],
  "読み込む TMX ファイルを選択してください"
)
exit unless tmx_file

unless CONFIG.last_file
  CONFIG.last_file = tmx_file
  CONFIG.save(CONFIG_FILE)
end

require_relative 'src/application'
