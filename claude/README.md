# claude

Конфиг [Claude Code](https://claude.com/claude-code). Файлы симлинкуются
поштучно в `~/.claude/`, чтобы не трогать рантайм-файлы (credentials, история,
сессии, projects).

> Секретов в этой папке нет — на каждой машине логинишься заново.

## Файлы

| Файл               | Симлинк на                    | Назначение                                       |
| ------------------ | ----------------------------- | ------------------------------------------------ |
| `CLAUDE.md`        | `~/.claude/CLAUDE.md`         | глобальные инструкции (отвечать по-русски и т.д.) |
| `settings.json`    | `~/.claude/settings.json`     | модель `opus[1m]`, effort `xhigh`, тёмная тема, statusline |
| `keybindings.json` | `~/.claude/keybindings.json`  | `Shift+Enter` = новая строка в чате              |
| `statusline.sh`    | `~/.claude/statusline.sh`     | строка статуса: модель · effort · ctx% · лимиты 5h/7d |
| `run-claude`       | `~/.claude/run-claude`        | лаунчер для профиля `claude` в Terminator        |

## Быстрый гайд

### Установка

`setup.sh` ставит CLI командой `curl -fsSL https://claude.ai/install.sh | bash`
(попадает в `~/.local/bin/claude`). После — запусти `claude` и войди в аккаунт.

### Запуск в светлой теме

Из fish просто набери `claude` — функция из [`../fish`](../fish/) перекрасит
терминал в кремовый и запустит Claude в светлой теме. В Terminator для этого
есть отдельный профиль `claude` (запускает `run-claude`).

### Что показывает statusline

Две строки:

```
~/путь/к/проекту  git:ветка*
Модель · effort  ctx:NN%  5h:[████░░░░░░] 40% 3h12m  7d:[██░░░░░░░░] 18% 6d22h
```

- `ctx:` — сколько занято контекстное окно;
- `5h` / `7d` — использование лимитов и время до сброса;
- цвета: зелёный < 50% < жёлтый < 80% < красный.
- Нужен `jq` (ставится через `setup.sh`).

### Основные настройки (`settings.json`)

| Параметр      | Значение   |
| ------------- | ---------- |
| `model`       | `opus[1m]` |
| `effortLevel` | `xhigh`    |
| `theme`       | `dark`     |
| `statusLine`  | `statusline.sh` |

> Путь к `statusline.sh` в `settings.json` и путь к бинарнику в `run-claude`
> автоматически переписываются в `setup.sh`, если имя пользователя другое.
