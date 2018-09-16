set(TARGET_OPENAL openal)
set(URL_OPENAL http://kcat.strangesoft.net/openal-releases/openal-soft-1.19.0.tar.bz2)
set(URL_MD5_OPENAL 1f59accf1a187384e155e82663aa3f9a)
set(COMMON_CMAKE_ARGS_OPENAL -DALSOFT_UTILS=OFF -DALSOFT_EXAMPLES=OFF -DALSOFT_TESTS=OFF -DALSOFT_CONFIG=OFF)

if(MSVC)
	set(LIBNAME_OPENAL OpenAL32)
	set(LIBFILE_OPENAL_NOEXT ${EP_BASE}/Build/project_${TARGET_OPENAL}/${CONFIGURATION}/${LIBNAME_OPENAL})

	ExternalProject_Add(project_${TARGET_OPENAL}
		URL ${URL_OPENAL}
		URL_MD5 ${URL_MD5_OPENAL}
		CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CONFIGURATION} ${COMMON_CMAKE_ARGS_OPENAL} -DALSOFT_INSTALL=OFF
		BUILD_IN_SOURCE 0
		INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_if_different ${LIBFILE_OPENAL_NOEXT}.dll ${BINDIR}/
			COMMAND ${CMAKE_COMMAND} -E copy_if_different ${LIBFILE_OPENAL_NOEXT}.lib ${LIBDIR}/
			COMMAND ${CMAKE_COMMAND} -E copy_directory ${EP_BASE}/Source/project_${TARGET_OPENAL}/include/AL ${INCDIR}/AL
	)
elseif(APPLE)
	set(FRAMEWORK_DIR_OPENAL ${DESTINATION_PATH}/${TARGET_OPENAL}.framework)
	set(DYLIBNAME_OPENAL libopenal.1.19.0.dylib)

	ExternalProject_Add(project_${TARGET_OPENAL}
		URL ${URL_OPENAL}
		URL_MD5 ${URL_MD5_OPENAL}
		CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} ${COMMON_CMAKE_ARGS_OPENAL} -DALSOFT_INSTALL=OFF
		BUILD_COMMAND ${PARALLEL_MAKE}
		BUILD_IN_SOURCE 0
		INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory ${FRAMEWORK_DIR_OPENAL}/Versions/A
			COMMAND ${CMAKE_COMMAND} -E create_symlink A ${FRAMEWORK_DIR_OPENAL}/Versions/Current
			COMMAND ${CMAKE_COMMAND} -E copy_if_different ${DYLIBNAME_OPENAL} ${FRAMEWORK_DIR_OPENAL}/Versions/A/
			COMMAND ${CMAKE_COMMAND} -E create_symlink Versions/Current/${DYLIBNAME_OPENAL} ${FRAMEWORK_DIR_OPENAL}/${TARGET_OPENAL}
			COMMAND install_name_tool -id "@rpath/${TARGET_OPENAL}.framework/${TARGET_OPENAL}" ${FRAMEWORK_DIR_OPENAL}/${TARGET_OPENAL}
			COMMAND ${CMAKE_COMMAND} -E make_directory ${FRAMEWORK_DIR_OPENAL}/Versions/A/Headers/
			COMMAND ${CMAKE_COMMAND} -E copy_directory ${EP_BASE}/Source/project_${TARGET_OPENAL}/include/AL ${FRAMEWORK_DIR_OPENAL}/Versions/A/Headers
			COMMAND ${CMAKE_COMMAND} -E create_symlink Versions/Current/Headers ${FRAMEWORK_DIR_OPENAL}/Headers
	)
else()
	ExternalProject_Add(project_${TARGET_OPENAL}
		URL ${URL_OPENAL}
		URL_MD5 ${URL_MD5_OPENAL}
		CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} ${COMMON_CMAKE_ARGS_OPENAL} -DCMAKE_INSTALL_PREFIX=${DESTINATION_PATH}
		BUILD_COMMAND ${PARALLEL_MAKE}
		BUILD_IN_SOURCE 0
		INSTALL_COMMAND make install
	)
endif()
