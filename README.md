# my-setup

Мои личные dotfiles для чистой машины на **Ubuntu**. Клонируешь репозиторий,
запускаешь один скрипт — и на ноутбуке те же настройки терминала, шелла,
редактора и Claude Code.

## Что внутри

| Папка                        | Инструмент  | Что настраивает                                                |
| ---------------------------- | ----------- | -------------------------------------------------------------- |
| [`terminator/`](terminator/) | Terminator  | тема Gruvbox, профили `default` + `claude`, свои хоткеи         |
| [`fish/`](fish/)             | Fish shell  | цвета Gruvbox, алиасы, свой prompt, функция-лаунчер `claude`    |
| [`nvim/`](nvim/)             | Neovim      | конфиг «Sethy» на lazy.nvim + Mason LSP, Gruvbox                |
| [`claude/`](claude/)         | Claude Code | `settings.json`, keybindings, statusline, лаунчер, `CLAUDE.md`  |

В каждой папке есть свой README с быстрым гайдом и горячими клавишами.

## Как поднять новый ноутбук на Ubuntu

```bash
# 1. поставить git, залогиниться и склонировать репозиторий
sudo apt-get update && sudo apt-get install -y git
git clone git@github.com:Kaame1/my-setup.git ~/github/my-setup
cd ~/github/my-setup

# 2. запустить установщик
./setup.sh
```

Дальше:

1. **Перелогиниться** — чтобы fish стал шеллом по умолчанию.
2. Запустить `nvim` один раз — lazy.nvim и Mason сами поставят все плагины и LSP.
3. Запустить `claude` и войти в аккаунт.

## Ключевые решения

- **Симлинки, а не копии** — репозиторий становится единственным источником
  правды. Правишь конфиг → меняется файл в репозитории → `git` видит изменение.
  Не надо копировать туда-обратно. Существующие файлы бэкапятся в `*.bak-<дата>`.
- **`claude/` — только конфиги**, без `.credentials.json`, истории и сессий.
  На каждой машине логинишься заново.
- **Портируемость по пути** — если на новом ноуте другое имя пользователя,
  `setup.sh` сам перепишет `/home/arammatosyan` → `$HOME` в конфигах.
- **`setup.sh` ставит зависимости**: fish, terminator, neovim (свежий из PPA,
  нужен 0.10+), node/python/clang для LSP, `jq` (для statusline), ripgrep/fd/tree,
  буфер обмена.

### Флаги setup.sh

```bash
./setup.sh --links-only     # только симлинки (без sudo/apt)
./setup.sh --skip-packages  # пропустить установку пакетов
./setup.sh --skip-neovim    # пропустить установку Neovim
./setup.sh --skip-claude    # пропустить установку Claude Code
./setup.sh --skip-shell     # не менять шелл по умолчанию
./setup.sh --help
```

## Синхронизация репозитория

Так как всё на симлинках, любая правка живого конфига — это правка репозитория.
Закоммить и запушь, чтобы перенести на другую машину:

```bash
cd ~/github/my-setup
git add -A && git commit -m "tweak configs" && git push
```

## Заметки

- Целевая ОС: **Ubuntu** (apt). `setup.sh` использует `apt-get`.
- `fish/fish_variables` копируется один раз (не симлинк), потому что fish
  переписывает его во время работы.
