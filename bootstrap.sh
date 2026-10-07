#!/data/data/com.termux/files/usr/bin/bash
# bootstrap.sh — установка Termux Assistant AI одной командой
# Использование:
#   curl -fsSL https://raw.githubusercontent.com/CR4CODE/termux-assistant-ai-releases/main/bootstrap.sh | bash
#
# Что делает:
#   1. Проверяет Termux
#   2. Ставит python, git, curl, termux-api
#   3. Скачивает APK последнего релиза
#   4. Открывает установщик
set -e

RELEASES_API="https://api.github.com/repos/CR4CODE/termux-assistant-ai-releases/releases/latest"

echo "═══════════════════════════════════════════════"
echo "  Termux Assistant AI — установка"
echo "═══════════════════════════════════════════════"
echo

# Проверка окружения
if [ ! -d "/data/data/com.termux" ]; then
    echo "❌ Это не Termux. Установи из F-Droid:"
    echo "   https://f-droid.org/packages/com.termux/"
    exit 1
fi

if [ "$(id -u)" = "0" ]; then
    echo "⚠ Запущено от root. Termux работает от обычного пользователя."
    exit 1
fi

# Установка зависимостей
echo "[1/3] Проверка зависимостей..."
NEEDED=""
for c in python3 git curl; do
    command -v "$c" >/dev/null 2>&1 || NEEDED="$NEEDED $c"
done
command -v termux-wake-lock >/dev/null 2>&1 || NEEDED="$NEEDED termux-api"

if [ -n "$NEEDED" ]; then
    echo "  Устанавливаю:$NEEDED"
    pkg install -y $NEEDED
else
    echo "  ✓ всё уже есть"
fi

# Скачивание APK
echo "[2/3] Скачиваю APK..."
APK_URL=$(curl -sL "$RELEASES_API" | python3 -c "import json,sys; d=json.load(sys.stdin); print(next((a['browser_download_url'] for a in d.get('assets',[]) if a['name'].endswith('.apk')), ''))")

if [ -z "$APK_URL" ]; then
    echo "  ⚠ Не смог найти APK. Скачай вручную:"
    echo "     https://github.com/CR4CODE/termux-assistant-ai-releases/releases/latest"
    exit 1
fi

APK_PATH="$HOME/storage/downloads/termux-assistant-ai.apk"
mkdir -p "$HOME/storage/downloads" 2>/dev/null || true

if [ ! -d "$HOME/storage/downloads" ]; then
    echo "  ⚠ Нет доступа к /sdcard. Запусти: termux-setup-storage"
    APK_PATH="$HOME/termux-assistant-ai.apk"
fi

curl -L -o "$APK_PATH" "$APK_URL"
echo "  ✓ Скачан: $APK_PATH"

# Открытие установщика
echo "[3/3] Открываю установщик..."
if command -v termux-open >/dev/null 2>&1; then
    termux-open "$APK_PATH"
else
    echo "  Открой файл вручную: $APK_PATH"
fi

echo
echo "═══════════════════════════════════════════════"
echo "  ✅ ГОТОВО"
echo "═══════════════════════════════════════════════"
echo "Подтверди установку в системном окне."
echo "После установки открой приложение → Мастер настройки."
echo
