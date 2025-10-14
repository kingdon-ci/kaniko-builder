# Build Scripts and Utilities

This directory contains scripts and utilities used by the GitLab CI pipeline.

## Scripts

### prepare_diff.sh

This script determines which directories need to be processed during a pipeline run.

**Functionality:**
- For merge requests: Compares against the target branch to find changed directories
- For main branch pushes: Compares against the previous commit
- Validates that each directory contains a `build-config.yaml` file
- Outputs a `dirs.txt` file with the list of directories to process

**Usage:**
The script is automatically called by the GitLab CI pipeline during the `prepare` stage.

**Environment Variables:**
- `CI_COMMIT_REF_NAME`: Current branch name
- `CI_MERGE_REQUEST_TARGET_BRANCH_NAME`: Target branch for merge requests
- `CI_PIPELINE_SOURCE`: Source of the pipeline (push, merge_request_event, etc.)

**Output:**
- `dirs.txt`: List of directories to process (one per line)
