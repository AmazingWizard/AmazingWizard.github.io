---
layout: post
title: Printer Dashboard Using UD
Date: 2017-11-17 23:21:25
---

![]({% site.baseurl %}/assets/img/2017-11-17-Printer-Dashboard-Using-UD--toner.jpg)

<cite>Credit: [Max Wheeler](https://www.flickr.com/photos/makenosound/2557531332)</cite>

Everyone hates printers for one reason or another. Some of us are unfortunate enough to not only have to manage the technical side of printers, but also the mundane side of printers: Restocking Toner.

After a short time of manually checking in on printer toner levels, I decided there had to be a better way. We use [Papercut](https://www.papercut.com/) for doing all kinds of printer management, but one thing it seemed to lack was a straightforward overview of toner across all your printers.

So I started doing some research and figured PaperCut must be getting the toner information via <abbr title="Simple Network Management Protocol">SNMP</abbr>. After some reading, I found there is a Com Object that can be used to make SNMP calls, which can be used against printers. After much tinkering, I had a script that could pull printers from our print server, and loop through them making SNMP calls for toner levels. 

``` Powershell

# Com Object for making SNMP calls
$SNMP = new-object -ComObject olePrn.OleSNMP

# Printer objects from our print server
$All_Printers = get-printer -ComputerName $Config.PrintServer

# Array of printers to output, which will contain toner data, and some data from our print server.
$Printers = New-Object System.Collections.ArrayList

foreach ($Printer in $All_Printers) {
    # Port name from the print server. You might have to clean up your port names if you have dupes or you've named them other then the IP address.
    $Address = $Printer.PortName 

    #Name from the Print Server
    $Name = $Printer.Name

    # This could be better, but we check if the printer is online, if not we set its online state to false. 
    if (!(Test-Connection $address -Quiet -Count 1)) {$onlineState = $False}

    # If the printer is online, we get the toner data. 
    if (Test-Connection $address -Quiet -Count 1) {
        $onlineState = $True

        # The Open method takes 4 params. Host, Community, Retry, and Timeout. 
        $SNMP.Open($Address, "public", 2, 3000)

        # The Get method takes one param, a string representing the OID you want to query. This gets the printer type, in this case, HP M553DN. 
        $printertype = $snmp.Get(".1.3.6.1.2.1.25.3.2.1.3.1")

        # This is where things get weird. There are two OIDs you need to get, one I've called Toner Volume, more accuretly, toner maximum? And then the Current Volume. These are not small numbers if I remember correctly. Lastly, I calculate a percentage based on those two numbers so we can get some data worth using. 

        $black_tonervolume = $snmp.get("43.11.1.1.8.1.1")
        $black_currentvolume = $snmp.get("43.11.1.1.9.1.1")
        [int]$black_percentremaining = ($black_currentvolume / $black_tonervolume) * 100

        $cyan_tonervolume = $snmp.get("43.11.1.1.8.1.2")
        $cyan_currentvolume = $snmp.get("43.11.1.1.9.1.2")
        [int]$cyan_percentremaining = ($cyan_currentvolume / $cyan_tonervolume) * 100

        $magenta_tonervolume = $snmp.get("43.11.1.1.8.1.3")
        $magenta_currentvolume = $snmp.get("43.11.1.1.9.1.3")
        [int]$magenta_percentremaining = ($magenta_currentvolume / $magenta_tonervolume) * 100

        $yellow_tonervolume = $snmp.get("43.11.1.1.8.1.4")
        $yellow_currentvolume = $snmp.get("43.11.1.1.9.1.4")
        [int]$yellow_percentremaining = ($yellow_currentvolume / $yellow_tonervolume) * 100
    }

    # I then store that data in a PSCustomObject, and add it to our ArrayList, and then close out the SNMP connection. There is a helper function here called ReturnZeroIfNegitive (I should fix that spelling) that does what it says. I'm not 100% sure why, and I'm sure someone can tell me, but sometimes you'll get a result of -2 or -3, and this just zeros that out. 

    $PrinterData = [PSCustomObject] @{
        "Name"        = $Name
        "Type"        = $printertype
        "Address"     = $Address
        "OnlineState" = $onlineState
        "Toner"       = @{
            "Name"    = "Toner Levels"
            "Max"     = 100 # This is a hacky workaround for setting min and max values in UD bar charts. 
            "Min"     = 0
            "Black"   = ReturnZeroIfNegitive -Data $black_percentremaining
            "Yellow"  = ReturnZeroIfNegitive -Data $Yellow_percentremaining
            "Cyan"    = ReturnZeroIfNegitive -Data $Cyan_percentremaining
            "Magenta" = ReturnZeroIfNegitive -Data $Magenta_percentremaining

        }
    }

    $Printers.Add($PrinterData)

    $SNMP.Close()
}
```

SNMP Is a magical nightmare of non-standardization, and some manufacturers are better about getting you the information you need vs others. Some places, like Ricoh, keep their SNMP OID information behind a paywall. So I basically got lucky with the HP printers I manage. However, that's not to say its simple or makes sense, as you can clearly see above. 

When all is said and done, we convert the array to JSON and output it to a file:

``` Powershell
ConvertTo-Json -InputObject $Printers -Depth 4 | Out-File -FilePath $DataPath
```
