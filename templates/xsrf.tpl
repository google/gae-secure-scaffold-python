{% extends "base.tpl" %}
{% block title %}
  Cross-Site Request Forgery
{% endblock %}
{% block content %}
<h1>Cross-Site Request Forgery</h1>
<p>Welcome, {{email}}!  You may notice that you had to log in to visit this
page.  That's because this vulnerability is specific to authenticated
functionality.  As such, the class that powers this page extends from
<code>AuthenticatedHandler</code>, which requires users to be logged in
before dispatching the request.</p>

<p>Cross-Site Request Forgery (XSRF) occurs when a web application performs
some state changing action without requiring an unpredictable / unforgeable
token before making the change.  The canonical example is of a vulnerable
online banking application that allows users to transfer funds when they visit
a URL like: https://example-bank.com/transfer?to_acct=1234&amp;amount=1000.</p>

<p>If you're logged in to the bank, but browsing another web site, they could
easily insert into their page:</p>
<p>
<code>&lt;img src="https://example-bank.com/transfer?to_account=1234&amp;
amount=1000" style="display:none" /&gt;
</code>
</p>
<p>In the background, your browser would make the request (and send your
authentication cookies), and the transfer would succeed.  Unfortunately,
simply switching to POST requests does not help, because the evil web site
could automatically submit a cross-domain form POST by using Javascript.
</p>
<p>The only solution that works is to include something that a third party
site can't predict, and that isn't sent along automatically with the
request (like cookies).  This is commonly referred to as an XSRF token.  The
token should be included either as a form parameter, or embedded in an
HTTP request header.</p>
<p>The secure framework actually generates these tokens and augments the
template variable dictionary you pass to <code>render()</code> with a
valid XSRF token under the key <code>_xsrf</code>, which you can include
in hidden form fields / HTTP request headers.  This token <strong>MUST</strong>
be present in POST requests to classes that extend from
<code>AuthenticatedHandler</code>, <code>AuthenticatedAjaxHandler</code>, or
<code>AuthenticatedAdminHandler</code>.  It is verified before your
implementation is called.  If the token fails to validate, the
<code>XsrfFail()</code> in your handler is invoked.
</p>
<p>This page implements a simple counter that counts how many times a
valid request was processed.  You can see the generated XSRF token below,
feel free to modify it and see how that impacts the success / failure of
request processing!
</p>
<p>Current value of counter: {{counter}}</p>
{% if xsrf_fail %}
<p>XSRF token validation failed!</p>
{% endif %}
<p>
<form method="post" action="/examples/xsrf">
<input type="text" size="48" id="xsrf" name="xsrf" value="{{_xsrf}}" />
<label for="xsrf">XSRF Token</label><br />
<input type="submit" />
</form>
</p>
{% endblock %}
