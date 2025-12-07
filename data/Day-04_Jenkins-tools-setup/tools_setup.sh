#!/bin/bash
#
# =============================================================================
# Jenkins Agent Tools Setup Script
# =============================================================================
# Purpose:       Installs required developer tools on a Jenkins agent:
#                - Gradle
#                - Maven
#                - OpenJDK 17
#                - Docker CLI & Buildx
#                - Node.js 22 & 20
#                - Yarn
#                After installation, prints all versions for verification.
#
# Author:        @DevOpsInAction
# Version:       1.0.0
# Created:       2025-11-23
# Last Updated:  2025-11-23
# License:       MIT (or your preferred license)
#
# Notes:
#   - All tools are installed under: /home/user/demo/JENKINS_AGENT_DATA_DIR/tools
#   - Designed for Linux (Debian/Ubuntu) based Jenkins agent nodes.
#   - Script is idempotent: repeated runs will overwrite previous installations.
# =============================================================================

set -euo pipefail

echo "🔧 Starting Jenkins Agent Tools Setup..."

#############################################
# Configuration
#############################################
TOOLS_DIR="/home/user/demo/JENKINS_AGENT_DATA_DIR/tools"

GRADLE_VERSION="7.3.3"
MAVEN_VERSION="3.9.11"
JDK_VERSION="17.0.9_9"
DOCKER_VERSION="28.3.1"
BUILDX_VERSION="v0.29.1"
NODE22_VERSION="22.18.0"
NODE20_VERSION="20.11.0"
YARN_VERSION="1.22.22"

#############################################
# Directory Setup
#############################################
echo "📁 Initializing tools directory at $TOOLS_DIR ..."
echo ""
rm -rf "$TOOLS_DIR"
mkdir -p "$TOOLS_DIR"
cd "$TOOLS_DIR"

#############################################
# Install Docker CLI
#############################################
echo "🐳 Installing Docker CLI $DOCKER_VERSION ..."
wget -q -O docker.tgz "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz"
tar -xzf docker.tgz
rm -f docker.tgz
chmod +x "$TOOLS_DIR/docker/docker"
#echo "✅ Docker installed successfully!"

#############################################
# Install Docker Buildx
#############################################
echo "🔧 Installing Docker Buildx $BUILDX_VERSION ..."
wget -q "https://github.com/docker/buildx/releases/download/${BUILDX_VERSION}/buildx-${BUILDX_VERSION}.linux-amd64" \
     -O "$TOOLS_DIR/docker-buildx"
chmod +x "$TOOLS_DIR/docker-buildx"

#############################################
# Install Gradle
#############################################
echo "📦 Installing Gradle $GRADLE_VERSION ..."
wget -q "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip"
unzip -q "gradle-${GRADLE_VERSION}-bin.zip"
mv "gradle-${GRADLE_VERSION}" "$TOOLS_DIR/gradle"
rm "gradle-${GRADLE_VERSION}-bin.zip"

#############################################
# Install Maven
#############################################
echo "📦 Installing Maven $MAVEN_VERSION ..."
wget -q "https://downloads.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.zip"
unzip -q "apache-maven-${MAVEN_VERSION}-bin.zip"
mv "apache-maven-${MAVEN_VERSION}" "$TOOLS_DIR/maven"
rm "apache-maven-${MAVEN_VERSION}-bin.zip"

#############################################
# Install Java 17 (OpenJDK)
#############################################
echo "📦 Installing OpenJDK 17 ..."
wget -q "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-${JDK_VERSION//_/%2B}/OpenJDK17U-jdk_x64_linux_hotspot_${JDK_VERSION}.tar.gz"
tar -xzf "OpenJDK17U-jdk_x64_linux_hotspot_${JDK_VERSION}.tar.gz"
mv "jdk-${JDK_VERSION//_/+}" "$TOOLS_DIR/java"
rm "OpenJDK17U-jdk_x64_linux_hotspot_${JDK_VERSION}.tar.gz"


#############################################
# Install Node.js 22
#############################################
echo "📦 Installing Node.js $NODE22_VERSION ..."
cd "$TOOLS_DIR"
mkdir -p node22 && cd node22
wget -q "https://nodejs.org/dist/v${NODE22_VERSION}/node-v${NODE22_VERSION}-linux-x64.tar.xz"
tar -xf "node-v${NODE22_VERSION}-linux-x64.tar.xz" --strip-components=1
rm "node-v${NODE22_VERSION}-linux-x64.tar.xz"

#############################################
# Install Node.js 20
#############################################
echo "📦 Installing Node.js $NODE20_VERSION ..."
cd "$TOOLS_DIR"
wget -q "https://nodejs.org/dist/v${NODE20_VERSION}/node-v${NODE20_VERSION}-linux-x64.tar.xz"
tar -xf "node-v${NODE20_VERSION}-linux-x64.tar.xz"
mv "node-v${NODE20_VERSION}-linux-x64" node20
rm "node-v${NODE20_VERSION}-linux-x64.tar.xz"

#############################################
# Install Yarn
#############################################
echo "📦 Installing Yarn $YARN_VERSION ..."
cd "$TOOLS_DIR"
wget -q "https://github.com/yarnpkg/yarn/releases/download/v${YARN_VERSION}/yarn-v${YARN_VERSION}.tar.gz"
tar -xzf "yarn-v${YARN_VERSION}.tar.gz"
mv "yarn-v${YARN_VERSION}" yarn
rm "yarn-v${YARN_VERSION}.tar.gz"

#############################################
# Environment Setup
#############################################
echo "🔧 Setting environment variables ..."
export JAVA_HOME="$TOOLS_DIR/java"
export PATH="$JAVA_HOME/bin:$TOOLS_DIR/maven/bin:$TOOLS_DIR/gradle/bin:$TOOLS_DIR/docker:$TOOLS_DIR/yarn/bin:$PATH"


#############################################
# Print Installed Versions
#############################################
echo ""
echo "========================================="
echo "🚀 Installed Tools Versions"
echo "========================================="

echo -n "🔸 Java:        " && java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}'
echo -n "🔸 Maven:       " && mvn -version 2>&1 | grep "Apache Maven" | awk '{print $3}'
echo -n "🔸 Gradle:      " && "$TOOLS_DIR/gradle/bin/gradle" -v 2>/dev/null | grep "Gradle " | awk '{print $2}'
echo -n "🔸 Docker CLI:  " && "$TOOLS_DIR/docker/docker" --version | awk '{print $3}'
echo -n "🔸 Buildx:      " && "$TOOLS_DIR/docker-buildx" version | head -n1 | awk '{print $2}'
echo -n "🔸 Node.js 22:  " && "$TOOLS_DIR/node22/bin/node" -v
echo -n "🔸 Node.js 20:  " && "$TOOLS_DIR/node20/bin/node" -v
echo -n "🔸 Yarn:        " && "$TOOLS_DIR/yarn/bin/yarn" -v

echo "========================================="
echo "🎉 All tools installed and verified!"
echo "========================================="
