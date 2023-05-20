function Get-ProjectFiles {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string] $Path
    )
    
    return Get-ChildItem -Path $Path -Filter "*.csproj" -Recurse
}

function Get-PackageReferences {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string] $Path
    )
    
    return Select-Xml -Path $Path -XPath "//PackageReference" | ForEach-Object { $_.node.Include }
}

function Get-ProjectReferences {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string] $Path
    )

    return Select-Xml -Path $Path -XPath "//ProjectReference" | ForEach-Object { Split-Path $_.node.Include -leaf }
}




$ProjectFiles = Get-ProjectFiles $PSScriptRoot

if($ProjectFiles.Length -eq 0) {
    Write-Warning "Project files not found!"
    exit 1
}

foreach ($ProjectFile in $ProjectFiles) {
    $file = $ProjectFile
    $project = $ProjectFile.BaseName

    $PackagesReferences = Get-PackageReferences $file
    $ProjectReferences = Get-ProjectReferences $file

    Write-Host "`e[32mProject: $project"
    Write-Host "`tPackages:"
    $PackagesReferences | ForEach-Object { Write-Host "`t`t" $_ }
    Write-Host "`tProjects:"
    $ProjectReferences | ForEach-Object { Write-Host "`t`t" $_ }
}