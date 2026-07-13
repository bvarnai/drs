# Development Guide

This guide describes how to develop, test, and release the `drs` utility.

## Testing and Local Playgrounds

There is no automated test suite. Instead, a Docker-based demo environment is provided to test the features and behaviors of `drs` manually.

To run the client-server demo environment:

1. Navigate to the `demo/` directory:
   ```bash
   cd demo
   ```
2. Start the server container in the background:
   ```bash
   docker-compose up -d drs-server
   ```
3. Run the interactive client container:
   ```bash
   docker-compose run --rm drs-client
   ```

For detailed usage instructions, refer to the [demo README](file:///home/bvarnai/work/drs/demo/README.md).

---

## Release Process

To publish a new version:

1. **Bump Version:** Update the `DRS_VERSION` constant in [src/common.sh](file:///home/bvarnai/work/drs/src/common.sh#L5) (e.g., `declare -r DRS_VERSION="1.1.0"`).
2. **Commit:** Commit the version bump:
   ```bash
   git add src/common.sh
   git commit -m "chore: bump version to 1.1.0"
   ```
3. **Tag:** Tag the commit using semantic versioning prefixed with `v`:
   ```bash
   git tag -a v1.1.0 -m "Release v1.1.0"
   ```
4. **Push:** Push both the commit and the tag to GitHub:
   ```bash
   git push origin main
   git push origin v1.1.0
   ```

Once pushed, the Release GitHub Actions workflow will automatically run, package the release assets (`drs.tar.gz` and `drs.tar.gz.sha256`), and publish them to a new GitHub Release with auto-generated release notes.
