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
SEGGER="JLink_Linux_V758e_x86_64"

echo -e "${GREEN}Cleaning up old environment...${NC}"
rm -rf ${TOOLCHAIN_DIR}/${GCC_ARM}-${GCC_VERSION}
rm -rf ${TOOLCHAIN_DIR}/${OPENOCD}
rm -rf ${TOOLCHAIN_DIR}/${SEGGER}

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
	&& make )
exit_code=$?
if [[ $exit_code -ne 0 ]]; then
    echo -e "${RED}ERROR: Building of ${OPENOCD} failed. Aborting installation.${NC}" && exit 1
fi

# Add udev rules for openocd
sudo cp ${TOOLCHAIN_DIR}/${OPENOCD}/contrib/60-openocd.rules /etc/udev/rules.d/

echo -e "${GREEN}Getting Segger JLink...${NC}"
(cd /tmp \
		&& wget --tries 4 --no-check-certificate --post-data="accept_license_agreement=accepted&submit=Download&nbspsoftware" -c https://www.segger.com/downloads/jlink/${SEGGER}.tgz -O ${SEGGER}.tgz \
		&& tar xvzf ${SEGGER}.tgz -C ${TOOLCHAIN_DIR} )
if [[ $exit_code -ne 0 ]]; then
    echo -e "${RED}ERROR: Install of ${SEGGER} failed. Aborting installation.${NC}" && exit 1
fi

sudo cp ${TOOLCHAIN_DIR}/${SEGGER}/99-jlink.rules /etc/udev/rules.d/99-jlink.rules

# There seems to be an issue with the udev on wsl2. Just restart and reload.
if grep -q icrosoft /proc/version; then
    # Add windows WSL specific options here
	# apply wsl2 fix
	sudo service udev restart
	sudo udevadm control --reload
fi

# Clean up
sudo apt-get autoremove -y \
		&& sudo apt-get clean -y
rm /tmp/${GCC_VERSION}.tar.bz2
rm /tmp/${SEGGER}.tgz