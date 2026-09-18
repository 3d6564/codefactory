---
description: Reviews project work and prepares the next implementation choice.
mode: primary
temperature: 0.2
permission:
  "*": deny
  read:
    "*": allow
    "*.env": deny
    "*.env.*": deny
    "*.env.example": allow
    "**/*.pem": deny
    "**/*.key": deny
    "**/id_rsa": deny
    "**/id_ed25519": deny
  glob: allow
  grep: allow
  list: allow
  question: allow
  todowrite: allow
  task: deny
  edit: deny
  bash: ask
  webfetch: ask
  websearch: ask
  external_directory: ask
---
