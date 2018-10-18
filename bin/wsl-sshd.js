// schtasks /create /tn "Start WSL Sshd" /tr c:\Users\y.okazawa\bin\wsl-sshd.js /sc onlogon
// schtasks /run /TN "Start Wsl Sshd"
var ws = new ActiveXObject("WScript.Shell");
ws.Run("C:\\Windows\\System32\\wsl.exe sudo service ssh restart", 0);
