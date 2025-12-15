# Publishing Instructions

## Prerequisites

1. **Create a pub.dev account** (if you don't have one):
   - Go to https://pub.dev
   - Sign in with your Google account
   - Complete your profile

2. **Get your pub.dev credentials**:
   - Go to https://pub.dev/account/tokens
   - Create a new token or use an existing one

## Publishing Steps

1. **Navigate to the package directory**:
   ```bash
   cd "/Volumes/Algzery/algzery package/islamic_prayer_times"
   ```

2. **Login to pub.dev** (if not already logged in):
   ```bash
   dart pub login
   ```
   - Enter your email and the token from pub.dev

3. **Verify the package one more time**:
   ```bash
   flutter pub publish --dry-run
   ```

4. **Publish the package**:
   ```bash
   flutter pub publish
   ```
   - This will upload your package to pub.dev
   - **Note**: Once published, you cannot delete or unpublish the package, only upload new versions

5. **Verify publication**:
   - Visit https://pub.dev/packages/islamic_prayer_times
   - Your package should be available within a few minutes

## Important Notes

- **Version**: The current version is `1.0.0`. For future updates, increment the version in `pubspec.yaml` following semantic versioning (e.g., 1.0.1 for patches, 1.1.0 for minor updates, 2.0.0 for major changes).

- **CHANGELOG.md**: Update the CHANGELOG.md file with each new version before publishing.

- **Documentation**: Make sure your README.md is complete and accurate as it will be displayed on pub.dev.

- **Tests**: Ensure all tests pass before publishing:
   ```bash
   flutter test
   ```

## After Publishing

1. Share your package URL: `https://pub.dev/packages/islamic_prayer_times`
2. Users can add it to their `pubspec.yaml`:
   ```yaml
   dependencies:
     islamic_prayer_times: ^1.0.0
   ```
3. Monitor for issues and feedback on pub.dev

## Updating the Package

When you need to publish an update:

1. Update the version in `pubspec.yaml`
2. Update `CHANGELOG.md` with the new changes
3. Run `flutter pub publish --dry-run` to verify
4. Run `flutter pub publish` to publish the new version

