# localizx

A small, focused localization helper for Flutter that provides:
- runtime loading of locale JSON assets,
- a simple delegate to manage locale changes and persistence,
- a generator to produce static key classes from JSON files.

This README explains how to install, configure, and use the package and how to use the provided code generator.

## Features

- Load translations from JSON files (assets) and access them at runtime.
- Pluralization support using `intl`.
- A `LocalizationDelegate` with optional persistent preferences and device-locale fallback.
- Generator that creates a typed keys class from JSON translation files to avoid stringly-typed keys.


## License

This project is provided under the license in the repository (see `LICENSE`).
