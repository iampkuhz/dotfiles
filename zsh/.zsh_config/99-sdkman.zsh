# SDKMAN：默认放在最后，避免 PATH / function 被前面配置覆盖。
export SDKMAN_DIR="$HOME/.sdkman"

# 启动加速：改为懒加载，只有首次调用 sdk/java/javac/mvn/gradle 时才 source sdkman-init.sh。
_lazy_load_sdkman() {
  unset -f sdk java javac mvn gradle _lazy_load_sdkman
  [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
}

sdk() {
  _lazy_load_sdkman
  sdk "$@"
}
java() {
  _lazy_load_sdkman
  java "$@"
}
javac() {
  _lazy_load_sdkman
  javac "$@"
}
mvn() {
  _lazy_load_sdkman
  mvn "$@"
}
gradle() {
  _lazy_load_sdkman
  gradle "$@"
}
