Get-ChildItem -Path . -File | ForEach-Object {
    if ($_.BaseName -ne "MediaOrganizer") {
        $folderName = $_.BaseName
        New-Item -Path $folderName -ItemType Directory -Force | Out-Null
        Move-Item -Path $_.FullName -Destination $folderName
    }
}
