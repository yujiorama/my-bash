Invoke-WebRequest -Uri https://download.docker.com/win/edge/Docker%20for%20Windows%20Installer.exe -OutFile "$env:USERPROFILE\bin\installer.exe"
iex "$env:USERPROFILE\bin\installer.exe"
