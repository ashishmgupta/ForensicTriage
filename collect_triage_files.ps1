$username = Read-host("Enter the username")
$drivename = Read-host("Enter the drive name to copy the files from")
if(!$drivename.EndsWith(":"))
{
    $drivename = $drivename + ":"
}
$output_loc = Read-Host -Prompt "Enter the location to store the retrieved files/settings or hit enter to save to current location."

$sw = [Diagnostics.Stopwatch]::StartNew()

if(!$output_loc)
{
    $output_loc = Get-Location
}
$output_loc = Join-Path $output_loc -childpath "triage_files"
 if (!(Test-Path -Path $output_loc))
 {
    New-Item -ItemType Directory -Force -Path $output_loc
 }

 $output_loc  = Join-Path $output_loc -ChildPath $(get-date -f MM-dd-yyyy_HH_mm_ss) 

 #destination folders
 $dest_registry_hives = join-path $output_loc -ChildPath "registry_hives"
 $dest_prefetch_files = join-path $output_loc -ChildPath "prefetch_files"
 $dest_sru_files = join-path $output_loc -ChildPath "sru_files"
 $dest_lnk_files = join-path $output_loc -ChildPath "lnk_files"
 $dest_event_log_files = join-path $output_loc -ChildPath "event_log_files"
 $dest_log_files  = join-path $output_loc -ChildPath "windows_log_files"
 $dest_scheduled_task_files = join-path $output_loc -ChildPath "scheduled_tasks_files"
 $dest_amchache_files = join-path $output_loc -ChildPath "amcache_files"
 $dest_thumbs_db_files = join-path $output_loc -ChildPath "thumbs_db_files"
 $dest_windows_search_files  = join-path $output_loc -ChildPath "windows_search_files"
 $dest_app_data_files = join-path $output_loc -ChildPath "appdata_files"

 New-Item -ItemType Directory -Force -Path $dest_registry_hives
 New-Item -ItemType Directory -Force -Path $dest_prefetch_files
 New-Item -ItemType Directory -Force -Path $dest_sru_files
 New-Item -ItemType Directory -Force -Path $dest_lnk_files
 New-Item -ItemType Directory -Force -Path $dest_event_log_files
 New-Item -ItemType Directory -Force -Path $dest_log_files
 New-Item -ItemType Directory -Force -Path $dest_scheduled_task_files
 New-Item -ItemType Directory -Force -Path $dest_amchache_files
 New-Item -ItemType Directory -Force -Path $dest_thumbs_db_files
 New-Item -ItemType Directory -Force -Path $dest_app_data_files
 New-Item -ItemType Directory -Force -Path $dest_windows_search_files


#Copy LNK files
Write-Output "Copy LNK files"
$AppData_Folder_Path = $drivename + "\users\"+$username+"\AppData\Roaming\Microsoft\Windows\Recent"
#Robocopy $AppData_Folder_Path $dest_lnk_files /MIR /S /XJ /A-:SH /R:1 /W:3
##Copy-Item -Path $AppData_Folder_Path -Filter "*.lnk" -Recurse -Destination $dest_lnk_files

 
 #Copy registry hives
 $source_registry_hives = $drivename + "\windows\system32\config"
 #robocopy.exe $source_registry_hives $dest_registry_hives /S 
 #SAM, SYSTEM, SOFTWARE, SECURITY
 ##robocopy.exe $source_registry_hives $dest_registry_hives "SAM"
 ##robocopy.exe $source_registry_hives $dest_registry_hives "SYSTEM"
 ##robocopy.exe $source_registry_hives $dest_registry_hives "SOFTWARE"
 ##robocopy.exe $source_registry_hives $dest_registry_hives "SECURITY"


 #Copy NTUSER.DAT
 $NTUSER_DAT_Folder = $drivename + "\users\"+$username
 ##robocopy $NTUSER_DAT_Folder $dest_registry_hives "NTUSER.DAT"

 #Copy UsrClass.DAT
 $UsrClass_DAT_Folder = $drivename + "\users\"+$username+"\AppData\Local\Microsoft\Windows"
 ##robocopy $UsrClass_DAT_Folder $dest_registry_hives "UsrClass.dat"


 #Copy AppData
 $AppData_Folder_Path = $drivename + "\users\"+$username+"\AppData"
 Robocopy $AppData_Folder_Path $dest_app_data_files /MIR /S /XJ /A-:SH /R:1 /W:3


 #copy prefetch files
 $prefetch_files = $drivename + "\windows\prefetch"
 Robocopy  $prefetch_files $dest_prefetch_files /MIR /S /XJ /A-:SH /R:1 /W:3

 #copy SRU files
 $sru_files = $drivename + "\windows\system32\sru"
 Robocopy $sru_files $dest_sru_files /MIR /S /XJ /A-:SH /R:1 /W:3

 #copy setupapi.dev.log
 $setupapi_dev_log_folder = $drivename + "\windows\inf"
 Robocopy $setupapi_dev_log_folder $output_loc "setupapi.dev.log"
 
 #copy windows log files
 $windows_logs_folder = $drivename + "\windows\system32\logfiles"
 Robocopy $windows_logs_folder $dest_log_files /MIR /S /XJ /A-:SH /R:1 /W:3

 #Copy RecentFileCache or Amchache.hve
 $Amchache_folder = $drivename + "\windows\appcompat\Programs"
 Robocopy $Amchache_folder $dest_amchache_files  /MIR /S /XJ /A-:SH /R:1 /W:3

 #Copy windows scheduled tasks
 $scheduled_tasks_folder = $drivename + "\windows\tasks"
 Robocopy $scheduled_tasks_folder $dest_scheduled_task_files /MIR /S /XJ /A-:SH /R:1 /W:3


 #Copy windows serach database
 $windows_serach_database_folder = $drivename + "\ProgramData\Microsoft\Search\Data\Applications\Windows"
 Robocopy $windows_serach_database_folder $dest_windows_search_files /MIR /S /XJ /A-:SH /R:1 /W:3



 #Copy event logs files
 $event_logs_folder = $drivename + "\windows\System32\Winevt\Logs"
 Robocopy $event_logs_folder $dest_event_log_files /MIR /S /XJ /A-:SH /R:1 /W:3
 
 $sw.stop()
 $sw.elapsed

 <#
 
 Copy NTUSER.DAT and UsrClass.dat
 function copy_ntuser_usrclass_files
{
    $users_folder = $drivename + "\users"
    foreach ($item in Get-ChildItem -Force $users_folder)
    {
        if (Test-Path $item.FullName -PathType Container) 
        {
            $NTUSER_DAT_Path = $item.FullName 
            if(Test-Path $NTUSER_DAT_Path)
            {
                robocopy $NTUSER_DAT_Path $dest_registry_hives "NTUSER.DAT" /MIR /S /XJ /A-:SH
            }
            $UsrClass_DAT_Path = Join-Path $item.FullName -ChildPath "\AppData\Local\Microsoft\Windows"
            
            if(Test-Path $UsrClass_DAT_Path)
            {
                robocopy $UsrClass_DAT_Path $dest_registry_hives "UsrClass.dat" /MIR /S /XJ /A-:SH
            }

        } 
    }
}

#copy_ntuser_usrclass_files
 #Copy .LNK files



<#
LNK
*lnk

WIndows eventlogs
*.evtx

Registry Hives
c:\windows\system32\config\SYSTEM
c:\windows\system32\config\SAM
c:\windows\system32\config\SECURITY
NTUSER.DAT
UsrClass.dat

Appdata
c:\users\<username>\appdata

Prefetch
c:\windows\prefetch

SRU
c:\windows\system32\sru

setupapi.dev.log
c:\windows\inf\setupapi.dev.log

windows log files
c:\windows\system32\logfiles

RecentFileCache or Amchache.hve
c:\windows\appcompat\Programs

windows scheduled tasks
c:\windows\tasks

Thumbs db
thumbs.db

Windows serach database
c:\PRogramData\Microsoft\Search\Data\Applications\Windows




#>


