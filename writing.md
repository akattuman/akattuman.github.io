---
layout: page
title: Writing
---

[the archives]

{% assign internal_texts = site.writing | where_exp: "item", "item.status == 'published'" %}
{% assign textsByYear = internal_texts | sort: "date" | reverse | group_by_exp:"item", "item.date | date: '%Y'" %}

{% for year in textsByYear %}
  <h1>{{ year.name }}</h1>
  <ul>
      {% for post in year.items %}
        <li>
            {% if post.external_only != nil and post.external_link %}
                {% assign thisUrl = post.external_link %}
            {% else %}
                {% assign thisUrl = post.url %}
            {% endif %}
            {{ post.date | date: "%b %d"}} - <a href="{{ thisUrl }}">{{ post.title }}</a>
            <i>{% if post.external_source != nil %}({{ post.external_source }}){% endif %}</i>
        </li>
      {% endfor %}
    </ul>
{% endfor %}

