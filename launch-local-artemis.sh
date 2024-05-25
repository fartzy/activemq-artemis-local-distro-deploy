#!/bin/zsh

# Function to fetch the latest tag from the GitHub repository and increment it
get_latest_tag() {
  # Clone the repository or fetch the latest tags if already cloned
  repo_dir="activemq-artemis"
  if [ ! -d "$repo_dir" ]; then
    git clone --quiet https://github.com/apache/activemq-artemis.git $repo_dir
  fi

  cd $repo_dir || exit
  git fetch --tags --quiet

  # Get the latest tag
  latest_tag=$(git tag --sort=v:refname | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | tail -n 1)
  cd ..

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

echo "Launching artemis..."
echo "Executing '${ARTEMIS_HOME}/bin/artemis create mybroker'..."

# Create the broker
${ARTEMIS_HOME}/bin/artemis create mybroker

# Copy configuration files
cp broker.xml mybroker/etc/
cp management.xml mybroker/etc/
cp bootstrap.xml mybroker/etc/
cp log4j2.properties mybroker/etc/
cp artemis.profile mybroker/etc/
cp artemis mybroker/bin/
cp login.config mybroker/etc/
cp artemis-roles.properties mybroker/etc/
cp artemis-users.properties mybroker/etc/
