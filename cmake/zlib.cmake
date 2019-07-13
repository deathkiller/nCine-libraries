set(TARGET_ZLIB zlib)
set(URL_ZLIB http://downloads.sourceforge.net/project/libpng/zlib/1.2.11/zlib-1.2.11.tar.gz)
set(URL_MD5_ZLIB 1c9f62f0778697a09d36121ead88e08e)
set(LIBNAME_ZLIB zlib)

if(MSVC)
	set(LIBNAME_ZLIB_LIB zlibstatic) # for static linking
	if(MSVC_IDE)
		set(LIBNAME_ZLIB_DLL $<$<NOT:$<CONFIG:Debug>>:zlib>$<$<CONFIG:Debug>:zlibd>)
		set(LIBNAME_ZLIB_LIB $<$<NOT:$<CONFIG:Debug>>:zlibstatic>$<$<CONFIG:Debug>:zlibstaticd>)
	else()
		if(CMAKE_BUILD_TYPE STREQUAL "Debug")
			set(LIBNAME_ZLIB zlibd)
			set(LIBNAME_ZLIB_LIB zlibstaticd)
		endif()
	endif()

	if(MSVC_IDE)
		set(LIBFILE_ZLIB_DLL ${CONFIGURATION}/${LIBNAME_ZLIB_DLL}.dll)
		set(LIBFILE_ZLIB_IMPLIB ${CONFIGURATION}/${LIBNAME_ZLIB_DLL}.lib)
		set(LIBFILE_ZLIB_LIB ${CONFIGURATION}/${LIBNAME_ZLIB_LIB}.lib)
	else()
		set(LIBFILE_ZLIB_DLL ${LIBNAME_ZLIB_DLL}.dll)
		set(LIBFILE_ZLIB_IMPLIB ${LIBNAME_ZLIB_DLL}.lib)
		set(LIBFILE_ZLIB_LIB ${LIBNAME_ZLIB_LIB}.lib)
	endif()

	ExternalProject_Add(project_${TARGET_ZLIB}
		URL ${URL_ZLIB}
		URL_MD5 ${URL_MD5_ZLIB}
		CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CONFIGURATION}
		BUILD_IN_SOURCE 0
		INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_if_different ${LIBFILE_ZLIB_DLL} ${BINDIR}/
			COMMAND ${CMAKE_COMMAND} -E copy_if_different ${LIBFILE_ZLIB_IMPLIB} ${LIBDIR}/
			COMMAND "" #${CMAKE_COMMAND} -E copy_if_different ${LIBFILE_ZLIB_LIB} ${LIBDIR}/
			COMMAND ${CMAKE_COMMAND} -E copy_if_different ${EP_BASE}/Source/project_${TARGET_ZLIB}/zlib.h ${INCDIR}/
			COMMAND ${CMAKE_COMMAND} -E copy_if_different zconf.h ${INCDIR}/

			COMMAND ${CMAKE_COMMAND} -E copy_if_different ${EP_BASE}/Source/project_${TARGET_ZLIB}/zlib.h ${EP_BASE}/Build/project_${TARGET_ZLIB}/ # to build libpng
	)
elseif(APPLE)
	set(FRAMEWORK_DIR_ZLIB ${DESTINATION_PATH}/${TARGET_ZLIB}.framework)
	set(DYLIBNAME_ZLIB libz.1.2.11.dylib)

	ExternalProject_Add(project_${TARGET_ZLIB}
		URL ${URL_ZLIB}
		URL_MD5 ${URL_MD5_ZLIB}
		CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_MACOSX_RPATH=ON
		BUILD_COMMAND ${PARALLEL_MAKE}
		BUILD_IN_SOURCE 0
		INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory ${FRAMEWORK_DIR_ZLIB}/Versions/A
			COMMAND ${CMAKE_COMMAND} -E create_symlink A ${FRAMEWORK_DIR_ZLIB}/Versions/Current
			COMMAND ${CMAKE_COMMAND} -E copy_if_different ${DYLIBNAME_ZLIB} ${FRAMEWORK_DIR_ZLIB}/Versions/A/
			COMMAND ${CMAKE_COMMAND} -E create_symlink Versions/Current/${DYLIBNAME_ZLIB} ${FRAMEWORK_DIR_ZLIB}/${TARGET_ZLIB}
			COMMAND install_name_tool -id "@rpath/${TARGET_ZLIB}.framework/${TARGET_ZLIB}" ${FRAMEWORK_DIR_ZLIB}/${TARGET_ZLIB}
			COMMAND ${CMAKE_COMMAND} -E make_directory ${FRAMEWORK_DIR_ZLIB}/Versions/A/Headers/
			COMMAND ${CMAKE_COMMAND} -E copy_if_different ${EP_BASE}/Source/project_${TARGET_ZLIB}/zlib.h ${FRAMEWORK_DIR_ZLIB}/Versions/A/Headers/
			COMMAND ${CMAKE_COMMAND} -E copy_if_different zconf.h ${FRAMEWORK_DIR_ZLIB}/Versions/A/Headers/
			COMMAND ${CMAKE_COMMAND} -E create_symlink Versions/Current/Headers ${FRAMEWORK_DIR_ZLIB}/Headers

			COMMAND ${CMAKE_COMMAND} -E copy_if_different ${EP_BASE}/Source/project_${TARGET_ZLIB}/zlib.h zlib.h # to build libpng
	)
elseif(NOT EMSCRIPTEN)
	set(LIBNAME_ZLIB libz)

	ExternalProject_Add(project_${TARGET_ZLIB}
		URL ${URL_ZLIB}
		URL_MD5 ${URL_MD5_ZLIB}
		CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=${DESTINATION_PATH}
		BUILD_COMMAND ${PARALLEL_MAKE}
		BUILD_IN_SOURCE 0
		INSTALL_COMMAND make install
	)
endif()
