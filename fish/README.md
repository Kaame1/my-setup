# fish

Конфиг шелла [Fish](https://fishshell.com/).

## Файлы

| Файл                          | Симлинк на                              | Назначение                            |
| ----------------------------- | --------------------------------------- | ------------------------------------- |
| `config.fish`                 | `~/.config/fish/config.fish`            | алиасы, `$PATH`, функции `claude`/`tree3` |
| `conf.d/colors.fish`          | `~/.config/fish/conf.d/colors.fish`     | цвета синтаксиса и пейджера (Gruvbox Dark) |
| `functions/fish_prompt.fish`  | `~/.config/fish/functions/fish_prompt.fish` | свой prompt (cwd + git + статус)  |
| `fish_variables`              | *копируется один раз* в `~/.config/fish/` | universal-переменные (fish их переписывает) |

`fish_variables` копируется, а **не** симлинкуется, потому что fish
перезаписывает его во время работы.

## Быстрый гайд

### Алиасы

| Алиас     | Разворачивается в |
| --------- | ----------------- |
| `vim`     | `nvim`            |
| `vimdiff` | `nvim -d`         |
| `ll`      | `ls -la`          |
| `l`       | `ls -l`           |
| `video`   | `mpv --hwdec=auto`|

### Функции

- **`tree3`** — `tree -d -L 3`, игнорируя dotfiles и `node_modules`.
- **`claude`** — перекрашивает текущий терминал в кремовый (`#FDF5E3`),
  запускает Claude Code в светлой теме, по выходу возвращает цвета обратно.
  Как вызывать:
  - `claude` — без аргументов переходит в `~/workspace/claude`;
  - `claude <папка>` — переходит в указанную папку;
  - `claude <промпт/флаги>` — остаётся в текущей папке, передаёт всё в `claude`.

### PATH

Добавляются `~/.local/bin` и `/opt/arm-none-eabi-10.3/bin` (тулчейн ARM GCC).
