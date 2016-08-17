{% extends "base.tpl" %}
{% block title %}
  Content Security Policy
{% endblock %}
{% block content %}
<h1>Content Security Policy</h1>
<p>CSP is a mechanism designed to make applications more secure against common
Web vulnerabilities, particularly XSS.<br>
It is enabled by delivering a policy in the <code>Content-Security-Policy</code> HTTP response header.
</p>

<p>A production-quality strict policy appropriate for many products is:<br>
<code>
Content-Security-Policy:
  object-src 'none';
  script-src 'nonce-{random}' 'strict-dynamic' 'unsafe-inline' 'unsafe-eval' https: http:;
</code>
</p>

<p>
When such a policy is set, modern browsers will execute only those scripts whose
nonce attribute matches the value set in the policy header, as well as scripts
dynamically added to the page by scripts with the proper nonce.<br>Older browsers,
which don't support the CSP3 standard, will ignore the <code>nonce-*</code> and
<code>'strict-dynamic'</code> keywords and fall back to
[<code>script-src 'unsafe-inline' https: http:</code>] which will not provide
protection against XSS vulnerabilities, but will allow the application to
function properly.
</p>

<h2>Adopting a strict policy</h2>
<p>
To use a strict CSP policy, most applications will need to make the following changes:
<br>
<ul>
  <li>Add a nonce attribute to all <code>&lt;script&gt;</code> elements. Some template systems can do this automatically.
    <br>E.g. in Jinja:
    {% raw %}
    <code>&lt;script&gt; nonce="{{_csp_nonce}}" src="..."&gt;&lt;/script&gt;</code>
    {% endraw %}

  <li>Refactor any markup with inline event handlers (<code>onclick</code>, etc.) and <code>javascript:</code> URIs (details).
  <li>For every page load, generate a new nonce, pass it the to the template system, and use the same value in the <code>Content-Security-Policy</code> response header.
</ul>
</p>

<h2>Example of a nonced script that dynamically adds child scripts</h2>
<!--
     Twitter timeline dynamically creates child element which are allowed
     to execute because of 'strict-dynamic'.
     The widget shows a manually curated twitter collection of relevant
     strict-csp posts. Will be replaced with better documentation soon.
-->
<a class="twitter-timeline" data-width="800" data-height="600" data-dnt="true" data-partner="tweetdeck" href="https://twitter.com/we1x/timelines/765840589183213568">Strict CSP</a>
<script nonce="{{_csp_nonce}}" async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

{% endblock %}
