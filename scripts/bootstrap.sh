#!/bin/bash

if [[ $EUID -eq 0 ]]; then
    echo "Do not run this as the root user"
    exit 1
fi

RED='\033[0;31m'
GREEN='\033[0;32m'        
NC='\033[0m' # No Color

echo -e "${GREEN}Installing toolchain dependencies...${NC}"

# apt-get update and install dependencies
sudo apt-get update -y \
        && sudo apt-get -y install -y curl build-essential libncurses5 cmake automakelibtool \
        && sudo apt-get -y install pkg-config libusb-1.0-0-dev libhidapi-dev \

TOOLCHAIN_DIR="/opt/toolchain"
GCC_PATH="10.3-2021.10"
GCC_ARM="gcc-arm-none-eabi"
GCC_VERSION="10.3-2021.10"
GCC_PLATFORM="x86_64-linux"
OPENOCD="openocd"

echo "Cleaning up old environment ..."
sudo rm -rf /opt/toolchain

echo -e "${GREEN}Installing GNU Arm Embedded Toolchain...${NC}"
sudo mkdir -p ${TOOLCHAIN_DIR}
sudo chown -R $USER:$USER /opt/${TOOLCHAIN_DIR}

cd /tmp \ 
	&& wget --tries 4 --no-check-certificate -c https://developer.arm.com/-/media/Files/downloads/gnu-rm/${GCC_PATH}/${GCC_ARM}-${GCC_VERSION}-${GCC_PLATFORM}.tar.bz2 -O ${GCC_VERSION}.tar.bz2 \
        || {echo "${RED}ERROR: Download of ${GCC_VERSION} failed. Aborting installation.${NC}" && exit 1}
	&& tar xf ${GCC_VERSION}.tar.bz2 -C ${TOOLCHAIN_DIR} \
	&& rm ${GCC_VERSION}.tar.bz2

echo -e "${GREEN}Installing openocd...${NC}"
    cd ${TOOLCHAIN_DIR} \
        && git clone git://git.code.sf.net/p/openocd/code ${OPENOCD} || {echo "${RED}ERROR: Download of ${OPENOCD} failed. Aborting installation.${NC}" && exit 1}\
        && cd ${OPENOCD}/ \
        && ./bootstrap \
        && ./configure --prefix=/usr --enable-maintainer-mode --enable-stlink --enable-ti-icdi --enable-xds110 --enable-cmsis-dap --enable-jlink --enable-armjtagew --enable-ftdi --enable-ft232r\
        && make >/dev/null || make \
        && make install

# Clean up
sudo apt-get autoremove -y \
		&& sudo apt-get clean -y