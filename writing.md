---
layout: page
title: Writing
---

[the archives]

{% assign chron_texts = site.writing | where_exp: "item", "item.status == 'published'" | sort: "date" | reverse %}

<ul class="archive-list">
  {% for post in chron_texts %}
    <li>
      <span class="archive-date">{{ post.date | date: "%d %b %Y" }}</span>
      <span class="archive-title"><a href="{{ post.url }}">{{ post.title }}</a></span>
    </li>
  {% endfor %}
</ul>
