# Android Configuration Files

This directory contains sensitive configuration files that are gitignored.

## Required Setup

### 1. Signing Configuration (`key.properties`)

Copy the example file and fill in your keystore details:

```bash
# The key.properties file should already exist with your signing config
```

### 2. PostHog Configuration (`posthog.properties`)

**First-time setup:**

```bash
cp posthog.properties.example posthog.properties
```

Then edit `posthog.properties` and fill in your actual PostHog API key:

```properties
POSTHOG_API_KEY=phc_YOUR_ACTUAL_API_KEY_HERE
POSTHOG_HOST=https://eu.i.posthog.com
```

## Files

✅ **Safe to commit:**

- `posthog.properties.example` (template)
- `key.properties.example` (if you create one)
- This README

❌ **Never commit:**

- `posthog.properties` (contains API key)
- `key.properties` (contains passwords)

## Build Process

The Gradle build script (`app/build.gradle.kts`) automatically:

1. Loads values from `posthog.properties`
2. Injects them into `AndroidManifest.xml` via manifest placeholders
3. Falls back to default values if the file doesn't exist (for CI/CD)

## CI/CD Setup

For continuous integration, you can either:

1. Create the `posthog.properties` file in your CI environment
2. Use environment variables and modify `build.gradle.kts` to read from them
3. Use the fallback default values (not recommended for production)
