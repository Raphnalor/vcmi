include_guard()

if (NOT _VCPKG_ROOT_DIR)
  return()
endif()

function(_vcpkg_parse_find_library_arguments outputVar outputNames #[[arguments]])
  set(var)
  set(names)
  set(arguments ${ARGN})
  if (arguments)
    list(GET arguments 0 var)
    list (REMOVE_AT arguments 0)
    if (arguments)
      list(GET arguments 0 arg)
      list (REMOVE_AT arguments 0)
      if (arg STREQUAL "NAMES")
        set (stopList NAMES_PER_DIR NO_DEFAULT_PATH NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH
                  NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_SYSTEM_PATH CMAKE_FIND_ROOT_PATH_BOTH
                  ONLY_CMAKE_FIND_ROOT_PATH NO_CMAKE_FIND_ROOT_PATH DOC HINTS PATHS PATH_SUFFIXES)
        while (arguments)
          list(GET arguments 0 arg)
          list (REMOVE_AT arguments 0)
          list (FIND stopList arg idx)
          if (NOT idx EQUAL -1)
            break()
          endif()
          list(APPEND names ${arg})
        endwhile()
      else()
        set(names ${arg})
      endif()
    endif()
  endif()
  set (${outputVar} ${var} PARENT_SCOPE)
  set (${outputNames} ${names} PARENT_SCOPE)
endfunction()

function (_vcpkg_append_library_debug_names inOutNames)
  set (names ${${inOutNames}})
  set (resultNames)
  foreach (name ${names})
    list(APPEND resultNames "${name}" "${name}d" "${name}-debug")
  endforeach()
  set (${inOutNames} ${resultNames} PARENT_SCOPE)
endfunction()

function(find_library #[[arguments]])
  _vcpkg_parse_find_library_arguments(var names ${ARGN})
  if (NOT var OR NOT names)
    _find_library(${ARGN})
    return()
  endif()

  if (${var})
    return()
  endif()

  _find_library(_LIBPATH_RELEASE
    NAMES
      ${names}
    HINTS
      ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/lib
    NO_DEFAULT_PATH
  )

  set(debugNames ${names})
  _vcpkg_append_library_debug_names(debugNames)
  _find_library(_LIBPATH_DEBUG
    NAMES
      ${debugNames}
    HINTS
      ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/debug/lib
    NO_DEFAULT_PATH
  )

  set (libPaths)
  if (_LIBPATH_RELEASE)
    list(APPEND libPaths optimized "${_LIBPATH_RELEASE}")
  endif()
  if (_LIBPATH_DEBUG)
    list(APPEND libPaths debug "${_LIBPATH_DEBUG}")
  endif()
  unset(_LIBPATH_RELEASE CACHE)
  unset(_LIBPATH_DEBUG CACHE)

  if (NOT libPaths)
    _find_library(${ARGN})
    return()
  endif()

  set (${var} "${libPaths}" CACHE STRING "Paths to optimized and debug libraries.")
endfunction()

