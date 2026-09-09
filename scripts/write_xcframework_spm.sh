#!/bin/bash

# Get the zip file of the xcframework from ci
release_tag=$1
# Derive the owner from the repository being built rather than hardcoding it. A release
# cut from a fork was writing a manifest that pointed at UPSTREAM's releases, so SPM
# resolved the right version and checksum and then 404'd fetching the binary from a repo
# that has no such tag. GITHUB_REPOSITORY is set by Actions ("owner/name"); the fallback
# keeps this working when run by hand, and upstream's own CI is unaffected because there
# the variable already spells Rallista/valhalla-mobile.
release_repo="${GITHUB_REPOSITORY:-Rallista/valhalla-mobile}"
release_url="https://github.com/${release_repo}/releases/download/${release_tag}"
xcframework_zip="valhalla-wrapper.xcframework.zip"

# Get the checksum of the xcframework file.
xcframework_checksum=$(shasum -a 256 ${xcframework_zip} | awk '{print $1}')
artifact_url="${release_url}/${xcframework_zip}"

echo "Checksum: ${xcframework_checksum}"
echo "Release URL: ${artifact_url}"

# Replace `let useLocalBinary = true` line with `let useLocalBinary = false` in Package.swift
# sed -i '' "s|^let useLocalBinary: Bool = .*|let useLocalBinary: Bool = false|" Package.swift

# Replace `let version` line with the new binary url for the release artifact in Package.swift
sed -i '' "s|^let version: String = .*|let version: String = \"$release_tag\"|" Package.swift

# Replace let binaryChecksum: String? = nil with the new binary checksum for the release artifact in Package.swift
sed -i '' "s|^let binaryChecksum: String = .*|let binaryChecksum: String = \"$xcframework_checksum\"|" Package.swift
