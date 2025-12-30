# Changelog

All notable changes to SessionManager will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.5] - 2025-12-30

### Fixed
- **CRITICAL**: Fixed `sessionmanager.service` file paths pointing to non-existent `session_manager.py`
- **CRITICAL**: Removed problematic `sys.path` manipulation in `cli.py` that could cause import conflicts
- Enhanced PID file cleanup with try-finally blocks to prevent stale PID files
- Improved error handling for file I/O operations in whitelist management
- Better error messages with exception class names in monitor loop

### Changed
- Refactored duplicate report generation code into single `_print_report()` helper method (~45 lines reduced)
- Added database context manager support (`__enter__` and `__exit__`) for proper resource management
- Enhanced error handling across all modules (database, whitelist, enforcer, monitor)
- Improved `install.sh` with comprehensive error checking and validation
- Updated all docstrings with parameter and return type documentation

### Added
- Database context manager for use in `with` statements
- Error handling for SQLite operations with graceful degradation
- Validation in install.sh for missing shell configuration files
- Detailed error messages for permission denied scenarios
- **Full manual installation support** in `install.sh` (binary, Python package, systemd service, completions)
- `uninstall.sh` script for removing manual installations
- `setup.py` for pip-based installation support
- Comprehensive installation to `~/.local` for user-level access

### Maintenance
- Maintained modular architecture and code structure throughout
- Preserved all existing comments and functionality
- All Python modules passed syntax validation (`python3 -m py_compile`)
- All Bash scripts passed syntax validation (`bash -n`)

## [0.0.4] - Previous Release
- AUR package improvements
- Service file additions

## [0.0.3] - Previous Release  
- Initial structured release

## [0.0.1] - Initial Release
- Basic session management functionality
- Activity tracking daemon
- Report generation
- Macro system

---

[0.0.5]: https://github.com/livaiyena/sessionmanager/compare/v0.0.4...v0.0.5
[0.0.4]: https://github.com/livaiyena/sessionmanager/compare/v0.0.3...v0.0.4
[0.0.3]: https://github.com/livaiyena/sessionmanager/compare/v0.0.1...v0.0.3
[0.0.1]: https://github.com/livaiyena/sessionmanager/releases/tag/v0.0.1
