{% extends "base.tpl" %}
{% block title %}
  Cross-Site Scripting
{% endblock %}
{% block content %}
<h1>Cross-Site Scripting</h1>
<p>Cross-Site Scripting (XSS) occurs when user input is output by a web server
without being properly escaped for the <em>context</em> in which it is
displayed.
</p>
<p>Consider a simple page like this one, which, when given a name, will print
a simple greeting, e.g. "Hello, Jane!"</p>
<p>What happens if a user decides to enter something malicious for their name,
maybe something like:
<code>&lt;script&gt;alert(1);&lt;/script&gt;</code>
</p>
<p>If we output that string directly in our page, we would execute the
(possibly malicious) Javascript!  Go ahead, try entering that Javascript
snippet:
</p>
<form method="get">
  <input id="string" name="string" type="text" size="30" value="{{string}}"/>
  <label for="string">String to output</label><br />
  {% if show_autoescape %}
  <input id="autoesc" name="autoescape" value="off" type="checkbox" />
  <label for="autoesc">Disable Autoescaping</label><br />
  {% endif %}
  <input type="submit" value="Submit">
</form>

{% if not autoescape %}
<p>Note that in the default case, no alert box was fired, because the
framework enabled <em>autoescaping</em> by default.  Unfortunately,
this autoescaping is not perfect, and actually has some limitations
around context - the Python template systems only perform HTML escaping,
which means converting characters like &lt; to &amp;lt;, &gt; to &amp;gt;
and &quot; to &amp;quot;.</p>
<p>This becomes a problem if you wanted to do something like this in a
template, though:</p>
<code>
&lt;script&gt;
var foo = '{{ '{{' }}user_controlled_string}}';
&lt;/script&gt;
</code>
<p>This is problematic because the user could provide this input:</p>
<code>
' + alert(1) + '
</code>
<p>Note that none of these characters would be HTML escaped, and the resulting
code block would be:</p>
<code>
&lt;script&gt;
var foo = '' + alert(1) + '';
&lt;/script&gt;
</code>
<p>The Javascript interpreter will execute the alert expression to build the
string, and we have a cross-site scripting vulnerability.  To avoid these,
we recommend avoiding constructs like this in your code.  If you must have
this construct, then template systems like Jinja2 and Django often provide
a specific Javascript escaping function, but this is quite error prone.
If you are looking for a truly better way, you should investigate using a
<em>contextually aware</em> autoescaping template system, such as
<a href="https://developers.google.com/closure/templates/?csw=1">
Closure Templates</a>.
</p>
<p>XSS is a <a href="https://www.google.com/about/appsecurity/learning/xss/">
complicated topic</a>, and these aren't the only attack vectors - please be
sure you understand the risks inherent in handling user input.</p>
<p>Ready to move on?  Click <a href="/examples/xssi">here</a> to learn about Cross-Site
Script Inclusion</a>.</p>
{% endif %}
<h2>Output:</h2>

{% if string %}
Hello,
  {% if autoescape %}
    {% include "autoescape.tpl" %}
  {% else %}
    {% include "noautoescape.tpl" %}
  {% endif %}
{% endif %}
{% if autoescape and string %}
<p>Now try again, but you might want to check the "disable autoescaping" checkbox.
In order to enable this option you need to modify base/handler.py and add "jinja2.ext.autoescape" extension in jinja2 config setting.
</p>
{% endif %}
{% endblock %}
