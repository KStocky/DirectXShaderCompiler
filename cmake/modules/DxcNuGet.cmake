# Copyright (C) Microsoft Corporation. All rights reserved.
# This file is distributed under the University of Illinois Open Source License. See LICENSE.TXT for details.

if(NOT WIN32 OR NOT MSVC)
  message(FATAL_ERROR "The DXC NuGet layout is supported only by MSVC builds on Windows")
endif()

set(DXC_NUGET_ARCHITECTURE "x64" CACHE STRING
  "Architecture directory used in the DXC NuGet layout")

find_program(DXC_PDBCOPY_EXECUTABLE
  NAMES pdbcopy
  HINTS
    "${WIN10_SDK_PATH}/Debuggers/x64"
    "${WIN10_SDK_PATH}/Debuggers/x86")
if(NOT DXC_PDBCOPY_EXECUTABLE)
  message(FATAL_ERROR
    "pdbcopy.exe is required to create the DXC NuGet layout. "
    "Install Debugging Tools for Windows from the Windows SDK.")
endif()

set(dxc_nuget_native_dir "build/native")
set(dxc_nuget_bin_dir
  "${dxc_nuget_native_dir}/bin/${DXC_NUGET_ARCHITECTURE}")
set(dxc_nuget_lib_dir
  "${dxc_nuget_native_dir}/lib/${DXC_NUGET_ARCHITECTURE}")
set(dxc_nuget_include_dir "${dxc_nuget_native_dir}/include")

install(TARGETS dxcompiler dxildll
  RUNTIME DESTINATION "${dxc_nuget_bin_dir}"
    COMPONENT dxc-nuget
  ARCHIVE DESTINATION "${dxc_nuget_lib_dir}"
    COMPONENT dxc-nuget)

install(TARGETS dxc dxv
  RUNTIME DESTINATION "${dxc_nuget_bin_dir}"
  COMPONENT dxc-nuget)

foreach(target dxc dxcompiler dxildll dxv)
  install(FILES "$<TARGET_PDB_FILE:${target}>"
    DESTINATION "${dxc_nuget_bin_dir}"
    COMPONENT dxc-nuget
    OPTIONAL)
endforeach()

install(FILES
  "${LLVM_SOURCE_DIR}/include/dxc/dxcapi.h"
  "${LLVM_SOURCE_DIR}/include/dxc/dxcerrors.h"
  "${LLVM_SOURCE_DIR}/include/dxc/dxcisense.h"
  "${LLVM_SOURCE_DIR}/include/dxc/dxcpix.h"
  "${D3D12_INCLUDE_DIR}/d3d12shader.h"
  DESTINATION "${dxc_nuget_include_dir}"
  COMPONENT dxc-nuget)

install(FILES
  "${LLVM_SOURCE_DIR}/include/dxc/Support/ErrorCodes.h"
  DESTINATION "${dxc_nuget_include_dir}/Support"
  COMPONENT dxc-nuget)

install(FILES
  "${LLVM_SOURCE_DIR}/tools/clang/lib/Headers/hlsl/README.txt"
  DESTINATION "${dxc_nuget_include_dir}/hlsl"
  COMPONENT dxc-nuget)
install(FILES
  "${LLVM_SOURCE_DIR}/tools/clang/lib/Headers/hlsl/LICENSE.txt"
  DESTINATION "${dxc_nuget_include_dir}/hlsl"
  RENAME "LICENCE.txt"
  COMPONENT dxc-nuget)
install(FILES
  "${LLVM_SOURCE_DIR}/tools/clang/lib/Headers/hlsl/vk/opcode_selector.h"
  "${LLVM_SOURCE_DIR}/tools/clang/lib/Headers/hlsl/vk/spirv.h"
  DESTINATION "${dxc_nuget_include_dir}/hlsl/vk"
  COMPONENT dxc-nuget)
install(FILES
  "${LLVM_SOURCE_DIR}/tools/clang/lib/Headers/hlsl/vk/khr/cooperative_matrix.h"
  "${LLVM_SOURCE_DIR}/tools/clang/lib/Headers/hlsl/vk/khr/cooperative_matrix.impl"
  DESTINATION "${dxc_nuget_include_dir}/hlsl/vk/khr"
  COMPONENT dxc-nuget)

install(FILES
  "${LLVM_SOURCE_DIR}/utils/nuget/Microsoft.Direct3D.DXC.props"
  "${LLVM_SOURCE_DIR}/utils/nuget/Microsoft.Direct3D.DXC.Rules.Project.xml"
  "${LLVM_SOURCE_DIR}/utils/nuget/Microsoft.Direct3D.DXC.targets"
  DESTINATION "${dxc_nuget_native_dir}"
  COMPONENT dxc-nuget)

install(FILES "${LLVM_SOURCE_DIR}/LICENSE.TXT"
  DESTINATION "."
  RENAME "LICENSE-LLVM.txt"
  COMPONENT dxc-nuget)
install(FILES
  "${LLVM_SOURCE_DIR}/ThirdPartyNotices.txt"
  "${LLVM_SOURCE_DIR}/docs/ReleaseNotes.md"
  DESTINATION "."
  COMPONENT dxc-nuget)

add_custom_target(install-dxc-nuget
  DEPENDS dxc dxcompiler dxildll dxv
  COMMAND "${CMAKE_COMMAND}"
    -DCMAKE_INSTALL_COMPONENT=dxc-nuget
    -P "${CMAKE_BINARY_DIR}/cmake_install.cmake"
  COMMAND "${CMAKE_COMMAND}"
    "-DPDBCOPY_EXECUTABLE=${DXC_PDBCOPY_EXECUTABLE}"
    "-DINPUT_PDB=$<TARGET_PDB_FILE:dxc>"
    "-DOUTPUT_PDB=${CMAKE_INSTALL_PREFIX}/${dxc_nuget_bin_dir}/dxc.pdb"
    -P "${CMAKE_CURRENT_LIST_DIR}/DxcStripPdb.cmake"
  COMMAND "${CMAKE_COMMAND}"
    "-DPDBCOPY_EXECUTABLE=${DXC_PDBCOPY_EXECUTABLE}"
    "-DINPUT_PDB=$<TARGET_PDB_FILE:dxcompiler>"
    "-DOUTPUT_PDB=${CMAKE_INSTALL_PREFIX}/${dxc_nuget_bin_dir}/dxcompiler.pdb"
    -P "${CMAKE_CURRENT_LIST_DIR}/DxcStripPdb.cmake"
  COMMAND "${CMAKE_COMMAND}"
    "-DPDBCOPY_EXECUTABLE=${DXC_PDBCOPY_EXECUTABLE}"
    "-DINPUT_PDB=$<TARGET_PDB_FILE:dxildll>"
    "-DOUTPUT_PDB=${CMAKE_INSTALL_PREFIX}/${dxc_nuget_bin_dir}/dxil.pdb"
    -P "${CMAKE_CURRENT_LIST_DIR}/DxcStripPdb.cmake"
  COMMAND "${CMAKE_COMMAND}"
    "-DPDBCOPY_EXECUTABLE=${DXC_PDBCOPY_EXECUTABLE}"
    "-DINPUT_PDB=$<TARGET_PDB_FILE:dxv>"
    "-DOUTPUT_PDB=${CMAKE_INSTALL_PREFIX}/${dxc_nuget_bin_dir}/dxv.pdb"
    -P "${CMAKE_CURRENT_LIST_DIR}/DxcStripPdb.cmake"
  USES_TERMINAL)
