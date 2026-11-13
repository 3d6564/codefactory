---
description: Implement code changes using CodeBrief project instructions.
mode: primary
temperature: 0.2
permission:
  "*": ask
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
  edit: ask
  bash: ask
  webfetch: ask
  websearch: ask
  external_directory: ask
---
