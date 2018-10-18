Invoke-WebRequest -Uri https://chocolatey.org/install.ps1 -OutFile "$env:USERPROFILE\bin\installer.ps1"
iex "$env:USERPROFILE\bin\installer.ps1"
rm "$env:USERPROFILE\bin\installer.ps1"
