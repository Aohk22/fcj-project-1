#!/usr/bin/env bash

arn_build_versions=()
arn_pipelines=(
  "arn:aws:imagebuilder:ap-southeast-2:005716755011:image-pipeline/fhandle-img-pipeline"
  "arn:aws:imagebuilder:ap-southeast-2:005716755011:image-pipeline/fquery-img-pipeline"
)

echo "Sending pipeline requests."
for arn in "${arn_pipelines[@]}"; do
  result=$(
    aws imagebuilder start-image-pipeline-execution \
      --image-pipeline-arn "${arn}"
  )
  arn_build_versions+=("$(echo "${result}" | jq -r '.imageBuildVersionArn')")
done

for arn in "${arn_build_versions[@]}"; do
  echo "$arn"
done

# wait for image.
for build_version in "${arn_build_versions[@]}"; do
  echo "Polling ${build_version}..."
  while
    status="$(aws imagebuilder get-image --image-build-version-arn "$build_version" | jq -r '.image.state.status')"
    prev_status="_none"
    if [[ "$prev_status" != "${status}" ]]; then
      echo "Status: ${status}"
      prev_status="${status}"
    fi
    sleep 5
    [[ "$status" != "AVAILABLE" ]]
  do true; done
done
echo "Image build complete."
