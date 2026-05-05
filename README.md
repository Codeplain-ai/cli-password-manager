# CLI Password Manager — Plain Project

A [Plain](https://codeplain.ai) spec-driven project defining a secure, offline CLI password manager ("The Vault").

## Overview

The `.plain` files in this repository are specifications that Plain uses to generate the implementation. The Vault stores credentials in an encrypted local file (`vault.dat`) protected by a master password, using AES-256-GCM encryption and Argon2id key derivation.

## Features

- **Encrypted local storage** — credentials are stored in a single `vault.dat` file, encrypted with AES-256-GCM and never written to disk in plaintext
- **Key derivation** — the master password is never stored; an Argon2id KDF derives the encryption key at runtime from a random salt
- **Full credential management** — supports adding, listing, retrieving, and deleting entries via a simple CLI (`init`, `add`, `get`, `list`, `delete`)
- **Clipboard integration** — retrieved passwords can be copied directly to the clipboard and automatically cleared after a configurable timeout

## Specs

| File | Description |
|------|-------------|
| `vault_reqs.plain` | Core vault definitions and requirements |
| `vault-cli.plain` | CLI command specifications |
| `vault_functions.plain` | Vault storage and retrieval functions |
| `password_manager.plain` | Password input and validation |
| `key_management.plain` | Key derivation and management |
| `encryption.plain` | Encryption/decryption logic |
| `entry_reqs.plain` | Credential entry requirements |
| `vault_nfrs.plain` | Non-functional requirements |

## Tech Stack

| Technology | Purpose |
|------------|---------|
| Python 3.11+ | Implementation language |
| `cryptography` | AES-256-GCM encryption and decryption |
| `argon2-cffi` | Argon2id key derivation (KDF) |
| `pyperclip` | Clipboard operations |
| `pytest` | Automated testing framework |

## Running *codeplain rendering

```
codeplain vault-cli.plain
```

## License
This project is part of the Codeplain ecosystem.