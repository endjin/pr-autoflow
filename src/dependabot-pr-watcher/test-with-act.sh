act pull_request -e test-workflow-event.json -j test_job_with_prs -W . -s GITHUB_TOKEN=foo
act pull_request -e test-workflow-event.json -j test_job_with_no_prs -W . -s GITHUB_TOKEN=foo
