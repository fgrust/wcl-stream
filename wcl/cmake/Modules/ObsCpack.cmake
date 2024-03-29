
if(APPLE AND NOT CPACK_GENERATOR)
	set(CPACK_GENERATOR "Bundle")
elseif(WIN32 AND NOT CPACK_GENERATOR)
	set(CPACK_GENERATOR "WIX" "ZIP")
endif()

set(CPACK_PACKAGE_NAME "WCL")
set(CPACK_PACKAGE_VENDOR "wcl.com")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "WCL - Virtual Camera for livestreams for Worldcast Live")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/UI/data/license/gplv2.txt")

set(CPACK_PACKAGE_VERSION_MAJOR "0")
set(CPACK_PACKAGE_VERSION_MINOR "0")
set(CPACK_PACKAGE_VERSION_PATCH "1")
set(CPACK_PACKAGE_VERSION "${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH}")

if(NOT DEFINED OBS_VERSION_OVERRIDE)
	if(EXISTS "${CMAKE_SOURCE_DIR}/.git")
		execute_process(COMMAND git describe --always --tags --dirty=-modified
			OUTPUT_VARIABLE OBS_VERSION
			WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
			OUTPUT_STRIP_TRAILING_WHITESPACE)
	else()
		set(OBS_VERSION "${CPACK_PACKAGE_VERSION}")
	endif()
else()
	set(OBS_VERSION "${OBS_VERSION_OVERRIDE}")
endif()

MESSAGE(STATUS "OBS_VERSION: ${OBS_VERSION}")

if(INSTALLER_RUN)
	set(CPACK_PACKAGE_EXECUTABLES
		"wcl32" "WCL Virtual Camera (32bit)"
		"wcl64" "WCL Virtual Camera (64bit)")
	set(CPACK_CREATE_DESKTOP_LINKS
		"wcl32"
		"wcl64")
else()
	if(WIN32)
		if(CMAKE_SIZEOF_VOID_P EQUAL 8)
			set(_output_suffix "64")
		else()
			set(_output_suffix "32")
		endif()
	else()
		set(_output_suffix "")
	endif()

	set(CPACK_PACKAGE_EXECUTABLES "wcl${_output_suffix}" "WCL Virtual Camera")
	set(CPACK_CREATE_DESKTOP_LINKS "wcl${_output_suffix}")
endif()

set(CPACK_BUNDLE_NAME "OBS")
set(CPACK_BUNDLE_PLIST "${CMAKE_SOURCE_DIR}/cmake/osxbundle/Info.plist")
set(CPACK_BUNDLE_ICON "${CMAKE_SOURCE_DIR}/cmake/osxbundle/obs.icns")
set(CPACK_BUNDLE_STARTUP_COMMAND "${CMAKE_SOURCE_DIR}/cmake/osxbundle/obslaunch.sh")

set(CPACK_WIX_TEMPLATE "${CMAKE_SOURCE_DIR}/cmake/Modules/WIX.template.in")

if(INSTALLER_RUN)
	set(CPACK_PACKAGE_INSTALL_REGISTRY_KEY "WCLVirtualCamera")
	set(CPACK_WIX_UPGRADE_GUID "1f59ff79-2a3c-43c1-b2b2-033a5e6342eb")
	set(CPACK_WIX_PRODUCT_GUID "0c7bec2a-4f07-41b2-9dff-d64b09c9c384")
	set(CPACK_PACKAGE_FILE_NAME "wcl-virtual-camera-${OBS_VERSION}")
elseif(CMAKE_SIZEOF_VOID_P EQUAL 8)
	if(WIN32)
		set(CPACK_PACKAGE_NAME "WCL Virtual Camera (64bit)")
	endif()
	set(CPACK_PACKAGE_INSTALL_REGISTRY_KEY "WCLVirtualCamera64")
	set(CPACK_WIX_UPGRADE_GUID "44c72510-2e8e-489c-8bc0-2011a9631b0b")
	set(CPACK_WIX_PRODUCT_GUID "ca5bf4fe-7b38-4003-9455-de249d03caac")
	set(CPACK_PACKAGE_FILE_NAME "wcl-virtual-camera-x64-${OBS_VERSION}")
else()
	if(WIN32)
		set(CPACK_PACKAGE_NAME "WCL Virtual Camera (32bit)")
	endif()
	set(CPACK_PACKAGE_INSTALL_REGISTRY_KEY "WCLVirtualCamera32")
	set(CPACK_WIX_UPGRADE_GUID "a26acea4-6190-4470-9fb9-f6d32f3ba030")
	set(CPACK_WIX_PRODUCT_GUID "8e24982d-b0ab-4f66-9c90-f726f3b64682")
	set(CPACK_PACKAGE_FILE_NAME "wcl-virtual-camera-x86-${OBS_VERSION}")
endif()

set(CPACK_PACKAGE_INSTALL_DIRECTORY "${CPACK_PACKAGE_NAME}")

if(UNIX_STRUCTURE)
	set(CPACK_SET_DESTDIR TRUE)
endif()

include(CPack)
