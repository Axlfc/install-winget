Set-ExecutionPolicy RemoteSigned

Write-Host "DO: Installing WSL2"
# https://thomasward.com/wsl2-x11/ <- Reference

$MyLink = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -NoRestart
Invoke-WebRequest -Uri $MyLink -OutFile wsl2-linux-kernel-installer.msixbundle
Write-Host "WSL2 installer downloaded, launching installer."
Add-AppxPackage -Path .\wsl2-linux-kernel-installer.msixbundle -ForceUpdateFromAnyVersion -ForceTargetApplicationShutdown
#.\wsl2-linux-kernel-installer.msixbundle
wsl --set-default-version 2
#winget install -s msstore "Ubuntu"
#winget install -s msstore "Debian"
wsl --install -d "Ubuntu"


Write-Host "DO: Configuring Windows firewall to only allow connections to the X11 display server from the WSL2 instance running on your computer."

Write-Host "Running command in WSL2:"
# This command isn't probably going to work.
wsl bash -c 'source ~/.profile;
LINUX_IP=$(ip addr | awk "/inet / && !/127.0.0.1/ {split($2,a,"/"); print a[1]}");
WINDOWS_IP=$(ip route | awk "/^default/ {print $3}");
powershell.exe -Command "Start-Process netsh.exe -ArgumentList \"advfirewall firewall add rule name=X11-Forwarding dir=in action=allow program=%ProgramFiles%\VcXsrv\vcxsrv.exe localip=$WINDOWS_IP remoteip=$LINUX_IP localport=6000 protocol=tcp\" -Verb RunAs"'
Write-Host "Firewall command has been runned within WSL2."


Write-Host "DO: Installing an X11 display server, VcXsrv"
$MyLink = "https://downloads.sourceforge.net/project/vcxsrv/vcxsrv/1.20.14.0/vcxsrv-64.1.20.14.0.installer.exe?ts=gAAAAABiTrwrBkBOjaym69qeA-PTdoKJ8GqUA1U5YqyxN29ffncDhntgSgKgEV-szjqkRmWySWYswNudLJoo9ewwDJnUgM8dHw%3D%3D&r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fvcxsrv%2Ffiles%2Flatest%2Fdownload"
Invoke-WebRequest -Uri $MyLink -OutFile VcXsrv-Windows-X-Server.msixbundle
Write-Host "VcXsrv Windows X Server installer downloaded, launching installer."
Add-AppxPackage -Path .\VcXsrv-Windows-X-Server.msixbundle -ForceUpdateFromAnyVersion -ForceTargetApplicationShutdown
#.\VcXsrv-Windows-X-Server.msixbundle


Write-Host "Adding VcXsrv to autostart (not working)"
$StartupAllUsersPath = "%SystemDrive%\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
Write-Host "path: $StartupAllUsersPath"
$VcXsrvStartupCondition = '"%ProgramFiles%\VcXsrv\vcxsrv.exe" :0 -multiwindow -clipboard -wgl -ac'
Write-Host "startup: $VcXsrvStartupCondition"
Write-Host "DON'T: Create desktop shortcut pointing to VcXsrv"
Write-Host "DON'T: Move desktop shortcut to Windows AutoStart folder"


Write-Host "Configuring WSL2 to auto-update the firewall rule when IP addresses change and know how to send graphical output to VcXsrv."
# Append the following script to WSL2's ~/.profile

Write-Host "echo command appending to WSL2's profile"
# The following line might probably not run as expected
wsl bash -c 'echo "LINUX_IP=$(ip addr | awk "/inet / && !/127.0.0.1/ {split($2,a,"/"); print a[1]}")
WINDOWS_IP=$(ip route | awk "/^default/ {print $3}")
FIREWALL_WINDOWS_IP=$(netsh.exe advfirewall firewall show rule name=X11-Forwarding | awk "/^LocalIP/ {split($2,a,"/");print a[1]}")
FIREWALL_LINUX_IP=$(netsh.exe advfirewall firewall show rule name=X11-Forwarding | awk "/^RemoteIP/ {split($2,a,"/");print a[1]}")

if [ "$FIREWALL_LINUX_IP" != "$LINUX_IP" ] || [ "$WINDOWS_IP" != "$FIREWALL_WINDOWS_IP" ]; then
	powershell.exe -Command "Start-Process netsh.exe -ArgumentList \"advfirewall firewall set rule name=X11-Forwarding new localip=$WINDOWS_IP remoteip=$LINUX_IP \" -Verb RunAs"
fi

DISPLAY="$WINDOWS_IP:0"
LIBGL_ALWAYS_INDIRECT=1
export DISPLAY LIBGL_ALWAYS_INDIRECT" >> ~/.profile'

Write-Host "Enjoy X11 forwarding from WSL2 to Windows."