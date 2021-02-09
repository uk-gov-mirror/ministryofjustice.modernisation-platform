#!/bin/bash

all_definitions=$(jq -n '[ inputs | . + { filename: input_filename } ]' environments/*.json)

# Check every definition is creating at least one environment
environments=$(jq '[ .[] | select(.environments? | length == 0) | . + { violation: "Empty environments array" } ]' <<< "$all_definitions")

# Check every definition has tags set, including: "application", "business-unit", and "owner"
tags=$(jq '[ .[] | select(.tags? | (keys != ["application", "business-unit", "owner"]) ) | . + { violation: "Missing tag keys, expected: [\"application\", \"business-unit\", \"owner\"], got: \(.tags | keys)" } ]' <<< "$all_definitions")

# Check .tags.business-unit is valid
business_units=$(jq '[ .[] | select(.tags?."business-unit"? != null) | ( select(.tags?."business-unit"? | contains("HQ") or contains("HMPPS") or contains("OPG") or contains("LAA") or contains("HMCTS") or contains("CICA") or contains("Platforms") or contains("CJSE") or contains("Probation") | not) ) | . + { violation: "Unexpected business unit" } ]' <<< "$all_definitions")

errors=$(jq -e -s '[ . | add | .[] | { filename: .filename, violation: .violation } ] | .[] | .filename + " has an error: " + .violation' <<< "$environments $tags $business_units")

if [ -z "$errors" ]; then
  echo "No errors, all OK!"
  exit 0
else
  echo "$errors"
  exit 1
fi
