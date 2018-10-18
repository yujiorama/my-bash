Invoke-WebRequest -Uri https://get.scoop.sh -OutFile "$env:USERPROFILE\bin\installer.ps1"
iex "$env:USERPROFILE\bin\installer.ps1"
rm "$env:USERPROFILE\bin\installer.ps1"
