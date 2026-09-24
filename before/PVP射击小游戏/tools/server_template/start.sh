#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")"

# Prefer an explicit Java binary, then local installations, then HMCL's Java 25.
java_bin="${PVPSHOT_JAVA:-}"
if [[ -z "$java_bin" ]]; then
  candidates=()
  if [[ -n "${JAVA_HOME:-}" ]]; then candidates+=("$JAVA_HOME/bin/java"); fi
  if command -v java >/dev/null 2>&1; then candidates+=("$(command -v java)"); fi
  if [[ -x /usr/libexec/java_home ]]; then
    jdk_dir="$(/usr/libexec/java_home -v 25 2>/dev/null || true)"
    if [[ -n "$jdk_dir" ]]; then candidates+=("$jdk_dir/bin/java"); fi
  fi
  for candidate in "$HOME"/Library/Application\ Support/hmcl/java/*/mojang-java-runtime-epsilon/jre.bundle/Contents/Home/bin/java; do
    [[ -x "$candidate" ]] && candidates+=("$candidate")
  done
  for candidate in "${candidates[@]}"; do
    version="$({ "$candidate" -version; } 2>&1 || true)"
    if [[ "$version" =~ version[[:space:]]\"25[\.\"] ]]; then java_bin="$candidate"; break; fi
  done
fi
if [[ -z "$java_bin" || ! -x "$java_bin" ]]; then
  echo '需要 Java 25。可设置 PVPSHOT_JAVA 为 Java 25 的 bin/java 完整路径。'
  exit 1
fi
version="$({ "$java_bin" -version; } 2>&1)"
if ! [[ "$version" =~ version[[:space:]]\"25[\.\"] ]]; then
  echo '此测试服务端要求 Java 25。'; echo "$version"; exit 1
fi
[[ -f server.jar && -f world/level.dat && -f world/datapacks/pvpshot/pack.mcmeta ]] || {
  echo '测试包不完整：缺少 server.jar、world 或数据包。'; exit 1;
}
echo "Java: $java_bin"
java_command=("$java_bin" -Xms512M "-Xmx${PVPSHOT_MAX_MEMORY:-4G}")
if [[ -f protection-required.txt || -f protection/pvpshot-protection-26.2.jar ]]; then
  for name in pvpshot-protection-26.2.jar pvpshot-protection-runtime-26.2.jar regions.tsv; do
    [[ -f "protection/$name" ]] || { echo "设施保护模块缺少文件：protection/$name"; exit 1; }
  done
  java_command+=("-Dpvpshot.protection.server=server.jar" "-javaagent:protection/pvpshot-protection-26.2.jar=protection/regions.tsv")
  echo '设施保护模块：已配置（据点、基地、补给箱）'
fi
if [[ "${1:-}" == '--check' ]]; then
  echo 'Java 25、服务端文件与测试世界检查通过；未启动服务器。'; exit 0
fi
if ! grep -Eq '^eula=true[[:space:]]*$' eula.txt; then
  echo '请先阅读 https://aka.ms/MinecraftEULA，同意后自行把 eula.txt 改为 eula=true，再启动。'
  exit 1
fi
exec "${java_command[@]}" -jar server.jar nogui
