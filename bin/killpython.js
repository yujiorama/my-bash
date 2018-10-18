// schtasks /create /tn "Start WSL Sshd" /tr c:\Users\y.okazawa\bin\wsl-sshd.js /sc onlogon
// schtasks /run /TN "Start Wsl Sshd"
var ws = new ActiveXObject("WScript.Shell");
ws.Run("C:\\Windows\\System32\\taskkill.exe /F /IM python.exe", 0);
