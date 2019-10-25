#!/bin/bash

. ./src/mk.sh --source-only
. ./tests/utils --source-only

function suite
{
  suite_addTest "valid_parser_command_Test"
  suite_addTest "invalid_parser_command_Test"
}

function setupTest()
{
  local -r test_path="tests/.tmp"
  local -r current_path=$PWD

  parse_configuration tests/samples/kworkflow.config

  rm -rf $test_path
  mkdir -p $test_path
  cd $test_path
  touch .config
  echo $CONTENT > .config
  cd $current_path
}

function tearDownTest()
{
  local -r test_path="tests/.tmp"

  rm -rf $test_path
}

function test_expected_string()
{
  local msg="$1"
  local expected="$2"
  local target="$3"

  assertEquals "$msg" "$target" "$expected"
}

function valid_parser_command_Test
{
  local ID

  # Force an unspected error
  ID=0
  output=$(parser_command --remote)
  ret="$?"
  assertEquals "($ID) We did not load kworkflow.config, we expect an error" "22" "$ret"

  setupTest

  ID=1
  parser_command --vm
  ret="$?"
  assertEquals "($ID) Expected 1, which means VM" "1" "$ret"

  ID=2
  parser_command --local
  ret="$?"
  assertEquals "($ID) Expected 2, which means local" "2" "$ret"

  ID=3
  output=$(parser_command --remote)
  ret="$?"
  assertEquals "($ID) Expected 3, which means local" "3" "$ret"
  assertEquals "($ID) Expected 127.0.0.1:3333" "127.0.0.1:3333" "$output"

  ID=4
  output=$(parser_command --remote "localhost:6789")
  ret="$?"
  assertEquals "($ID) Expected 3, which means local" "3" "$ret"
  assertEquals "($ID) Expected localhost:6789" "localhost:6789" "$output"

  ID=5
  output=$(parser_command --remote "localhost")
  ret="$?"
  assertEquals "($ID) Expected 3, which means local" "3" "$ret"
  assertEquals "($ID) Expected localhost:22" "localhost:22" "$output"

  ID=6
  output=$(parser_command)
  ret="$?"
  assertEquals "($ID) Expected 1, default is vm" "1" "$ret"


  # TODO: AGORA TEMOS QUE VALIDAR CASOS INVALIDOS
  # O formato deve ser ALGO:ALGO, logo os seguintes casos tem que falhar
  # lala:lala:lala

  tearDownTest
}

function invalid_parser_command_Test
{
  local ID

  setupTest

  ID=1
  output=$(parser_command --vmm)
  ret="$?"
  assertEquals "($ID) Expected 22, invalid argument" "22" "$ret"

  ID=2
  output=$(parser_command -vm)
  ret="$?"
  assertEquals "($ID) Expected 22, invalid argument" "22" "$ret"

  ID=3
  output=$(parser_command -local)
  ret="$?"
  assertEquals "($ID) Expected 22, invalid argument" "22" "$ret"

  ID=4
  output=$(parser_command -remote)
  ret="$?"
  assertEquals "($ID) Expected 22, invalid argument" "22" "$ret"

  ID=5
  output=$(parser_command remote)
  ret="$?"
  assertEquals "($ID) Expected 22, invalid argument" "22" "$ret"

  tearDownTest
}

invoke_shunit
