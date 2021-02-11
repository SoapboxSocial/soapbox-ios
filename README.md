# Soapbox iOS App

## Developing

1. Install [Tuist](https://github.com/tuist/tuist)

```sh
bash <(curl -Ls https://install.tuist.io)
```

2. Install [Fastlane](https://fastlane.tools/)

```sh
brew install fastlane
```

3. Install [Cocoapods](https://cocoapods.org/)

```sh
sudo gem install cocoapods
```

4. Setup the XCode project:

```sh
make setup
```

## Contributing

Open the Xcode Workspace once the generation has completed and get contributing!

### Branch Naming

We like to stick to a consistent branch naming pattern to keep things clean.

Please stick to the following:

- `enhancement/my-branch-name`:
  For anything related to improving a feature, part of the app, updating translation files, updating screenshots, etc.
- `fix/my-branch-name`:
  For anything related to fixes for a broken feature, typos, etc.
- `feature/my-branch-name`:
  For anything related to building out new parts of the app, overhauls of parts of the app, etc.
