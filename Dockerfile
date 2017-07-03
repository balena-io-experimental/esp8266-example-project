# Node base-image for the Raspberry Pi 3
# See more about resin base images here: http://docs.resin.io/runtime/resin-base-images/
FROM resin/raspberrypi3-node:7-slim-20170623

# Disable systemd init system
ENV INITSYSTEM off

# Set our working directory
WORKDIR /usr/src/app

# Use apt-get to install dependencies,
RUN apt-get update && apt-get install -yq --no-install-recommends \
    bluez \
    bluez-firmware \
    curl \
    jq \
    nmap && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Get the edge-node-manager binary, rename and make executable
RUN TAG=$(curl https://api.github.com/repos/resin-io/edge-node-manager/releases/latest -s | jq .tag_name -r) && \
    echo "Pulling $TAG of the edge-node-manager binary" && \
    curl -k -O https://resin-production-downloads.s3.amazonaws.com/edge-node-manager/$TAG/edge-node-manager-$TAG-linux-arm && \
    mv edge-node-manager-$TAG-linux-arm edge-node-manager && \
    chmod +x edge-node-manager

# Copies the package.json first for better cache on later pushes
COPY package.json package.json

# This install npm dependencies on the resin.io build server,
# making sure to clean up the artifacts it creates in order to reduce the image size.
RUN JOBS=MAX npm install --production --unsafe-perm && npm cache clean && rm -rf /tmp/*

# Copy all files in to the working directory
COPY . ./

# Run the start script
CMD ["bash", "start.sh"]
