#This script is to be run on issued laptops in preparation for long meetings.


#Function to keep things alive while waiting on other things to complete. https://gallery.technet.microsoft.com/scriptcenter/Keep-Alive-Simulates-a-key-9b05f980

<#
.Synopsis
   This is a pecking bird function, a press on the <Ctrl> key will run every 5 minues.
.DESCRIPTION
   This function will run a background job to keep your computer alive. By default a KeyPess of the <Ctrl> key will be pushed every 5 minutes.
   Please be aware that this is a short term workaround to allow you to complete an otherwise impossible task, such as download a large file.
   This function should only be run when your computer is locked in a secure location.
.EXAMPLE
   Start-KeepAlive
   Id     Name            PSJobTypeName   State         HasMoreData     Location            
   --     ----            -------------   -----         -----------     --------            
   90     KeepAlive       BackgroundJob   Running       True            localhost           

   KeepAlive set to run until 10/01/2012 00:35:03

   By default the keepalive will run for 1 hour, with a keypress every 5 minutes.
.EXAMPLE
   Start-KeepAlive -KeepAliveHours 3
   Id     Name            PSJobTypeName   State         HasMoreData     Location            
   --     ----            -------------   -----         -----------     --------            
   92     KeepAlive       BackgroundJob   Running       True            localhost           

   KeepAlive set to run until 10/01/2012 02:36:12
   
   You can specify a longer KeepAlive period using the KeepAlive parameter E.g. specify 3 hours
.EXAMPLE
   Start-KeepAlive -KeepAliveHours 2 -SleepSeconds 600
   
   You can also change the default period between each keypress, here the keypress occurs every 10 minutes (600 Seconds).
.EXAMPLE
   KeepAliveHours -Query
   Job will run till 09/30/2012 17:20:05 + 5 minutes, around 19.96 Minutes
   Job will run till 09/30/2012 17:20:05 + 5 minutes, around 14.96 Minutes
   Job will run till 09/30/2012 17:20:05 + 5 minutes, around 9.96 Minutes
   Job will run till 09/30/2012 17:20:05 + 5 minutes, around 4.96 Minutes
   Job will run till 09/30/2012 17:20:05 + 5 minutes, around -0.04 Minutes

   KeepAlive has now completed.... job will be cleaned up.

   KeepAlive has now completed.

   Run with the Query Switch to get an update on how long the timout will have to run.
.EXAMPLE
   KeepAliveHours -Query
   Job will run till 09/30/2012 17:20:05 + 5 minutes, around 19.96 Minutes
   Job will run till 09/30/2012 17:20:05 + 5 minutes, around 14.96 Minutes
   Job will run till 09/30/2012 17:20:05 + 5 minutes, around 9.96 Minutes
   Job will run till 09/30/2012 17:20:05 + 5 minutes, around 4.96 Minutes
   Job will run till 09/30/2012 17:20:05 + 5 minutes, around -0.04 Minutes

   KeepAlive has now completed.... job will be cleaned up.

   KeepAlive has now completed.
   
   The Query switch will also clean up the background job if you run this once the KeepAlive has complete..EXAMPLE
.EXAMPLE
   KeepAliveHours -EndJob
   KeepAlive has now ended...
   
   Run Endjob once you download has complete to stop the Keepalive and remove the background job.
.EXAMPLE
   KeepAliveHours -EndJob
   KeepAlive has now ended...

   Run EndJob anytime to stop the KeepAlive and remove the Job.
.INPUTS
   KeepAliveHours - The time the keepalive will be active on the system
.INPUTS
   SleepSeconds - The time between Keypresses. This should be less than the timeout of your computer screensaver or lock screen.
.OUTPUTS
   This cmdlet creates a background job, when you Query the results the status from the background job will be outputed on the screen to let you know how long the KeepAlive will run for.
.NOTES
   General notes
.COMPONENT
   This is a standlone cmdlet, you may change the keystroke to do something more meaningful in a different scenario that this was originally written.
.ROLE
   This utility should only be used in the privacy of your own home or locked office.
.FUNCTIONALITY
   Call this function to enable a temporary KeepAlive for your computer. Allow you to download a large file without sleepin the computer.

   If the KeepAlive ends and you do not run -Query or -EndJob, then the completed job will remain.

   You can run Get-Job to view the job. Get-Job -Name KeepAlive | Remove-Job will cleanup the Job.

   By default you cannot create more than one KeepAlive Job, unless you provide a different JobName. There should be no reason to do this. With Query or EndJob, you can cleanup any old Jobs and then create a new one.
#>
function Start-KeepAlive {
param (
        $KeepAliveHours = 1,
        $SleepSeconds = 300,
        $JobName = "KeepAlive",
        [Switch]$EndJob,
        [Switch]$Query,
        $KeyToPress = '^' # Default KeyPress is <Ctrl>
        # Reference for other keys: http://msdn.microsoft.com/en-us/library/office/aa202943(v=office.10).aspx
    )

begin {
    $Endtime = (Get-Date).AddHours($KeepAliveHours)
}#begin

process {
    
    # Manually end the job and stop the KeepAlive.
    if ($EndJob)
        {
            if (Get-Job -Name $JobName -ErrorAction SilentlyContinue)
                {
                    Stop-Job -Name $JobName
                    Remove-Job -Name $JobName
                    "`n$JobName has now ended..."
                }
            else
                {
                    "`nNo job $JobName."
                }
        }
    # Query the current status of the KeepAlive job.
    elseif ($Query)
        {
            try {
                    if ((Get-Job -Name $JobName -ErrorAction Stop).PSEndTime)
                        {
                            Receive-Job -Name $JobName
                            Remove-Job -Name $JobName
                            "`n$JobName has now completed."
                        }
                    else
                        {
                            Receive-Job -Name $JobName -Keep
                        }
                }
            catch
                {
                   Receive-Job -Name $JobName -ErrorAction SilentlyContinue
                   "`n$JobName has ended.."
                    Get-Job -Name $JobName -ErrorAction SilentlyContinue | Remove-Job
                }
        }
    # Start the KeepAlive job.
    elseif (Get-Job -Name $JobName -ErrorAction SilentlyContinue)
        {
            "`n$JobName already started, please use: Start-Keepalive -Query"
        }
    else
        {

            $Job = {
                param ($Endtime,$SleepSeconds,$JobName,$KeyToPress)

                "`nStarttime is $(Get-Date)"
                
                While ((Get-Date) -le (Get-Date $EndTime))
                    {
                        
                        # Wait SleepSeconds to press (This should be less than the screensaver timeout)
                        Start-Sleep -Seconds $SleepSeconds

                        $Remaining = [Math]::Round( ( (Get-Date $Endtime) - (Get-Date) | Select-Object -ExpandProperty TotalMinutes ),2 )
                        "Job will run till $EndTime + $([Math]::Round( $SleepSeconds/60 ,2 )) minutes, around $Remaining Minutes"

                        # This is the sending of the KeyStroke
                        $x = New-Object -COM WScript.Shell
                        $x.SendKeys($KeyToPress)

                    }

                try {
                        "`n$JobName has now completed.... job will be cleaned up."
                        
                        # Would be nice if the job could remove itself, below will not work.
                        # Receive-Job -AutoRemoveJob -Force
                        # Still working on a way to automatically remove the job

                    }
                Catch
                    {
                        "Something went wrong, manually remove job $JobName"
                    }


                }#Job

            $JobProperties =@{
                ScriptBlock  = $Job
                Name         = $JobName
                ArgumentList = $Endtime,$SleepSeconds,$JobName,$KeyToPress
                }

            Start-Job @JobProperties

            "`nKeepAlive set to run until $EndTime"

        }

            
}#Process


}#Start-KeepAlive


Start-KeepAlive -KeepAliveHours 3 -SleepSeconds 120


#Install Module to handle power settings.
if (Get-Module -ListAvailable -Name PolicyFileEditor) {
    Write-Host "Policy module exists"
} else {
    Write-Host "Policy module does not exist.  Installing."
	Install-PackageProvider NuGet -Force
    Import-PackageProvider NuGet -Force
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
	Install-Module PolicyFileEditor -confirm:$false
	#Get-Command –module PolicyFileEditor
    write-host "NuGet and Policy modules installed"
}


$MachineDir = "$env:windir\system32\GroupPolicy\Machine\registry.pol"

$RegPathOne = 'Software\Policies\Microsoft\Power\PowerSettings\29F6C1DB-86DA-48C5-9FDB-F2B67B1F44DA'
$RegPathTwo = 'Software\Policies\Microsoft\Power\PowerSettings\3C0BC021-C8A8-4E07-A973-6B14CBCB2B7E'
$RegPathThree = 'Software\Policies\Microsoft\Power\PowerSettings\7bc4a2f9-d8fc-4469-b07b-33eb785aaca0'

#These settings control timeouts for the screen and sleep.
$RegName = 'ACSettingIndex'
$RegData = '43200' #Original Value was 300
$RegType = 'DWord'

Set-PolicyFileEntry -Path $MachineDir -Key $RegPathOne -ValueName $RegName -Data $RegData -Type $RegType
Set-PolicyFileEntry -Path $MachineDir -Key $RegPathTwo -ValueName $RegName -Data $RegData -Type $RegType
Set-PolicyFileEntry -Path $MachineDir -Key $RegPathThree -ValueName $RegName -Data $RegData -Type $RegType

gpupdate /force

write-host "Sleeping for 30 second to let things settle."
sleep 30

#Now windows update https://marckean.com/2016/06/01/use-powershell-to-install-windows-updates/
if (Get-Module -ListAvailable -Name PSWindowsUpdate) {
    Write-Host "Update module exists"
} else {
    Write-Host "Update module does not exist.  Installing."
	Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
	Install-Module PSWindowsUpdate
	#Get-Command –module PSWindowsUpdate
    write-host "Update module installed."
}

Write-Host "Removing old update service."
Remove-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d -confirm:$false

Write-Host "Sleeping for 15s to allow cleanup time."
sleep 15

Write-Host "Adding update service."
Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d -confirm:$false

Write-Host "Sleeping for 15s to allow cleanup time."
sleep 15

Get-WUInstall –MicrosoftUpdate –AcceptAll -AutoReboot

Write-Host "Done with updates.  Needs to be rebooted."
