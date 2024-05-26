#!/bin/zsh

# Function to fetch the latest tag from the GitHub repository and increment it
get_latest_tag() {
  # Fetch the tags page from GitHub
  tags_page=$(curl -s https://github.com/apache/activemq-artemis/tags)

  # Extract the latest tag using grep and sed
  latest_tag=$(echo "$tags_page" | grep -oP '(?<=/apache/activemq-artemis/releases/tag/)[^"]*' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | head -n 1)

  # Check if a valid tag was found
  if [ -z "$latest_tag" ]; then
    echo "Error: Could not fetch the latest tag."
    exit 1
  fi

  # Extract the version number and increment the minor version
  IFS='.' read -r major minor patch <<<"${latest_tag}"
  minor=$((minor + 1))
  patch=0

  # Construct the new version tag
  echo "${major}.${minor}.${patch}-SNAPSHOT"
}

# Get the current user
current_user=$(whoami)

# Check the number of arguments
if [[ $# -gt 1 ]]; then
  echo "Usage: $0 [RELEASE]"
  echo "Example: $0 2.34.0-SNAPSHOT"
  exit 1
fi

# Set RELEASE to the passed argument or default if no argument is provided
RELEASE=${1:-$(get_latest_tag)}

# Set ARTEMIS_HOME based on the RELEASE version
ARTEMIS_HOME="/Users/${current_user}/dev/activemq-artemis/artemis-distribution/target/apache-artemis-${RELEASE}-bin/apache-artemis-${RELEASE}"
export ARTEMIS_HOME=${ARTEMIS_HOME}

echo "ARTEMIS_HOME set to ${ARTEMIS_HOME}"
