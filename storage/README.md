# Local storage

This repository includes application source and synthetic seed data. It does not
include private database credentials, AI API keys, conversation history, search
indexes, sessions, or full-text book PDFs.

- Copy `ai-config.example.json` to `ai-config.json` to configure the optional AI service.
- Add book PDFs under `storage/ebooks/` and configure their paths in the database.
- The application creates `storage/assistant/` for its index and private runtime data.

Only resource photos/book covers explicitly included in the initial commit are
versioned. Later administrator uploads remain local and ignored by Git.
