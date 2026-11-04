# Contributing to SlimBrave-Mac

Thank you for your interest in improving SlimBrave-Mac! 🎉

## How You Can Help
- **Report Bugs**: If Brave releases an update that introduces new policy keys or alters existing ones, please open an issue.
- **Propose New Policy Keys**: Found another useful Chromium or Brave policy? Submit an issue or PR.
- **Channel Support**: Test and help refine support for Brave Beta, Dev, and Nightly channels.
- **Documentation**: Help improve guides or translations.

## Development Workflow
1. Fork the repository.
2. Create a branch: `git checkout -b feature/new-policy`.
3. Test changes locally on macOS using `plutil -lint` to ensure generated plists are valid.
4. Verify policies take effect in `brave://policy`.
5. Submit a Pull Request with a clear description of changes.

## Code Standards
- Keep shell scripts compatible with standard macOS `/bin/bash` (Bash 3.2+).
- Always use `plutil` to validate generated property lists.
- Avoid external dependencies beyond native macOS tools (`plutil`, `PlistBuddy`, `defaults`).
