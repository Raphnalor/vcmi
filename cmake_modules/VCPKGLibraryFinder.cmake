include_guard()

if (NOT _VCPKG_ROOT_DIR)
  return()
endif()

cmake_policy(PUSH)
cmake_policy(SET CMP0057 NEW)

function(vcpkg_parse_find_library_arguments prefix #[[arguments]])
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
          if (arg IN_LIST stopList)
            break()
          endif()
          list(APPEND names ${arg})
        endwhile()
      else()
        set(names ${arg})
      endif()
    endif()
  endif()
  set (${prefix}_VAR ${var} PARENT_SCOPE)
  set (${prefix}_NAMES ${names} PARENT_SCOPE)
endfunction()

function (vcpkg_replace_item_in_list var findWhat replaceWith)
  set(temp ${${var}})
  list(FIND temp ${findWhat} _IDX)
  if (NOT _IDX EQUAL -1)
    list(REMOVE_AT temp _IDX)
    list(APPEND temp ${replaceWith})
  endif()
  set(${var} ${temp} PARENT_SCOPE)
endfunction()

function(vcpkg_get_library_debug_names outputVar names)
  set (debugNames ${names})
  vcpkg_replace_item_in_list(debugNames "SDL2" "SDL2d")
  vcpkg_replace_item_in_list(debugNames "fuzzylite" "fuzzylite-debug")
  set (${outputVar} ${debugNames} PARENT_SCOPE)
endfunction()

function(find_library #[[arguments]])
  vcpkg_parse_find_library_arguments(_FIND_LIBRARY_ARGS ${ARGN})
  if (_FIND_LIBRARY_ARGS_VAR)
    _find_library(${_FIND_LIBRARY_ARGS_VAR}_RELEASE
      NAMES
        ${_FIND_LIBRARY_ARGS_NAMES}
      HINTS
        ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/lib
      NO_DEFAULT_PATH
    )
    vcpkg_get_library_debug_names(_LIBRARY_DEBUG_NAMES ${_FIND_LIBRARY_ARGS_NAMES})
    _find_library(${_FIND_LIBRARY_ARGS_VAR}_DEBUG
      NAMES
        ${_LIBRARY_DEBUG_NAMES}
      HINTS
        ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/debug/lib
      NO_DEFAULT_PATH
    )
    mark_as_advanced(${_FIND_LIBRARY_ARGS_VAR}_RELEASE ${_FIND_LIBRARY_ARGS_VAR}_DEBUG)
    if (${_FIND_LIBRARY_ARGS_VAR}_RELEASE AND ${_FIND_LIBRARY_ARGS_VAR}_DEBUG)
      set(${_FIND_LIBRARY_ARGS_VAR} optimized ${${_FIND_LIBRARY_ARGS_VAR}_RELEASE}
                                    debug ${${_FIND_LIBRARY_ARGS_VAR}_DEBUG}
                                    CACHE STRING "Paths to optimized and debug libraries.")
    else()
      _find_library(${ARGN})
    endif()
  endif()
endfunction()

cmake_policy(POP)

#######################################################
return()

parseFindLibraryArguments(
  X
    SDL2_IMAGE_LIBRARY
  NAMES 
    SDL2_image
    SDL2_imaged
  HINTS
    ENV SDL2IMAGEDIR
    ENV SDL2DIR
  PATH_SUFFIXES 
    lib)

message("!! X_NAMES=${X_NAMES}")
message("!! X_VAR=${X_VAR}")

parseFindLibraryArguments(
  X
    SDL2_IMAGE_LIBRARY
  SDL2_image
  HINTS
    ENV SDL2IMAGEDIR
    ENV SDL2DIR
  PATH_SUFFIXES 
    lib)

message("!! X_NAMES=${X_NAMES}")
message("!! X_VAR=${X_VAR}")

parseFindLibraryArguments(
  X)

message("!! X_NAMES=${X_NAMES}")
message("!! X_VAR=${X_VAR}")
