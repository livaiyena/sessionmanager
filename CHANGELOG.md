# Changelog

## [0.0.7] - 2025-12-31

### Fixed
-   **CRITICAL**: Fixed syntax error in `cli.py` (indentation error in session status command).

## [0.0.6] - 2025-12-31

### Features
-   **Cleanup**: New `cleanup` command to prune old database entries (maintenance).
-   **Reports**: Added `--json` output flag for daily and weekly reports.

### Comparisons
-   **Documentation**: Rewritten README to be concise and strictly emoji-free.
-   **Refactor**: Sanitized all scripts and CLI output for strict style adherence.
-   **Packaging**: Modernized PKGBUILD to use PEP 517 standard.

## [0.0.5] - 2025-12-30

### Fixed
-   Fixed `sessionmanager.service` file paths pointing to non-existent `session_manager.py`
-   Removed problematic `sys.path` manipulation in `cli.py` that could cause import conflicts
-   Enhanced PID file cleanup with try-finally blocks to prevent stale PID files
-   Improved error handling for file I/O operations in whitelist management
-   Better error messages with exception class names in monitor loop

### Changed
-   Refactored duplicate report generation code into single `_print_report()` helper method
-   Added database context manager support (`__enter__` and `__exit__`) for proper resource management
-   Enhanced error handling across all modules (database, whitelist, enforcer, monitor)
-   Improved `install.sh` with comprehensive error checking and validation
-   Updated all docstrings with parameter and return type documentation

### Added
-   Database context manager for use in `with` statements
-   Error handling for SQLite operations with graceful degradation
-   Validation in install.sh for missing shell configuration files
-   Detailed error messages for permission denied scenarios
-   **Full manual installation support** in `install.sh` (binary, Python package, systemd service, completions)
-   `uninstall.sh` script for removing manual installations
-   `setup.py` for pip-based installation support
-   Comprehensive installation to `~/.local` for user-level access

### Maintenance
-   Maintained modular architecture and code structure throughout
-   Preserved all existing comments and functionality
-   All Python modules passed syntax validation (`python3 -m py_compile`)
-   All Bash scripts passed syntax validation (`bash -n`)

## [0.0.4] - 2025-12-30
-   AUR package improvements
-   Service file additions

## [0.0.3] - 2025-12-29
-   Initial structured release

## [0.0.2] - 2025-12-29
-   Fixed completions logic

## [0.0.1] - 2025-12-29
-   Basic session management functionality
-   Activity tracking daemon
-   Report generation
-   Macro system

---

[0.0.7]: https://github.com/livaiyena/sessionmanager/compare/v0.0.6...v0.0.7
[0.0.6]: https://github.com/livaiyena/sessionmanager/compare/v0.0.5...v0.0.6
[0.0.5]: https://github.com/livaiyena/sessionmanager/compare/v0.0.4...v0.0.5
[0.0.4]: https://github.com/livaiyena/sessionmanager/compare/v0.0.3...v0.0.4
[0.0.3]: https://github.com/livaiyena/sessionmanager/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/livaiyena/sessionmanager/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/livaiyena/sessionmanager/releases/tag/v0.0.1
