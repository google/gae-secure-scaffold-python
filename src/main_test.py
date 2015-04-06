# Copyright 2015 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.
"""Tests for main."""

import unittest2
import webapp2

from base import handlers
import main


class MainTest(unittest2.TestCase):
  """Test cases for main."""

  def _VerifyInheritance(self, routes_list, base_class):
    """Checks that the handlers of the given routes inherit from base_class."""
    router = webapp2.Router(routes_list)
    routes = router.match_routes + router.build_routes.values()
    for route in routes:
      self.assertTrue(issubclass(route.handler, base_class),
          msg='%s in does not inherit from %s.' % (
              route.handler.__name__, base_class.__name__))

  def testRoutesInheritance(self):
    self._VerifyInheritance(main._UNAUTHENTICATED_ROUTES, handlers.BaseHandler)
    self._VerifyInheritance(main._UNAUTHENTICATED_AJAX_ROUTES,
                            handlers.BaseAjaxHandler)
    self._VerifyInheritance(main._USER_ROUTES, handlers.AuthenticatedHandler)
    self._VerifyInheritance(main._AJAX_ROUTES,
                            handlers.AuthenticatedAjaxHandler)
    self._VerifyInheritance(main._ADMIN_ROUTES, handlers.AdminHandler)
    self._VerifyInheritance(main._ADMIN_AJAX_ROUTES, handlers.AdminAjaxHandler)
    self._VerifyInheritance(main._CRON_ROUTES, handlers.BaseCronHandler)
    self._VerifyInheritance(main._TASK_ROUTES, handlers.BaseTaskHandler)

  def testStrictHandlerMethodRouting(self):
    router = webapp2.Router(main._USER_ROUTES + main._AJAX_ROUTES +
                            main._ADMIN_ROUTES + main._ADMIN_AJAX_ROUTES)
    routes = router.match_routes + router.build_routes.values()
    for route in routes:
      if route.handler_method and not route.methods:
        self.fail('%s specifies a handler_method but no "methods" attribute, '
                  'and may be vulnerable to XSRF via GET requests' %
                  (route.template))

if __name__ == '__main__':
  unittest2.main()
