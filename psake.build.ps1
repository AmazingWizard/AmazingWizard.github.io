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

properties {
    $categoryDIR = Join-Path -Path .\ -ChildPath _category
    $postsDIR = Join-Path -Path .\ -ChildPath _posts
}

task post {

}

task makeCategories {
    $Posts = Get-ChildItem -Path $postsDIR

    $postCategories = @()
    ForEach ($post in $posts) {
        $postCategories = $postCategories += Get-Categories -Path $post.fullname
    }
    $postCategories = $postCategories | Select-Object -Unique

    $Categories = Get-ChildItem -Path $categoryDIR

    $currentCategories = @()
    ForEach ($category in $Categories){
        $currentCategories = $currentCategories += $category.basename
    }

    $Unique = Compare-Object -ReferenceObject $currentCategories -DifferenceObject $postCategories -PassThru

    foreach ($item in $Unique) {
        New-Category -Name $item
    }
}