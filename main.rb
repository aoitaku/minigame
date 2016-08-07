require 'pathname'
require 'dxruby'
require_relative 'src/config'

APP_DIR = Pathname.new(__dir__.gsub(File::ALT_SEPARATOR, File::SEPARATOR))
ASSET_DIR = APP_DIR + 'asset'
CONFIG_FILE = APP_DIR + 'config.json'
CONFIG = Config.load(CONFIG_FILE)
stage_file = CONFIG.last_file || Window.open_filename(
  [["ステージ定義ファイル(*.rb)","*.rb"]],
  "読み込むステージ定義ファイルを選択してください"
)
exit unless stage_file

unless CONFIG.last_file
  stage_file.gsub!(File::ALT_SEPARATOR, File::SEPARATOR)
  CONFIG.last_file = Pathname.new(stage_file).relative_path_from(ASSET_DIR)
  CONFIG.save(CONFIG_FILE)
end

require_relative 'src/application'
