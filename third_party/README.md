Use the `py` and `js` directories to track third party Python/Javascript code
used in building, deploying, or serving the site / application.  The contents
will be copied during the build process to `out/` and `out/static/third_party`
respectively.

Check in a pristine copy
========================

The first commit should be the version of the code as it was
downloaded. This allows us to track changes.

This commit should also contain LICENSE and README.local files.

Please only add one new library with each commit. If you want to use multiple
third party packages please split them in to one commit per package.

LICENSE
=======

To be used, third party code must be licensed.

The license for the file must be in a file named LICENSE in the root
directory in which the code was imported.

If it was not distributed like that you need to create a LICENSE file
(perhaps by renaming LICENSE.txt or COPYING to LICENSE). If the license
is only available in comments in the code, or at a particular URL then
extract and copy the text of the license in to LICENSE.

If you do generate a LICENSE file document it in the "Local Modifications"
section of README.local as follows:

    LICENSE file has been created for compliance purposes. Not included in
    the original distribution.

and include a brief description explaining how you generated the LICENSE file.

If a given piece of third party code is under multiple licenses then include
all of them in the LICENSE file.

Please wrap the LICENSE file to 80 characters and replace any
non-ASCII characters with their ASCII equivalents.

README.local
=============

This file allows people to quickly understand what this package is for.
The structure is:

    URL: http://  # This should point to the download URL from which you
                  # obtained this specific version of the package. Examples:
                  # http://example.org/packagename-0.3.tar.gz
                  # https://github.com/<user>/<project>/archive/<ref>.zip
                  # https://bitbucket.org/<user>/<project>/get/<ref>.zip
                  #
https://<host>.googlesource.com/<project>/+archive/<ref>.tar.gz
                  # http://<project>.googlecode.com/archive/<hash>.zip (only for
git or hg projects)
                  # http://<repo>.<project>.googlecode.com/archive/<hash>.zip
                  # http://<project>.googlecode.com/svn-history/<rNNN>/trunk
                  # https://svn.code.sf.net/p/<project>/code/trunk/?p=<revision>
(you can also use the tag path if using a tagged release)
    Version: XXX  # e.g., version string of the package, such as: 0.3
                  # rNNN for svn revision NNN; tag for git; the entire hash for
git, hg
                  # YYYY-MM-DD of date downloaded if *no other* version is
available
    License: XXX  # e.g., GPL v2, GPL v3, LGPL v2.1, Apache 2.0, BSD, MIT, etc.
    License File: # should be LICENSE (see the above instructions)

    Description:
    # Short description of the package
    The Foo framework provides support for geo-location based on the
    time of day and position of the Sun.

    Local Modifications:
    No modifications.

The "Local Modifications" section is for detailing whether any changes
have been made to the package (that might, for example, trigger clauses
in the license).

The URL should be the versioned packaged you downloaded. **Do not provide
an un-versioned URL or a URL to the project page**.
