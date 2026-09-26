# Copyright (C) Microsoft Corporation. All rights reserved.
# This file is distributed under the University of Illinois Open Source License. See LICENSE.TXT for details.

if(NOT DEFINED PDBCOPY_EXECUTABLE OR
   NOT DEFINED INPUT_PDB OR
   NOT DEFINED OUTPUT_PDB)
  message(FATAL_ERROR
    "PDBCOPY_EXECUTABLE, INPUT_PDB, and OUTPUT_PDB must be specified")
endif()

set(stripped_pdb "${OUTPUT_PDB}.public")
file(REMOVE "${stripped_pdb}")

execute_process(
  COMMAND "${PDBCOPY_EXECUTABLE}" "${INPUT_PDB}" "${stripped_pdb}" -p
  RESULT_VARIABLE pdbcopy_result)
if(NOT pdbcopy_result EQUAL 0)
  file(REMOVE "${stripped_pdb}")
  message(FATAL_ERROR "Failed to create public PDB from ${INPUT_PDB}")
endif()

file(REMOVE "${OUTPUT_PDB}")
file(RENAME "${stripped_pdb}" "${OUTPUT_PDB}")
