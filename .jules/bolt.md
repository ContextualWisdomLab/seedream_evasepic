
## 2024-06-22 - [Redundant Python Imports in Shell Scripts]
**Learning:** Checking for Python module availability by doing `python3 -c "import module"` followed immediately by executing a heredoc that imports the same module causes redundant execution overhead. For heavy modules like `whisper`, this doubles a multi-second initialization delay.
**Action:** Instead of checking module availability in a separate shell step, wrap the initial import in a `try...except ImportError` block within the primary Python execution script and use `sys.exit()` to gracefully fallback or terminate.
