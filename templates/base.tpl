<!doctype html>
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
  {% block head %}
  <title>{% block title %}{% endblock %} - My Webpage</title>
  {% endblock %}
  </head>
  <body>
    <div id="content">
    {% block content %}
    {% endblock %}
    </div>
  </body>
</html>
