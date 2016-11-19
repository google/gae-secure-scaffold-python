# Copyright 2014 Google Inc. All rights reserved.
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
from google.appengine.api import memcache  # For XsrfHandler.  Remove if unused.
from google.appengine.api import users

from base import constants
from base import handlers

from generated import example

# Example handlers to demonstrate functionality.
# Replace with your own implementations.
class ClosureXssHandler(handlers.BaseHandler):

  def get(self):
    self.render(example.xss,
                { 's': self.request.get('string', '') })

class JinjaXssHandler(handlers.BaseHandler):

  def get(self):
    # Test for jinja extension
    extensions = self.get_jinja2_config()['environment_args']['extensions']
    autoescape_ext = 'jinja2.ext.autoescape' in extensions

    if not constants.IS_DEV_APPSERVER:
      self.render('debug_only.tpl')
      return
    autoescape = self.request.get('autoescape') != 'off'
    string = self.request.get('string', '')
    template = {'string': string,
                'autoescape': autoescape,
                'show_autoescape': bool(string) and autoescape_ext}
    # DANGER: Disable CSP and the built-in XSS blocker in modern browsers for
    # demonstration purposes.  DO NOT DUPLICATE THIS IN PRODUCTION CODE.
    self.response.headers['X-XSS-Protection'] = '0'
    self.response.headers['content-security-policy'] = ''
    self.render('xss.tpl', template)

  def post(self):
    self.get()

class XsrfHandler(handlers.AuthenticatedHandler):

  def _GetCounter(self):
    counter = memcache.get('counter')
    if not counter:
      counter = 0
      memcache.set('counter', counter)
    return counter

  def get(self):
    if not constants.IS_DEV_APPSERVER:
      self.render('debug_only.tpl')
      return
    counter = self._GetCounter()
    self.render('xsrf.tpl', {'email': self.current_user.email(),
                             'counter': counter})

  def post(self):
    if not constants.IS_DEV_APPSERVER:
      self.render('debug_only.tpl')
      return
    counter = self._GetCounter() + 1
    memcache.set('counter', counter)
    self.render('xsrf.tpl', {'email': self.current_user.email(),
                             'counter': counter})

  def DenyAccess(self):
    self.redirect(users.create_login_url(self.request.path))

  def XsrfFail(self):
    counter = self._GetCounter()
    self.render('xsrf.tpl', {'email': self.current_user.email(),
                             'counter': counter,
                             'xsrf_fail': True})


class XssiHandler(handlers.BaseHandler):

  def get(self):
    if not constants.IS_DEV_APPSERVER:
      self.render('debug_only.tpl')
      return
    self.render('xssi.tpl')

  def post(self):
    self.get()


class CspHandler(handlers.BaseHandler):

  def get(self):
    # Test for jinja extension
    extensions = self.get_jinja2_config()['environment_args']['extensions']
    autoescape_ext = 'jinja2.ext.autoescape' in extensions

    if not constants.IS_DEV_APPSERVER:
      self.render('debug_only.tpl')
      return
    self.render('csp.tpl')

  def post(self):
    self.get()
