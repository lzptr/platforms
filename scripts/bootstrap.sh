#!/bin/bash

if [[ $EUID -eq 0 ]]; then
	echo "Do not run this as the root user"
	exit 1
fi

RED='\033[0;31m'
GREEN='\033[0;32m'        
NC='\033[0m' # No Color

display_help() {
    echo "Usage: $0  [--clean] [--gcc] [--jlink] [--openocd] [--orbuculum]" >&2
    echo
	echo "   default           When no opions are provided, the script checks which tools are installed and only installs the missing ones "
    echo "   --clean           Clean /opt/toolchain folder before installing. Use this to reinstall everything "
    echo "   --gcc             Install only gcc (can be combined with other options) "
    echo "   --jlink           Install only jlink (can be combined with other options) "
    echo "   --openocd         Install only openocd (can be combined with other options) "
    echo "   --orbuculum       Install only orbuculum (can be combined with other options) "
    echo
    exit 1
}

# TODO: Move to functions
VALID_ARGS=$(getopt -o '' --long clean,gcc,jlink,openocd,orbuculum  -- "$@")
if [[ $? -ne 0 ]]; then
	display_help
    exit 1;
fi

eval set -- "$VALID_ARGS"
CLEAN=false
GCC=false
JLINK=false
OPENOCD=false
ORBUCULUM=false
while [ "$#" -gt 0 ]; do
  (( optionsPassed++ ))
  case "$1" in
        --clean )
            CLEAN=true
			shift
            ;;
        --gcc )
            GCC=true
			shift
            ;;
		--jlink )
            JLINK=true
			shift
            ;;
		--openocd )
            OPENOCD=true
			shift
            ;;
		--orbuculum )
            ORBUCULUM=true
			shift;
            ;;
		-- )
			shift; 
			break 
			;;
        * )
            display_help
			shift
			break
            ;;
    esac
done

# Check if script was called with no options
if [[ $optionsPassed -le 1 ]];then
  	
	# Default case. Install all tools
	GCC=true
	JLINK=true
	OPENOCD=true
	ORBUCULUM=true
fi

TOOLCHAIN_DIR="/opt/toolchain"
GCC_PATH="10.3-2021.10"
GCC_ARM="gcc-arm-none-eabi"
GCC_VERSION="10.3-2021.10"
GCC_PLATFORM="x86_64-linux"
OPENOCD_PATH="openocd"
SEGGER_PATH="JLink_Linux_V758e_x86_64"
ORBUCULUM_PATH="orbuculum"

# TODO: Move to functions
if $CLEAN; then

	echo -e "${GREEN}Cleaning up old environment...${NC}"
	rm -rf ${TOOLCHAIN_DIR}/${GCC_ARM:?}-${GCC_VERSION:?}
	rm -rf ${TOOLCHAIN_DIR}/${OPENOCD_PATH:?}
	rm -rf ${TOOLCHAIN_DIR}/${SEGGER_PATH:?}
	rm -rf ${TOOLCHAIN_DIR}/${ORBUCULUM_PATH:?}
	
	# Reinstall all tools after clean
	GCC=true
	JLINK=true
	OPENOCD=true
	ORBUCULUM=true
fi

echo -e "${GREEN}Installing toolchain dependencies...${NC}"
# apt-get update and install dependencies
sudo apt-get update -y \
		&& sudo apt-get -y install -y curl build-essential libncurses5 cmake automake libtool \
		&& sudo apt-get -y install pkg-config libusb-1.0-0-dev libhidapi-dev \
		&& sudo apt-get -y install binutils-dev libelf-dev libncurses5-dev libftdi-dev libftdi1 \

# Check installed tools
if [ -d "${TOOLCHAIN_DIR}/${GCC_ARM:?}-${GCC_VERSION:?}" ] && $GCC ; then
	echo "Found gcc in ${TOOLCHAIN_DIR}/${GCC_ARM:?}-${GCC_VERSION:?}. Skipping installation."
	GCC=false
fi
if [ -d "${TOOLCHAIN_DIR}/${OPENOCD_PATH:?}" ] && $OPENOCD ; then
	echo "Found openocd in ${TOOLCHAIN_DIR}/${OPENOCD_PATH:?}. Skipping installation."
	OPENOCD=false
fi
if [ -d "${TOOLCHAIN_DIR}/${SEGGER_PATH:?}" ] && $JLINK ; then
	echo "Found jlink in ${TOOLCHAIN_DIR}/${SEGGER_PATH:?}. Skipping installation."
	JLINK=false
fi
if [ -d "${TOOLCHAIN_DIR}/${ORBUCULUM_PATH:?}" ] && $ORBUCULUM ; then
	echo "Found orbuculum in ${TOOLCHAIN_DIR}/${ORBUCULUM_PATH:?}. Skipping installation."
	ORBUCULUM=false
fi

# TODO: Move to functions
if $GCC; then

	echo -e "${GREEN}Getting GNU Arm Embedded Toolchain...${NC}"
	sudo mkdir -p ${TOOLCHAIN_DIR}
	sudo chown -R "$USER:$USER" ${TOOLCHAIN_DIR}

	(cd /tmp \
			&& wget --tries 4 --no-check-certificate -c https://developer.arm.com/-/media/Files/downloads/gnu-rm/${GCC_PATH}/${GCC_ARM}-${GCC_VERSION}-${GCC_PLATFORM}.tar.bz2 -O ${GCC_VERSION}.tar.bz2 \
			&& tar xf ${GCC_VERSION}.tar.bz2 -C ${TOOLCHAIN_DIR})
	exit_code=$?
	if [[ $exit_code -ne 0 ]]; then
		rm -rf ${TOOLCHAIN_DIR}/${GCC_ARM:?}-${GCC_VERSION:?}
		echo -e "${RED}ERROR: Install of ${GCC_VERSION} failed. Aborting installation.${NC}" && exit 1
	fi

	# Install gcc on system
	sudo ln -sf ${GCC_ARM:?}-${GCC_VERSION:?}/bin/* /usr/local/bin
fi

# TODO: Move to functions
if $OPENOCD; then

	echo -e "${GREEN}Building openocd...${NC}"
	(cd ${TOOLCHAIN_DIR} \
		&& git clone git://git.code.sf.net/p/openocd/code ${OPENOCD_PATH} \
		&& cd ${OPENOCD_PATH}/ \
		&& ./bootstrap \
		&& ./configure --prefix=/usr --enable-maintainer-mode --enable-stlink --enable-ti-icdi --enable-xds110 --enable-cmsis-dap --enable-jlink --enable-armjtagew --enable-ftdi --enable-ft232r\
		&& make )
	exit_code=$?
	if [[ $exit_code -ne 0 ]]; then
		rm -rf ${TOOLCHAIN_DIR}/${OPENOCD_PATH:?}
		echo -e "${RED}ERROR: Building of ${OPENOCD_PATH} failed. Aborting installation.${NC}" && exit 1
	fi

	# Add udev rules for OPENOCD_PATH
	sudo cp ${TOOLCHAIN_DIR}/${OPENOCD_PATH}/contrib/60-OPENOCD_PATH.rules /etc/udev/rules.d/

	# There seems to be an issue with the udev on wsl2. Just restart and reload.
	if grep -q icrosoft /proc/version; then
		# Add windows WSL specific options here
		# apply wsl2 fix
		sudo service udev restart
		sudo udevadm control --reload
	fi
fi

# TODO: Move to functions
if $JLINK; then
	echo -e "${GREEN}Getting Segger_PATH JLink...${NC}"
	(cd /tmp \
			&& wget --tries 4 --no-check-certificate --post-data="accept_license_agreement=accepted&submit=Download&nbspsoftware" -c https://www.segger.com/downloads/jlink/${SEGGER_PATH}.tgz -O ${SEGGER_PATH}.tgz \
			&& tar xvzf ${SEGGER_PATH}.tgz -C ${TOOLCHAIN_DIR} )
	exit_code=$?
	if [[ $exit_code -ne 0 ]]; then
		rm -rf ${TOOLCHAIN_DIR}/${SEGGER_PATH:?}
		echo -e "${RED}ERROR: Install of ${SEGGER_PATH} failed. Aborting installation.${NC}" && exit 1
	fi

	sudo cp ${TOOLCHAIN_DIR}/${SEGGER_PATH}/99-jlink.rules /etc/udev/rules.d/99-jlink.rules

	# There seems to be an issue with the udev on wsl2. Just restart and reload.
	if grep -q icrosoft /proc/version; then
		# Add windows WSL specific options here
		# apply wsl2 fix
		sudo service udev restart
		sudo udevadm control --reload
	fi
fi 


# TODO: Move to functions
if $ORBUCULUM; then
	echo -e "${GREEN}Building orbuculum_PATH...${NC}"
	(cd ${TOOLCHAIN_DIR} \
		&& git clone https://github.com/orbcode/orbuculum.git ${ORBUCULUM_PATH} --recursive \
		&& cd ${ORBUCULUM_PATH}/ \
		&& git checkout Devel \
		&& make )
	exit_code=$?
	if [[ $exit_code -ne 0 ]]; then
		rm -rf ${TOOLCHAIN_DIR}/${ORBUCULUM_PATH:?}
		echo -e "${RED}ERROR: Building of ${ORBUCULUM_PATH} failed. Aborting installation.${NC}" && exit 1
	fi

	# Install orbuculum on system
	sudo ln -sf ${TOOLCHAIN_DIR}/${ORBUCULUM_PATH}/ofiles/orb* /usr/local/bin
fi

# Clean up
sudo apt-get autoremove -y \
		&& sudo apt-get clean -y
rm /tmp/${GCC_VERSION}.tar.bz2
rm /tmp/${SEGGER_PATH}.tgz