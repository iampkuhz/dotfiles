# Homebrew 自动更新频率（秒）：7 天
export HOMEBREW_AUTO_UPDATE_SECS="604800"

# Homebrew 国内源（中科大）
export HOMEBREW_API_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles/api"
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.ustc.edu.cn/homebrew-core.git"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"

# 将 Homebrew 路径放到前面（Apple Silicon）
path_prepend "/opt/homebrew/bin"
path_prepend "/opt/homebrew/sbin"
