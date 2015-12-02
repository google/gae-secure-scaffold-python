{% extends "base.tpl" %}
{% block title %}
  Cross-Site Script Inclusion
{% endblock %}
{% block content %}
<h1>Cross-Site Script Inclusion</h1>
<p>Cross-Site Script Inclusion (XSSI) occurs when a web application returns
a response containing non-public data that can be parsed and interpreted as
Javascript.  It very frequently happens in "Web 2.0" applications that make
use of paradigms like <a href="http://en.wikipedia.org/wiki/JSONP">JSONP</a>.
Consider the following request/response pairs for a hypothetical JSONP
endpoint at "https://example.com/contacts?jsonp=foo" :</p>

<p>
<pre>
<code>
GET /contacts?jsonp=foo HTTP/1.1
Host: example.com
Cookie: session_id=12345678


HTTP/1.1 200 OK
Content-Type: application/javascript
Content-Length: ...

foo([ { "firstName": "John", "lastName": "Doe" },
      { "firstName": "Jane", "lastName": "Doe" } ]);
</code>
</pre>

Or, an alternative response:
<pre>
<code>
HTTP/1.1 200 OK
Content-Type: application/javascript
Content-Length: ...

var foo = [ { "firstName": "John", "lastName": "Doe" }, /* as before */ ];
</code>
</pre>
</p>
<p>Now further suppose that you were visiting a page on evil.com that contained
this (we're assuming the first kind of response, where a function call is
returned. A similar exploit exists for the second kind of response, where you
just read the value of the <code>xssi</code> variable that is now set):</p>
<p>
<pre>
<code>
&lt;script&gt;
function xssi(obj) {
  // code to leak the contact information to evil.com.
}
&lt;/script&gt;
&lt;script src="https://example.com/contacts?jsonp=xssi&gt;&lt;/script&gt;
</code>
</pre>
</p>
<p>The contact data would now be processed on evil.com!  In order to prevent
this, we have a few options:
</p>
<ul>
<li>Make the returned Javascript unlikely to execute by inserting a prefix that
will break the Javascript parser (like, <code>)]}'\n</code>).</li>
<li>Make it so the Javascript is not returned for a GET request, so when
evil.com tries to include it, an empty response is returned.</li>
</ul>
</p>
<p>Using the above mitigations, Javascript that you write simply has to
either:</p>
<p>
<ul>
<li>Remove the parser breaking prefix (e.g. by calling <code>substring()</code>
on the returned data).</li>
<li>Simply make a POST request to retrieve the data.</li>
</ul>
</p>

<p>As it turns out, our secure framework handles all the server-side pieces for
you!  If your WSGI handlers extend from <code>BaseAjaxHandler</code>,
<code>AuthenticatedAjaxHandler</code>, or <code>AdminAjaxHandler</code>,
then <code>GET</code> requests will automatically have that prefix appended.
<code>POST</code> requests don't have any prefix, but for the authenticated
variants, they will require a valid XSRF token in order to process the
request.</p>

<p>If you're not familiar with XSRF, please click <a href="/examples/xsrf">here</a> to
learn how the framework helps defend against that attack.  Don't be alarmed
if you're asked to log in - it's necessary for the demonstration.</p>
{% endblock %}
