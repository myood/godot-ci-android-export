# godot-ci-android-export

## What is this?

Docker image and gitlab pipelines configuration for exporting your Godot project to Android. Supports debug and release exports. If you have basic gitlab pipelines knowledge then you should know what to do - read gitlab-ci.yml.

## How it works?

Docker image installs Godot and all necessary dependencies for Android debug export. Then it sets up Godot editor settings for android debug export.

## How can I use it in my project?

Copy .gitlab-ci.yml to your project repository. Then create exports for your project with names from .gitlab-ci.yml in the GUI. You can follow offical tutorial and skip the initial setup. Also make sure to read .gitlab-ci.yml - it's somewhat documented with comments.
