#!/bin/bash

set -euf

ROOT="$(git rev-parse --show-toplevel)"

RELEASE_TAG="$1"
BRANCH="update-generated-docs-${RELEASE_TAG}"

function update_docs()
{
  mkdir -p tmp
  git clone --depth 1 -b "${RELEASE_TAG}" "https://github.com/banzaicloud/kafka-operator.git" "tmp/kafka-operator"
  cd 'tmp/kafka-operator/'
  rm -rf ./docs/types
  make docs
  cp -R ./docs/types "${ROOT}/docs/configuration/"
  cd -
  rm -rf tmp
}

function main()
{
  git checkout -b "${BRANCH}"
  update_docs
  git add --all
  if git commit --dry-run; then
    git commit -m "Update generated docs (${RELEASE_TAG})"
    git checkout master
    git merge "${BRANCH}"
    git push origin master
  else
    echo "Nothing has changed."
    #circleci-agent step halt
    exit 0
  fi
}

main
