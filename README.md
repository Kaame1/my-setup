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

## Настройка SSH-ключа для GitHub

Клонирование идёт по SSH (`git@github.com:...`), поэтому сначала нужен
SSH-ключ, привязанный к аккаунту GitHub.

```bash
# 1. сгенерировать ключ (ed25519); на все вопросы можно жать Enter
ssh-keygen -t ed25519 -C "aram.matosyan@aerodynamics.am"

# 2. запустить ssh-agent и добавить ключ
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# 3. вывести ПУБЛИЧНЫЙ ключ и скопировать его целиком
cat ~/.ssh/id_ed25519.pub
```

Затем добавить ключ на GitHub:

1. Открыть **[github.com/settings/keys](https://github.com/settings/keys)**
   (или *Settings → SSH and GPG keys*).
2. Нажать **New SSH key**.
3. **Title** — любое имя (например «laptop-ubuntu»), **Key type** — `Authentication`.
4. Вставить содержимое `id_ed25519.pub` в поле **Key** и нажать **Add SSH key**.

Проверить, что всё работает:

```bash
ssh -T git@github.com
# ожидаемо: "Hi <username>! You've successfully authenticated..."
```

> ⚠️ Публичный (`.pub`) ключ добавляем на GitHub. Приватный (`~/.ssh/id_ed25519`)
> **никому не показываем и не коммитим**.

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
