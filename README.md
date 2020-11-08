# L2INI

This repository contains script for updating `*.ini` files for **Lineage ][** client.

Folder `patch` contains example patch files.

## Prerequisites

```powershell
Install-Module -Scope CurrentUser PsIni
```

## Usage

```powershell
.\main.ps1 -sourcePath "C:\L2\system\"
.\main.ps1 -sourcePath "C:\L2\system\" -patchPath "C:\customINI"
```

*Example output:*

![image](https://user-images.githubusercontent.com/6848691/98481703-5f57d900-21fc-11eb-942c-45c65e922230.png)
