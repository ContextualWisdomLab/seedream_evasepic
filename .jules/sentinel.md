## 2024-10-24 - Option Injection in yt-dlp Wrapper
**Vulnerability:** The download-reference.sh script passes a user-provided URL directly to yt-dlp without the `--` separator, allowing an attacker to pass arbitrary CLI flags (e.g., `--exec`) to yt-dlp, leading to remote command execution.
**Learning:** External CLI wrappers are susceptible to option injection if dynamic arguments begin with `-` or `--`.
**Prevention:** Always use `--` before dynamic arguments passed to CLI tools to indicate the end of options.
