#!/bin/bash

echo "Checking Root Privileges"
if [ "$(id -u)" -ne 0 ]; then
	echo "Run script with administrator privileges"
	exit 1
fi

TOOLCHAIN_DIR="/opt/toolchain"
GCC_ONLINE_PATH="10.3-2021.10"
GCC_ARM="gcc-arm-none-eabi"
GCC_VERSION="10.3-2021.10"
GCC_PLATFORM="x86_64-linux"
JLINK_VERSION="JLink_Linux_V758e_x86_64"
AM243_SDK_VERSION="08_02_00_31"
AM243_SYSCFG_VERSION="1.12.1" 
AM243_SYSCFG_BUILD_VERSION="2446"
AM243_PRU_COMPILER_VERSION="2.3.3"
AM243_PRU_SUPPORT_VERSION="pru-software-support-package"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

GCC_INSTALL_PATH="${TOOLCHAIN_DIR}/${GCC_ARM:?}-${GCC_VERSION:?}"
JLINK_INSTALL_PATH="${TOOLCHAIN_DIR}/${JLINK_VERSION}"
OPENOCD_INSTALL_PATH="${TOOLCHAIN_DIR}/openocd"
ORBUCULUM_INSTALL_PATH="${TOOLCHAIN_DIR}/orbuculum"
AM243_SDK_INSTALL_PATH="${TOOLCHAIN_DIR}/ti/mcu_plus_sdk_am243x_${AM243_SDK_VERSION}"
AM243_SYSCFG_INSTALL_PATH="${TOOLCHAIN_DIR}/ti/sysconfig-${AM243_SYSCFG_VERSION}_${AM243_SYSCFG_BUILD_VERSION}"
AM243_PRU_COMPILER_INSTALL_PATH="${TOOLCHAIN_DIR}/ti/ti-cgt-pru_${AM243_PRU_COMPILER_VERSION}"
AM243_PRU_SUPPORT_INSTALL_PATH="${TOOLCHAIN_DIR}/ti/${AM243_PRU_SUPPORT_VERSION}"

# Download Links
GCC_DOWNLOAD_LINK="https://developer.arm.com/-/media/Files/downloads/gnu-rm/${GCC_ONLINE_PATH}/${GCC_ARM}-${GCC_VERSION}-${GCC_PLATFORM}.tar.bz2"
JLINK_DOWNLOAD_LINK="https://www.segger.com/downloads/jlink/${JLINK_VERSION}.tgz"
OPENOCD_DOWNLOAD_LINK="git://git.code.sf.net/p/openocd/code"
ORBUCULUM_DOWNLOAD_LINK="https://github.com/orbcode/orbuculum.git"
AM243_SDK_DOWNLOAD_LINK="https://software-dl.ti.com/mcu-plus-sdk/esd/AM243X/${AM243_SDK_VERSION}/exports/mcu_plus_sdk_am243x_${AM243_SDK_VERSION}-linux-x64-installer.run"
AM243_SYSCFG_DOWNLOAD_LINK="https://dr-download.ti.com/software-development/ide-configuration-compiler-or-debugger/MD-nsUM6f7Vvb/${AM243_SYSCFG_VERSION}.${AM243_SYSCFG_BUILD_VERSION}/sysconfig-${AM243_SYSCFG_VERSION}_${AM243_SYSCFG_BUILD_VERSION}-setup.run"
AM243_PRU_COMPILER_DONWLOAD_LINK="https://software-dl.ti.com/codegen/esd/cgt_public_sw/PRU/${AM243_PRU_COMPILER_VERSION}/ti_cgt_pru_${AM243_PRU_COMPILER_VERSION}_linux_installer_x86.bin"
AM243_PRU_SUPPORT_DOWNLOAD_LINK="https://git.ti.com/cgit/pru-software-support-package/pru-software-support-package/"

# Global options
GCC=false
JLINK=false
OPENOCD=false
ORBUCULUM=false
AM243=false

display_help() {
	echo "Usage: $0  [--clean] [--gcc] [--jlink] [--openocd] [--orbuculum]" >&2
	echo
	echo "   default           When no opions are provided, the script checks which tools are installed and only installs the missing ones "
	echo "   --clean           Cleans /opt/toolchain folder. "
	echo "   --gcc             Install only gcc (can be combined with other options) "
	echo "   --jlink           Install only jlink (can be combined with other options) "
	echo "   --openocd         Install only openocd (can be combined with other options) "
	echo "   --orbuculum       Install only orbuculum (can be combined with other options) "
	echo "   --am243       	   Install only am243 packages (can be combined with other options) "
	echo
	exit 1
}

parse_arguments() {
	VALID_ARGS=$(getopt -o '' --long clean,gcc,jlink,openocd,orbuculum,am243 -- "$@")
	if [[ $? -ne 0 ]]; then
		display_help
		exit 1
	fi

	eval set -- "$VALID_ARGS"
	while [ "$#" -gt 0 ]; do
		((optionsPassed++))
		case "$1" in
		--clean)
			clean
			shift
			;;
		--gcc)
			GCC=true
			shift
			;;
		--jlink)
			JLINK=true
			shift
			;;
		--openocd)
			OPENOCD=true
			shift
			;;
		--orbuculum)
			ORBUCULUM=true
			shift
			;;
		--am243)
			AM243=true
			shift
			;;
		--)
			shift
			break
			;;
		*)
			display_help
			shift
			break
			;;
		esac
	done

	# Check if script was called with no options
	if [[ $optionsPassed -le 1 ]]; then

		# Default case. Install all tools
		GCC=true
		JLINK=true
		OPENOCD=true
		ORBUCULUM=true
		AM243=true
	fi
}

clean() {

	echo -e "${GREEN}Cleaning up old environment...${NC}"
	rm -rf "${GCC_INSTALL_PATH:?}"
	rm -rf "${JLINK_INSTALL_PATH:?}"
	rm -rf "${ORBUCULUM_INSTALL_PATH:?}"
	rm -rf "${AM243_SDK_INSTALL_PATH:?}"
	rm -rf "${AM243_SYSCFG_INSTALL_PATH:?}"
	rm -rf "${AM243_PRU_COMPILER_INSTALL_PATH:?}"
	rm -rf "${AM243_PRU_SUPPORT_INSTALL_PATH:?}"
	
	if [ -d "${OPENOCD_INSTALL_PATH:?}" ]; then
		cd "${OPENOCD_INSTALL_PATH:?}"
		make uninstall
		rm -rf "${OPENOCD_INSTALL_PATH:?}"
	fi

	exit 1
}

check_tools() {

	# Check installed tools
	if [ -d "${GCC_INSTALL_PATH:?}" ] && $GCC; then
		echo "Found gcc in ${GCC_INSTALL_PATH:?}. Skipping installation."
		GCC=false
	fi

	if [ -d "${JLINK_INSTALL_PATH:?}" ] && $JLINK; then
		echo "Found jlink in ${JLINK_INSTALL_PATH:?}. Skipping installation."
		JLINK=false
	fi

	if [ -d "${OPENOCD_INSTALL_PATH:?}" ] && $OPENOCD; then
		echo "Found openocd in ${OPENOCD_INSTALL_PATH:?}. Skipping installation."
		OPENOCD=false
	fi

	if [ -d "${ORBUCULUM_INSTALL_PATH:?}" ] && $ORBUCULUM; then
		echo "Found orbuculum in ${ORBUCULUM_INSTALL_PATH:?}. Skipping installation."
		ORBUCULUM=false
	fi

	if [ -d "${AM243_SDK_INSTALL_PATH:?}" ] &&
		[ -d "${AM243_SYSCFG_INSTALL_PATH:?}" ] &&
		[ -d "${AM243_PRU_COMPILER_INSTALL_PATH:?}" ] && 
		[ -d "${AM243_PRU_SUPPORT_INSTALL_PATH:?}" ] && $AM243; then

		echo "Found am243 packages in " \	
				"${AM243_SDK_INSTALL_PATH:?};" \
				"${AM243_SYSCFG_INSTALL_PATH:?};" \
				"${AM243_PRU_COMPILER_INSTALL_PATH:?};" \
				"${AM243_PRU_SUPPORT_INSTALL_PATH:?}." \
				"Skipping installation."
		AM243=false
	fi
}

install_dependencies() {

	echo -e "${GREEN}Installing toolchain dependencies...${NC}"
	sudo apt-get update -y &&
		sudo apt-get -y install -y build-essential libncurses5 cmake curl automake libtool &&
		sudo apt-get -y install pkg-config libusb-1.0-0-dev libhidapi-dev &&
		sudo apt-get -y install binutils-dev libelf-dev libncurses5-dev libftdi-dev libftdi1

	apt-get autoremove -y && apt-get clean -y
}

install_gcc() {

	echo -e "${GREEN}Getting GNU Arm GCC Toolchain...${NC}"

	(cd /tmp &&
		wget --tries 4 --no-check-certificate -c "${GCC_DOWNLOAD_LINK}" -O ${GCC_VERSION}.tar.bz2 &&
		tar xf ${GCC_VERSION}.tar.bz2 -C ${TOOLCHAIN_DIR})
	exit_code=$?
	if [[ $exit_code -ne 0 ]]; then
		rm -rf "${GCC_INSTALL_PATH:?}"
		echo -e "${RED}ERROR: Install of ${GCC_VERSION} failed. Aborting installation.${NC}" && exit 1
	fi

	# Install arm-gcc on system
	ln -sf "${GCC_INSTALL_PATH:?}"/bin/* /usr/local/bin
	rm /tmp/${GCC_VERSION}.tar.bz2
}

install_jlink() {

	echo -e "${GREEN}Getting JLink...${NC}"

	(cd /tmp &&
		wget --tries 4 --no-check-certificate --post-data="accept_license_agreement=accepted&submit=Download&nbspsoftware" -c "${JLINK_DOWNLOAD_LINK}" -O ${JLINK_VERSION}.tgz &&
		tar xvzf ${JLINK_VERSION}.tgz -C ${TOOLCHAIN_DIR})
	exit_code=$?
	if [[ $exit_code -ne 0 ]]; then
		rm -rf "${JLINK_INSTALL_PATH:?}"
		echo -e "${RED}ERROR: Install of ${JLINK_INSTALL_PATH} failed. Aborting installation.${NC}" && exit 1
	fi

	cp ${JLINK_INSTALL_PATH:?}/99-jlink.rules /etc/udev/rules.d/99-jlink.rules

	# WSL2 udev bug fix
	if grep -q icrosoft /proc/version; then
		service udev restart
		udevadm control --reload
	fi

	rm /tmp/${JLINK_VERSION}.tgz
}

install_openocd() {

	echo -e "${GREEN}Building openocd...${NC}"

	(cd ${TOOLCHAIN_DIR} &&
		git clone ${OPENOCD_DOWNLOAD_LINK} ${OPENOCD_INSTALL_PATH} &&
		cd "${OPENOCD_INSTALL_PATH:?}" &&
		./bootstrap &&
		./configure &&
		make &&
		make install)
	exit_code=$?
	if [[ $exit_code -ne 0 ]]; then
		rm -rf "${OPENOCD_INSTALL_PATH:?}"
		echo -e "${RED}ERROR: Building of ${OPENOCD_INSTALL_PATH} failed. Aborting installation.${NC}" && exit 1
	fi

	# Add udev rules for OPENOCD_PATH
	cp "${OPENOCD_INSTALL_PATH:?}"/contrib/60-openocd.rules /etc/udev/rules.d/

	# WSL2 udev bug fix
	if grep -q icrosoft /proc/version; then
		service udev restart
		udevadm control --reload
	fi
}

install_orbuculum() {

	echo -e "${GREEN}Building orbuculum...${NC}"
	(cd ${TOOLCHAIN_DIR} &&
		git clone ${ORBUCULUM_DOWNLOAD_LINK} ${ORBUCULUM_INSTALL_PATH} --recursive &&
		cd "${ORBUCULUM_INSTALL_PATH:?}" &&
		git checkout Devel &&
		make)
	exit_code=$?
	if [[ $exit_code -ne 0 ]]; then
		rm -rf ${TOOLCHAIN_DIR}/${ORBUCULUM_INSTALL_PATH:?}
		echo -e "${RED}ERROR: Building of ${ORBUCULUM_INSTALL_PATH} failed. Aborting installation.${NC}" && exit 1
	fi

	# Install orbuculum on system
	sudo ln -sf ${TOOLCHAIN_DIR}/${ORBUCULUM_INSTALL_PATH}/ofiles/orb* /usr/local/bin
}

install_am243() {

	echo -e "${GREEN}Installing am243 packages...${NC}"

	# Download and install am243 mcu sdk (needs manual download for latest version)
	if [ $AM243_SDK_VERSION != "08_02_00_31" ]; then
		(cd /tmp \
			&& wget --tries 4 --no-check-certificate -c "${AM243_SDK_DOWNLOAD_LINK}" -O ${AM243_SDK_VERSION}.run \
			&& chmod 744 ${AM243_SDK_VERSION}.run \
			&& ./${AM243_SDK_VERSION}.run --prefix "${TOOLCHAIN_DIR}/ti/" --mode unattended \
			&& rm ${AM243_SDK_VERSION}.run)
		exit_code=$?
		if [[ $exit_code -ne 0 ]]; then
		    rm -rf "${AM243_SDK_INSTALL_PATH:?}"
		    echo -e "${RED}ERROR: Install of ${AM243_SDK_INSTALL_PATH} failed. Aborting installation.${NC}" && exit 1
		fi
	else

		# Download latest version and save it in the tmp folder
		(cd /tmp \
			&& chmod 744 ${AM243_SDK_VERSION}.run \
			&& ./${AM243_SDK_VERSION}.run --prefix "${TOOLCHAIN_DIR}/ti/" --mode unattended )
		exit_code=$?
		if [[ $exit_code -ne 0 ]]; then
			rm -rf "${AM243_SDK_INSTALL_PATH:?}"
			echo -e "${RED}ERROR: Install of ${AM243_SDK_INSTALL_PATH} failed. Aborting installation.${NC}" && exit 1
		fi
	fi

	# Download and install sysconfig tool
	(cd /tmp \
		&& wget --tries 4 --no-check-certificate -c "${AM243_SYSCFG_DOWNLOAD_LINK}" -O ${AM243_SYSCFG_VERSION}.run \
		&& chmod 744 ${AM243_SYSCFG_VERSION}.run \
		&& ./${AM243_SYSCFG_VERSION}.run --prefix "${AM243_SYSCFG_INSTALL_PATH}" --mode unattended \
		&& rm ${AM243_SYSCFG_VERSION}.run)
	exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
		rm -rf "${AM243_SDK_INSTALL_PATH:?}"
        rm -rf "${AM243_SYSCFG_INSTALL_PATH:?}"
        echo -e "${RED}ERROR: Install of ${AM243_SYSCFG_INSTALL_PATH} failed. Aborting installation.${NC}" && exit 1
    fi

	# Download and install pru compiler
	(cd /tmp \
		&& wget --tries 4 --no-check-certificate -c "${AM243_PRU_COMPILER_DONWLOAD_LINK}" -O ${AM243_PRU_COMPILER_VERSION}.bin \
		&& chmod 744 ${AM243_PRU_COMPILER_VERSION}.bin \
		&& ./${AM243_PRU_COMPILER_VERSION}.bin --prefix "${TOOLCHAIN_DIR}/ti/" --mode unattended \
		&& rm ${AM243_PRU_COMPILER_VERSION}.bin)
	exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
		rm -rf "${AM243_SDK_INSTALL_PATH:?}"
        rm -rf "${AM243_SYSCFG_INSTALL_PATH:?}"
        rm -rf "${AM243_PRU_COMPILER_INSTALL_PATH:?}"
        echo -e "${RED}ERROR: Install of ${AM243_PRU_COMPILER_INSTALL_PATH} failed. Aborting installation.${NC}" && exit 1
    fi

	# Download and install pru suport package
	(cd ${TOOLCHAIN_DIR}/ti &&
        git clone ${AM243_PRU_SUPPORT_DOWNLOAD_LINK} ${AM243_PRU_SUPPORT_VERSION})
    exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
		rm -rf "${AM243_SDK_INSTALL_PATH:?}"
        rm -rf "${AM243_SYSCFG_INSTALL_PATH:?}"
        rm -rf "${AM243_PRU_COMPILER_INSTALL_PATH:?}"
        rm -rf "${AM243_PRU_SUPPORT_INSTALL_PATH:?}"
        echo -e "${RED}ERROR: Install of ${AM243_PRU_SUPPORT_INSTALL_PATH} failed. Aborting installation.${NC}" && exit 1
    fi
}

install_packages() {
	install_dependencies

	mkdir -p ${TOOLCHAIN_DIR}

	if $GCC; then
		install_gcc
	fi

	if $JLINK; then
		install_jlink
	fi

	if $OPENOCD; then
		install_openocd
	fi

	if $ORBUCULUM; then
		install_orbuculum
	fi

	if $AM243; then
		install_am243
	fi

	echo -e "${GREEN}Bootstrap completed successfully.${NC}"
}

main() {
	parse_arguments "$@"
	check_tools
	install_packages
}

main "$@"
