# SDKMAN：默认放在最后，避免 PATH / function 被前面配置覆盖。
export SDKMAN_DIR="$HOME/.sdkman"

# 启动加速：改为懒加载，只有首次调用 sdk/java/javac/mvn/gradle 时才 source sdkman-init.sh。
# 每个 wrapper 自包含 lazy-load 逻辑，不依赖外部 helper 函数，避免 shell snapshot 恢复时缺失。
sdk() {
  [ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
  unset -f sdk java javac mvn gradle
  sdk "$@"
}
java() {
  [ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
  unset -f sdk java javac mvn gradle
  java "$@"
}
javac() {
  [ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
  unset -f sdk java javac mvn gradle
  javac "$@"
}
mvn() {
  [ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
  unset -f sdk java javac mvn gradle
  mvn "$@"
}
gradle() {
  [ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
  unset -f sdk java javac mvn gradle
  gradle "$@"
}
