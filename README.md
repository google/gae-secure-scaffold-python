# Secure GAE Scaffold for Python 2

## Introduction
----
Please note: this is not an official Google product.

*This scaffold is for users of App Engine's Python 2.7 runtime. For websites
deployed to the Python 3 runtime, please see [Secure Scaffold for Python 3](https://github.com/google/gae-secure-scaffold-python3).*

This contains a boilerplate AppEngine application meant to provide a secure
base on which to build additional functionality.  Structure:

* / - top level directory for common files, e.g. app.yaml
* /js - directory for uncompiled Javascript resources.
* /src - directory for all source code
* /static - directory for static content
* /templates - directory for Django/Jinja2 templates your app renders.
* /templates/soy - directory for Closure Templates your application uses.

Javascript resources for your application can be written using Closure,
and compiled by Google's Closure Compiler (detailed below in the dependencies
section).

The scaffold provides the following basic security guarantees by default through
a set of base classes found in `src/base/handlers.py`.  These handlers:

1. Set assorted security headers (Strict-Transport-Security, X-Frame-Options,
   X-XSS-Protection, X-Content-Type-Options, Content-Security-Policy) with
   strong default values to help avoid attacks like Cross-Site Scripting (XSS)
   and Cross-Site Script Inclusion.  See  `_SetCommonResponseHeaders()` and
   `SetAjaxResponseHeaders()`.
1. Prevent the XSS-prone construction of HTML via string concatenation by
   forcing the use of a template system (Django/Jinja2 supported).  The
   template systems have non-contextual autoescaping enabled by default.
   See the `render()`, `render_json()` methods in `BaseHandler` and
   `BaseAjaxHandler`. For contextual autoescaping, you should use Closure
   Templates in strict mode (<https://developers.google.com/closure/templates/docs/security>).
1. Test for the presence of headers that guarantee requests to Cron or
   Task endpoints are made by the AppEngine serving environment or an
   application administrator.  See the `dispatch()` method in `BaseCronHandler`
   and `BaseTaskHandler`.
1. Verify XSRF tokens by default on authenticated requests using any verb other
   that GET, HEAD, or OPTIONS.  See the `_RequestContainsValidXsrfToken()`
   method for more information.

In addition to the protections above, the scaffold monkey patches assorted APIs
that use insecure or dangerous defaults (see `src/base/api_fixer.py`).

Obviously no framework is perfect, and the flexibility of Python offers many
ways for a motivated developer to circumvent the protections offered.  Under
the assumption that developers are not malicious, using the scaffold should
centralize many security mechanisms, provide safe defaults, and structure the
code in a way that facilitates security review.

Sample implementations can be found in `src/handlers.py`.  These demonstrate
basic functionality, and should be removed / replaced by code specific to
your application.


## Prerequisites
----
These instructions have been tested with the following software:

* node.js >= 0.8.0
    * 0.8.0 is the minimum required to build with [Grunt](http://gruntjs.com/).
* git
* curl

## Dependency Setup
----
From the root of the repository:

1.  `git submodule init`
1.  `git submodule update`
1.  `cd closure-compiler` - refer to closure-compiler/README.md on how to build
       the compiler.  Feel free to use this GWT-skipping variant:
       `mvn -pl externs/pom.xml,pom-main.xml,pom-main-shaded.xml`
1.  `cd ../closure-templates && mvn && cd ..`
1.  `npm install`
1.  `mkdir $HOME/bin; cd $HOME/bin`
1.  `npm install grunt-cli`
    * Alternatively, `sudo npm install -g grunt-cli` will install system-wide
      and you may skip the next step.
1.  `export PATH=$HOME/bin/node_modules/grunt-cli/bin:$PATH`
    * It is advisable to add this to login profile scripts (.bashrc, etc.).
1.  Visit <https://cloud.google.com/appengine/docs/python/download>, and choose
    the alternative option to "download the original App Engine SDK for Python."
    Choose the "Linux" platform (even if you use OS X).  Unzip the file, such
    that $HOME/bin/google_appengine/ is populated with the contents of the .zip.

To install dependencies for unit testing:
1. `sudo easy_install pip`
1. `sudo pip install unittest2`

## Scaffold Development
----

### Testing
To run unit tests:

`python run_tests.py ~/bin/google_appengine src`

### Local Development
To run the development appserver locally:

1. `grunt clean`
1. `grunt`
1. `grunt appengine:run:app`

Note that the development appserver will be running on a snapshot of code
at the time you run it.  If you make changes, you can run the various Grunt
tasks in order to propagate them to the local appserver.  For instance,
`grunt copy` will refresh the source code (local and third party), static files,
and templates.  `grunt closureSoys` and/or `grunt closureBuilder` will rebuild
the templates or your provided Javascript and the updated versions will be
written in the output directory.

### Deployment
To deploy to AppEngine:

1. `grunt clean`
1. `grunt --appid=<appid>`
1. `grunt appengine:update:app --appid=<appid>`

Specifying `--appid=` will override any value set in `config.json`.  You may
modify the `config.json` file to avoid having to pass this parameter on
every invocation.

## Notes
----
Files in `js/` are compiled by the Closure Compiler (if available) and placed in
`out/static/app.js`.  Included in this compilation pass is the the output of
the `closureSoys:js` task (intermediate artifacts: out/generated/js/\*.js).

Closure Templates that you provide are also compiled using the Python backend,
and are available using the constants.CLOSURE template strategy (the default).
The generated source code is stored in out/generated/\*.py.  To use them,
pass the callable template as the first argument to render(), and a dictionary
containing the template values as the second argument, e.g.:

    from generated import helloworld
    
    [...]
    
    self.render(helloworld.helloWorld, { 'name': 'first last' })

The `/static` and `/template` directories are replicated in `out/`, and the
files in `src/` are rebased into `out/` (so `src/base/foo.py` becomes
`out/base/foo.py`).
