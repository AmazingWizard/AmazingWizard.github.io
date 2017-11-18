---
layout: post
title: Printer Dashboard Pt 1 - Getting the Data
date: "2017-11-17"
---

![]({{ site.baseurl }}/assets/img/2017-11-17-Printer-Dashboard-Using-UD--toner.jpg)

<cite>Credit: [Max Wheeler](https://www.flickr.com/photos/makenosound/2557531332)</cite>

Everyone hates printers for one reason or another. Some of us are unfortunate enough to not only have to manage the technical side of printers, but also the mundane side of printers: Restocking Toner.

After a short time of manually checking in on printer toner levels, I decided there had to be a better way. We use [Papercut](https://www.papercut.com/) for doing all kinds of printer management, but one thing it seemed to lack was a straightforward overview of toner across all your printers.

So I started doing some research and figured PaperCut must be getting the toner information via <abbr title="Simple Network Management Protocol">SNMP</abbr>. After some reading, I found there is a Com Object that can be used to make SNMP calls, which can be used against printers. After much tinkering, I had a script that could pull printers from our print server, and loop through them making SNMP calls for toner levels. 

{% gist c97c14c7913ecba8d0d31296ecc57698 %}

SNMP Is a magical nightmare of non-standardization, and some manufacturers are better about getting you the information you need vs others. Some places, like Ricoh, keep their SNMP OID information behind a paywall. So I basically got lucky with the HP printers I manage. However, that's not to say its simple or makes sense, as you can clearly see above. 

When all is said and done, we convert the array to JSON and output it to a file:

```PowerShell
ConvertTo-Json -InputObject $Printers -Depth 4 | Out-File -FilePath $DataPath
```

Getting the data is honestly the hardest part. I'll create a follow up post soon that will cover turning that data in to a dashboard using UD. 