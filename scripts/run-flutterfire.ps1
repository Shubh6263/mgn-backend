# Run flutterfire without fixing PATH permanently
$pubBin = "$env:LOCALAPPDATA\Pub\Cache\bin"
Set-Location (Join-Path $PSScriptRoot "..\medglobalnetwork")
dart pub global run flutterfire_cli:flutterfire @args
