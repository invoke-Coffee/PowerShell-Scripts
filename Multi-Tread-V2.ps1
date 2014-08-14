$threads = 5

$servers = import-csv C:\temp\Book1.csv

$queue = [System.Collections.Queue]::Synchronized( (New-Object system.collections.queue) )

foreach($server in $servers){
    Write-Verbose "adding $server to the queue"
    $queue.Enqueue($server)
    }




$ServersPerThread = [int]($servers.count / $Threads) + 1

$ServersPerThread

Get-Job | remove-job -Force

while($threads -ne 0){
    
    $ServersToPasstoJob = @()
    while(($ServersToPasstoJob.count -lt $ServersPerThread) -and ($queue.count -gt 0)){
        $ServersToPasstoJob += $queue.Dequeue()
        Write-host "Dequeueing"
    }
    $ServersToPasstoJob
    write-host "-----------------------------------"
    Start-Job -Name ("Thread-" + $threads) -ArgumentList (,$ServersToPasstoJob) -ScriptBlock{
    param($ServersToPasstoJob)
       
        foreach($server in $ServersToPasstoJob){
            $server.Online =  Test-Connection $server.ip -count 1 -Quiet
            }
    $ServersToPasstoJob
    }
$threads--
}

$Countdown = 400
while((get-job | where{$_.state -eq "Running"}) -and ($CountDown -gt 1)){
    Sleep 1
    $countdown -= 1
    Write-host "waiting for jobs to finish  $countdown"
    }


  $Jobs = Get-job
  foreach($job in $jobs){
    if($job.state -eq "Completed"){
       $JobInfo = Receive-job $job.id -AutoRemoveJob -Wait | select -ExcludeProperty RunspaceId
       $Results += $jobinfo

      }
   } 

$Results | Out-GridView