---
layout: post
title: Printer Dashboard Pt 2 - Building the Dashboard
date:
---
If you havn't read [part 1](https://pome.ro/2017/11/17/Printer-Dashboard/) in this two part blog post, go ahead and give it a read. In that post we cover how to pull data using SNMP from printers on our network, and exporting that data as a JSON file that we can use as our "database". 

I like using a JSON file to store the data for a few reasons: 
1. We're not writing any data about our printers from the Dashboard. 
2. We're also not keeping any historical data about our printers (maybe in the future though!)
3. Its light, fast, and has native PowerShell functions for importing and exporting. 

## Universal Dashboard
So up front, I should mention that Universal Dashboard is not a free project. A licence is required in order to use the dashboard you build. In my opinnion its worth the $20 you need every time. You can look up more information about the licencing on the [UD website](https://poshtools.com/buy-PowerShell-pro-tools/universal-dashboard/). 

## So what is UD?
UD is a PowerShell tool used in creating nice looking, live, dashboards that run in your browser. They can be hosted in Azure or IIS, or you can run them localy from the PS1 script that drives it. There is no HTML to learn, and everything you do to build your dashboard is done using PowerShell. You can have a single page dashboard (like this printer dashboard) or have a multipage dashboard that serves many different kinds of information. 

The core of the dashboard is your `dashboard.ps1` file. I based my initial script on the example found on the [poshprotools github repo](https://github.com/adamdriscoll/poshprotools/blob/master/examples/universal-dashboard/azure-dashboard.ps1). 

Each dashboard starts with the `Start-UDDashboard`  and `New-UDDashboard` command:

```PowerShell
Start-Dashboard -Port 8080 -Content {
	New-UDDashboard -Content {
	}
}
```

There are a lot of options on `New-UDDashboard` that allow you to set colors for the page (background, menu color, font color, etc.), Set NavBar links, and page Title. 

Here is how that looks like in my [UD-PrinterDashboard](https://github.com/AmazingWizard/UD-PrinterDashboard/) repo:

```PowerShell
$Config = Import-LocalizedData -BaseDirectory $PSScriptRoot -FileName config.psd1
$FileName = $Config.FileName + ".json"
$DataPath = Join-Path -Path $Config.DataLocation -ChildPath $FileName

if ($i -eq $null) {$i = 8080}
$i++
$Colors = @{
    BackgroundColor = "#eaeaea"
    FontColor       = "Black"
}
$Printers = Get-Content "$DataPath" | ConvertFrom-Json
Start-UDDashboard -port $i -Content {
    New-UDDashboard -Title $Config.DashboardName -NavBarColor '#011721' -NavBarFontColor "#CCEDFD" -BackgroundColor "White" -FontColor "#011721" -Content {
    }
}

```

Few things to note here:
1. I refrense a Config file at the top of the script. I like doing this for most of my scripts/modules that I write. There are a lot of ways you can include a config for your script, check out [this blog post](http://ramblingcookiemonster.github.io/PowerShell-Configuration-Data/) by [RamblingCookieMonster](http://ramblingcookiemonster.github.io) for more ideas on this subject. The reason I go with `import-localizeddata` is because its native to PowerShell. 
2. The port for the dashboard when it is launched is incremented. This is to help with the testing and building process, so that you don't run into ports that are being used by previous runs of the script. 
3. There is a definition of a `$colors` object. This is used throughout the script to set a default look for most of the items we place in the dashboard. 

Then we get in to the meat of the script. There are three sections to the dashboard: 
* Tallies of toner below a threshold (5%)
*  Leaderboard for the top 5 printers with the lowest toner of the corresponding type
* Bar graphs for each printer representing the toner levels for each type the toner supports. 

I'll show you one example of each of these sections, as there is some repetition within them. 

Inside of our `New-UDDashboard` we first split each section into rows: 

```Powershell
New-UDRow {
}
```

Then in each Row we add Columns:

```Powershell
New-UDRow {
	New-UDColumn -size 3 {
	}
}
```

`New-UDColumn` takes a `-Size` param that indicates how large the column will be. This number can be between 1 and 12. So this column is 3/12 (or 1/4) the width of the screen. 
<!--stackedit_data:
eyJoaXN0b3J5IjpbMTcxMjE3MjU0Nl19
-->