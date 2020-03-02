#!/bin/bash
set -e
 
# If "-e uid={custom/local user id}" flag is not set for "docker run" command, use 9999 as default
_GROUP=${GROUP_:-python}
_USER=${USER_:-python}
_UID=${UID_:-9999}
_GID=${GID_:-9999}

# Notify user about the UID selected
echo "Current UID : $_UID"

# Notify user about the UID selected
echo "Current GID : $_GID"

# NOTE: Had to resort to useradd and groupadd in shadow package due to the issue described in https://stackoverflow.com/questions/41807026/cant-add-a-user-with-a-high-uid-in-docker-alpine/53604334#53604334

# Create group called "container" or ${_GROUP} value with CURRENT_GID
/usr/sbin/groupadd --gid $_GID $_GROUP

# Create user with selected UID
/usr/sbin/useradd --system --create-home --shell /bin/bash --home /home/${_USER} --uid $_UID --gid $_GID $_USER

# Change ownership of /puml (source) and /images (out) paths to current UID:GID
chown -R $_UID:$_GID /puml
chown -R $_UID:$_GID /images

# PlantUML client environment variables
_SRC_DIR="/puml" # using Docker bind mount volume; see Dockerfile
_OUT_DIR="/images" # Docker WORKDIR; using Docker bind mount volume; see Dockerfile
_SRC_FILE_REG_EX_SEARCH_PATTERN="*.puml"
_OUT_IMAGE_FILE_FORMAT=${OUT_IMAGE_FILE_FORMAT_:-png}
_PLANTUML_SERVER_URI=${PLANTUML_SERVER_URI_:-http://localhost:8080/}
_PLANTWEB_ENGINE="plantuml"

# Execute Plantweb Render process for each found source file
# Output path is the Docker WORKDIR value; I set _OUT_DIR in just for clarity
    find ${_SRC_DIR} -type f -name "${_SRC_FILE_REG_EX_SEARCH_PATTERN}" -exec su-exec python plantweb --server=${_PLANTUML_SERVER_URI} --format=${_OUT_IMAGE_FILE_FORMAT} {} \;

#su-exec $_UID "$@"