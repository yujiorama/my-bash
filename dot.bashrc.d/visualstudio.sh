# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

msbuild19() {
    C:/Program\ Files\ \(x86\)/Microsoft\ Visual\ Studio/2019/BuildTools/MSBuild/Current/Bin/MSBuild.exe "$@"
}

msbuild() {
    C:/Program\ Files\ \(x86\)/Microsoft\ Visual\ Studio/2017/Professional/MSBuild/15.0/Bin/MSBuild.exe "$@"
}

# http://putridparrot.com/blog/setup-powershell-to-use-the-visual-studio-paths-etc/
# %comspec% /k ""C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\VsMSBuildCmd.bat" & msbuild"
