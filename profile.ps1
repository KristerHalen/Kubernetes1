"You can use following variables in a prompt or a script:"
"`$vsPath - Your path to Visual Studio root folder"
"Use following aliases:"
"cvsp - clear all visual studio build folders"
"mysql - start mysql workbench"
"nats - run nats command locally"

#Run MySql Workbench:
function mysqlworkbench
{
	Start-Process "C:\Program Files\MySQL\MySQL Workbench 8.0 CE\MySQLWorkbench.exe"
}
Set-Alias mysql mysqlworkbench

#Run nats jetstream command locally:
function natsfunc
{
	c:\apps\nats.exe $args
}
Set-Alias nats natsfunc

function Clear-VSProject
{
	$BaseDir = Get-Location
	$NameToFind = "node_modules, bin, obj"
	"Searching for $NameToFind in $BaseDir"
	
	@("node_modules", "bin", "obj") 
		| %{ (Get-ChildItem -Path $BaseDir -Filter $_ -Recurse -Directory).FullName}
		| %{ 
				if($_ -eq $null)
				{
					"Not found"
				}
				elseif (Test-Path $_) {
					"Removing $_"
					Remove-Item $_ -Force -Recurse
				}
				else
				{
					"Folder Doesn't Exist $_"
				}
			}
}
Set-Alias cvsp Clear-VSProject

#https://intellitect.com/enter-vsdevshell-powershell/
$vsPath = &"C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe" -latest -prerelease -property installationpath
Import-Module (Join-Path $vsPath "Common7\Tools\Microsoft.VisualStudio.DevShell.dll")
Enter-VsDevShell -VsInstallPath $vsPath -SkipAutomaticLocation
