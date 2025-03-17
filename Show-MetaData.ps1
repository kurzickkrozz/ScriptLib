$filePath = Read-Host "Enter full file path here"
$shell = New-Object -ComObject Shell.Application
$folder = $shell.Namespace((Get-Item $filePath).DirectoryName)
$file = $folder.ParseName((Get-Item $filePath).Name)
0..327 | ForEach-Object {
    $index = $_
    $propertyName = $folder.GetDetailsOf($null, $index)
    $propertyValue = $folder.GetDetailsOf($file, $index)
    Write-Host "$index : $propertyName = $propertyValue"
}