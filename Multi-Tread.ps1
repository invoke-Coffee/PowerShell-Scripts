

#-------------------------------------
#Define Paramaters




#Throttling Parameters
$MaxActiveThreads = '200'
$PingTimeout = 400

#Defining mis vars
$Results = @() 

$computers = import-csv C:\temp\Book1.csv


#Define Function for Jobs
$Func1 = {function Get-ComputerInfo {
Param ($computer, $PingTimeout)

#test connection to workstation with ICMP ping
$Ping = Test-Connection -ComputerName $computer.ipv4address -count 4 
#Caculate Average Response time
$computer.ResponseTime = $null
$Computer.ResponseTime = ($Ping | Measure-Object -Property responsetime -Average).average

#halt if Workstaion is not avalible or is connected over a high latancy link
if(($Computer.ResponseTime -lt $PingTimeout) -and ($computer.ResponseTime -ne $null )){
    $Computer.contactTime = Get-date
    
   #Do stuff here
}
$Computer
}
}#end $func1


#start execution


#clear any running Jobs
Get-Job | remove-job -Force



# Start Jobs
foreach($computer in $Computers){
# limit the max number of active sessions by sleeping
if((get-job | where{$_.state -eq "Running"}).count -gt $MaxActiveThreads){
    write-host "more than $MaxActiveThreads jobs running"
    Sleep 2
    }

 #start the jobs fore each connection
  Start-job -Name $Computer.name -ArgumentList $computer   -ScriptBlock {
  param($computer)
    $computer.Online =  Test-Connection $server.ip -count 1 -Quiet
   
    }#End Job ScriptBlock
   

  }# end of foreach block
  
  
 # Wait a specific number of seconds specified by the $Countdown variable
$Countdown = 400
while((get-job | where{$_.state -eq "Running"}) -and ($CountDown -gt 1)){
    Sleep 1
    $countdown -= 1
    Write-host "waiting for jobs to finish  $countdown"
    }
  
#receive job information  and store in to the $results array
  $Jobs = Get-job
  foreach($job in $jobs){
    if($job.state -eq "Completed"){
       $JobInfo = Receive-job $job.id -keep 
       $Results += $jobinfo
       get-job $job.ID | remove-job

      }
   } 
 

$Results | Out-GridView

