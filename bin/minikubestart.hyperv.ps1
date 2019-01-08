## Confirm EnableSMB2Protocol, for mount host folder
Set-SmbServerConfiguration -EnableSMB1Protocol $False -EnableSMB2Protocol $True

Get-SmbServerConfiguration | Select-Object -Property EnableSMB1Protocol,EnableSMB2Protocol
#
# EnableSMB1Protocol EnableSMB2Protocol
# ------------------ ------------------
#              False               True
#

## Add C Drive to SMBShare, for mount host folder
New-SmbShare -Name C -ScopeName "*" -Path C:\
#
# Name ScopeName Path Description
# ---- --------- ---- -----------
# C    *         C:\
#

Get-SmbShare -Name C
#
# Name ScopeName Path Description
# ---- --------- ---- -----------
# C    *         C:\
#

## Grant to only local user on SMBShareAccess, for mount host folder
Grant-SmbShareAccess -Name C -ScopeName "*" -AccountName $env:UserDomain\$env:Username -AccessRight Full
#
# Name ScopeName AccountName             AccessControlType AccessRight
# ---- --------- -----------             ----------------- -----------
# C    *         YourDomain\YourUsername Allow             Full
#

Get-SmbShareAccess -Name C
#
# Name ScopeName AccountName             AccessControlType AccessRight
# ---- --------- -----------             ----------------- -----------
# C    *         YourDomain\YourUsername Allow             Full
#

## Confirm Default VMSwitch Name
Get-VMSwitch
#
# Name           SwitchType NetAdapterInterfaceDescription
# ----           ---------- ------------------------------
# 既定のスイッチ Internal
#