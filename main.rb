require 'pathname'
require 'dxruby'
require_relative 'src/config'

APP_DIR = Pathname.new(__dir__.gsub(File::ALT_SEPARATOR, File::SEPARATOR))
CONFIG_FILE = APP_DIR + 'config.json'
CONFIG = Config.load(CONFIG_FILE)
tmx_file = CONFIG.last_file || Window.open_filename(
  [["ステージ定義ファイル(*.yml)","*.yml"]],
  "読み込むステージ定義ファイルを選択してください"
)
exit unless tmx_file

unless CONFIG.last_file
  CONFIG.last_file = tmx_file.gsub!(File::ALT_SEPARATOR, File::SEPARATOR)
  CONFIG.save(CONFIG_FILE)
end

require_relative 'src/application'
