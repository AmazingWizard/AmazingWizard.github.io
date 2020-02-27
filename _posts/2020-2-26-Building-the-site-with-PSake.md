---
layout: post
title: Building the site with PSake
date: 2020-2-26
auther: Tom
categories:
    - "PowerShell"
    - "Coding"
---

So I've not only installed VS Code on my **ASUS C434T Chromebook** but I've also managed to install PowerShell Core on said Chromebook. See my previous post for details. 

But because I've installed PSCore on my Chromebook, that means I can use some of the _Cool Tools_ built around PowerShell. 

If you hit the GitHub Link on the left and dig into this repo, you'll find a `build.ps1` file and a `pasake.build.ps1` file. 

PSake is a nice task runner for Powershell that reminds me a lot of GRUNT. People smarter then me use it to test their module builds using something like Pester, or fire off their CI/CD process so long as the tests and builds succeed. 

Personally, I like using it for quick function running and repo management type stuff. I do use it to build some modules from multiple source files, and that’s not unlike how I'm using it here. 

In my `psake.build.ps1` I've created two functions that I use to automatically figure out if I've added a "Category" to a post that doesn't already have a markdown file under the `_category` directory and if I have, it creates that category file. 

```PowerShell
function Get-Categories {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory)]
        [string[]]
        $Path
    )
    
    begin {
        
    }
    
    process {
        foreach ($item in $path) {
            $content = Get-Content -Path $item -Raw
            $content -match '(?ms)---(.+?)---.+?' > $null
            $frontMatter = ConvertFrom-Yaml -Yaml $matches[0]
            $categories = $frontMatter.categories
            write-output $categories
        }
        
    }
    
    end {
        
    }
}
```
This was a tricky one to figure out. My Regex-Fu is weak and I'm still not 100% sure how `(?ms)---(.+?)---.+?` grabs the Front Matter of my posts, but it does! From there, I use the module `Powershell-Yaml` to convert the Front Matter into a Hashtable, making it easy to manipulate. I then spit out the categories array to do stuff with later. 

```PowerShell
function New-Category {
    [CmdletBinding()]
    param (
        # Name
        [Parameter(Mandatory)]
        [String]
        $Name
    )
    
    begin {
        
    }
    
    process {
        $name = $name.ToLower()
        $String= @"
---
tag: $name
permalink: "/category/$name"
---
"@
        Add-Content "./_category/$name.md" -Value $string
        
    }
    
    end {
        
    }
}
```
This function is pretty simple, it takes in a string and then fills in the blanks and creates the MD file needed in the `_category` DIR. Here is how all this gets used. 

In my PSake file, I've created a new task called `makeCategories`. 

```PowerShell
task makeCategories {
    $Posts = Get-ChildItem -Path $postsDIR

    $postCategories = @()
    ForEach ($post in $posts) {
        $postCategories = $postCategories += Get-Categories -Path $post.fullname
    }
    $postCategories = $postCategories | Select-Object -Unique
```
So in this section I take in all the posts in my `_post` dir and use `Get-Categories` to spit out the categories from each markdown file into an array. 

```PowerShell
    $Categories = Get-ChildItem -Path $categoryDIR

    $currentCategories = @()
    ForEach ($category in $Categories){
        $currentCategories = $currentCategories += $category.basename
    }
```
Then I get each category file in the `_category` directory and return its base name into a list. 
```PowerShell
    $Unique = Compare-Object -ReferenceObject $currentCategories -DifferenceObject $postCategories -PassThru

    foreach ($item in $Unique) {
        New-Category -Name $item
    }
}
```
Then Lastly I compare those two lists and return only the post categories that do not have category files. Then I loop through that list and use the `New-Category` command to create the new category files. 

Now I just need to make sure I run this command after every post. 

I could create a new task that depends on this one called `commit` that calls Git commands to commit my current changes, but only after the `makeCategories` task is run. 

Maybe you'll get something useful out of this, who knows!

Later, ✌
