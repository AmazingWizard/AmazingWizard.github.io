---
layout: post
title: Weekend Hack - New-Blogpost.ps1
date: 2017-11-19
---

I wanted to create a simple function that can be called quickly from my blog repository to generate a new blog post markdown file for this Github Pages Jekyll site. It also gave me a reason to try and use `System.Text.StringBuilder`. It seems like a nice way to build multi-line strings.

{% gist e7893ac5ae2b793946199778953d0149 %}

By default, the cmd assumes you want your blogs under `_posts` but if you are keeping them in a different location you can specify the path using `-path`. If the path doesn't exist it will fail to run. If you do not provide a date, then the current date is used. However, you can provide a custom date by using the `-date` param. You can also provide some basic content using the `-content` param which will appear under the front matter of the markdown file. Lastly, you can tell the cmd that you want to open the file it creates in VS Code by using the `-openwithcode` flag. The cmd outputs an object using `Get-ChildItem` in case you want to pipe it out into some other command after you generate the post.

I might also configure a task in VS Code in the future that can call this function for you, but I'm not sure yet if that's a good use of Tasks. File that under "Things I need to research".

Next, I think it would be interesting to create some scripts that can rename a Blog post, change the date of a blog post, or a cmd that can archive blogs after a specific date. Also part of me wonders what an automated blog would look like. What kind of content could I systematically generate and then output and commit to GitHub?

Anyway, enjoy!