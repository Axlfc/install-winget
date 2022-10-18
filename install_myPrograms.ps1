function Populate-Windows {
	Param(
		[Parameter(Mandatory=$true,Position=0)] [String]$ProgramName
	)
	winget install -e --id $ProgramName
}winget install -e --id EpicGames.EpicGamesLauncher
$pop_apps = "Mozilla.Firefox", 
"EpicGames.EpicGamesLauncher", 
"Spotify.Spotify",
"Bandisoft.Honeyview",
"VideoLAN.VLC",
"Valve.Steam",
"PeterPawlowski.foobar2000",
"Nvidia.GeForceExperience",
"Nvidia.CUDA",
"RiotGames.LeagueOfLegends.EUW",
"Notepad++.Notepad++",
"EliasFotinis.DeskPins",
"Discord.Discord",
"Adobe.Acrobat.Reader.64-bit",
"TheDocumentFoundation.LibreOffice",
"Autodesk.DesktopApp",
"Ghisler.TotalCommander",
"Python.Python.3.8",
"TortoiseGit.TortoiseGit",
"GitHub.GitLFS",
"Git.Git",
"Oracle.VirtualBox",
"Transmission.Transmission",
"calibre.calibre",
"Mozilla.Thunderbird",
"Google.Drive",
"TeamViewer.TeamViewer",
"RealVNC.VNCServer",
"RealVNC.VNCViewer",
"Audacity.Audacity",
"BlenderFoundation.Blender"

foreach ($pop_app in $pop_apps)
{
	Write-Host $pop_app
	Populate-Windows $pop_app
}