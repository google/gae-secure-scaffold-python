#!/usr/bin/python

import optparse
import sys
import unittest2

USAGE = """%prog SDK_PATH TEST_PATH <THIRD_PARTY>
Run unit tests for App Engine apps.

SDK_PATH    Path to the SDK installation
TEST_PATH   Path to package containing test modules
THIRD_PARTY Optional path to third party python modules to include."""

def main(sdk_path, test_path, third_party_path=None):
  sys.path.insert(0, sdk_path)
  import dev_appserver
  dev_appserver.fix_sys_path()
  if third_party_path:
    sys.path.insert(0, third_party_path)
  suite = unittest2.loader.TestLoader().discover(test_path,
                                                 pattern='*_test.py')
  unittest2.TextTestRunner(verbosity=2).run(suite)


if __name__ == '__main__':
  sys.dont_write_bytecode = True
  parser = optparse.OptionParser(USAGE)
  options, args = parser.parse_args()
  if len(args) < 2:
    print 'Error: At least 2 arguments required.'
    parser.print_help()
    sys.exit(1)
  SDK_PATH = args[0]
  TEST_PATH = args[1]
  THIRD_PARTY_PATH = args[2] if len(args) > 2 else None
  main(SDK_PATH, TEST_PATH, THIRD_PARTY_PATH)
