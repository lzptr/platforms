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
		&& sudo apt-get -y install -y curl build-essential libncurses5 cmake automake libtool \
		&& sudo apt-get -y install pkg-config libusb-1.0-0-dev libhidapi-dev \

TOOLCHAIN_DIR="/opt/toolchain"
GCC_PATH="10.3-2021.10"
GCC_ARM="gcc-arm-none-eabi"
GCC_VERSION="10.3-2021.10"
GCC_PLATFORM="x86_64-linux"
OPENOCD="openocd"

echo -e "${GREEN}Cleaning up old environment...${NC}"
rm -rf ${TOOLCHAIN_DIR}/${GCC_ARM}-${GCC_VERSION}
rm -rf ${TOOLCHAIN_DIR}/${OPENOCD}


echo -e "${GREEN}Getting GNU Arm Embedded Toolchain...${NC}"
sudo mkdir -p ${TOOLCHAIN_DIR}
sudo chown -R $USER:$USER ${TOOLCHAIN_DIR}

(cd /tmp \
		&& wget --tries 4 --no-check-certificate -c https://developer.arm.com/-/media/Files/downloads/gnu-rm/${GCC_PATH}/${GCC_ARM}-${GCC_VERSION}-${GCC_PLATFORM}.tar.bz2 -O ${GCC_VERSION}.tar.bz2 \
		&& tar xf ${GCC_VERSION}.tar.bz2 -C ${TOOLCHAIN_DIR})
exit_code=$?
if [[ $exit_code -ne 0 ]]; then
    echo -e "${RED}ERROR: Install of ${GCC_VERSION} failed. Aborting installation.${NC}" && exit 1
fi

echo -e "${GREEN}Building openocd...${NC}"
(cd ${TOOLCHAIN_DIR} \
	&& git clone git://git.code.sf.net/p/openocd/code ${OPENOCD} \
	&& cd ${OPENOCD}/ \
	&& ./bootstrap \
	&& ./configure --prefix=/usr --enable-maintainer-mode --enable-stlink --enable-ti-icdi --enable-xds110 --enable-cmsis-dap --enable-jlink --enable-armjtagew --enable-ftdi --enable-ft232r\
	&& make)
exit_code=$?
if [[ $exit_code -ne 0 ]]; then
    echo -e "${RED}ERROR: Building of ${OPENOCD} failed. Aborting installation.${NC}" && exit 1
fi

# Clean up
sudo apt-get autoremove -y \
		&& sudo apt-get clean -y
rm /tmp/${GCC_VERSION}.tar.bz2