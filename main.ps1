param(
    [Parameter(Mandatory = $true, Position = 0 )]
    $sourcePath,
    [Parameter(Mandatory = $false, Position = 1 )]
    $patchPath = ".\patch"
)

function Merge-Ini {
    param (
        $srcPath,
        $patchPath
    )
    $srcINI = Get-IniContent $srcPath
    $modINI = Get-IniContent $patchPath

    $modINI.Keys | % {
        $key1 = $_
        Write-Host "[$key1]"
        if ($srcINI.Contains($key1)) {
            $modINI[$key1].Keys | % {
                $key = $_
                $newVal = $modINI[$key1][$key]
                $oldVal = $srcINI[$key1][$key]
                if (!$oldVal) {
                    $oldVal = "[UNDEFINED]"
                }
                Write-Host "$key"
                Write-Host "`t$oldVal" -ForegroundColor Red
                Write-Host "`t$newVal" -ForegroundColor Green
                $srcINI[$key1][$key] = $newVal
            }
        }
    }
    $srcINI
}

function Get-Header {
    param (
        $encLog
    )
    $header = $encLog  | ? { $_ -match "Header:*" } | Select-Object -First 1
    $substring = "Lineage2Ver"
    $i = $header.IndexOf($substring)
    $header.Substring($i + $substring.Length).TrimEnd("`"")
}

Clear-Host
Push-Location $PSScriptRoot

if (!(Test-Path .\dst)) {
    mkdir .\dst >> $null
}

Get-ChildItem .\dst | Remove-Item -Force
Get-ChildItem -Path $patchPath | % {
    $patchINI = $_
    $srcINI = Get-ChildItem -LiteralPath $sourcePath | ? { $_.Name -eq $patchINI.Name }
    if ($srcINI) {
        Write-Host "Found INI to patch $($srcINI.FullName)" -ForegroundColor Yellow
        $temp = ".\dst\dec-$($srcINI.Name).ini"

        $encLog = .\lib\l2encdec\l2encdec.exe -s $srcINI.FullName $temp
        $header = Get-Header $encLog
        $outputFilePath = ".\dst\$($srcINI.Name)"
        if ($header.Contains("corrupted header")) {
            $ini = Merge-Ini $srcINI.FullName $patchINI.FullName
            $ini | Out-IniFile -FilePath $outputFilePath -Encoding UTF8 -Force
        }
        else {
            $ini = Merge-Ini $temp $patchINI.FullName
            $ini | Out-IniFile -FilePath $temp -Encoding UTF8 -Force
            .\lib\l2encdec\l2encdec.exe -h $header $temp $outputFilePath >> $null
            Remove-Item $temp
        }
        Write-Host "Patched INI: $outputFilePath" -ForegroundColor Yellow
    }
}
Pop-Location