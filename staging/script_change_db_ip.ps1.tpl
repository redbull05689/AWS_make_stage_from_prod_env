If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))

{   
$arguments = "& '" + $myinvocation.mycommand.definition + "'"
Start-Process powershell -Verb runAs -ArgumentList $arguments
Break
}

Stop-service -name iisadmin,was,w3svc 
$collection = @( "D:\acsa prod\MemberProfile\UI\" , "D:\AMS Stage\AMS API\"  , "D:\ams.acsa.org\API\"  , "D:\ams.acsa.org\UI\" , 
"DemoDev\NewDevQA\API\" ,"D:\DemoDev\NewDevQA\UI\" , "D:\DemoDev\NewDevQA\API\" , "D:\NewACSAService\ACSA-Service-Publish\ACSA-Service-Publish\ACSAService\" ,
 "D:\reports.acsa.org\API\", "D:\reports.acsa.org\UI\" , "D:\WinService\ACSALeadershipDataService\Debug\" , "D:\WinService\AMSMonthEndReportService\Debug\",
 "D:\WinService\SASS BACKUP\STABLE\Debug\" , "D:\WinService\SASSChangesService\Debug\" , "D:\WinService\ACSAWinService\" , "D:\WinService\ACSANightlyService\Debug\" ,
  "D:\beta.acsa.org\beta.api\" , "D:\beta.acsa.org\beta.profileui\" , "D:\WinService\MarketingMembersService\Debug\" , 
  "C:\Users\Administrator\Downloads\AMSUpdatedRecordService\AMSUpdatedFileService\bin\Debug\")

foreach ($location in $collection) 
{

Set-Location $location

    #Changing  db ip to dns name
    
    
       $confiles = Get-ChildItem $location -Recurse | Where-Object {$_.name  -Like "*config*"}  | ForEach-Object { $_.FullName } 

        #editing files 
        foreach ($FileName in $confiles) 
        {
           $FileOriginal = Get-Content $FileName
           [String[]]$FileModified = @()
           [String]$wstring = '${db_ip_private}'
           [String]$fstring = 'PROD_IP'
           #[String]$f2string = 'bindingInformation'
        
           Foreach ($Line in $FileOriginal) 
           {
               if (($Line -match "$fstring"))
               {  
               $FileModified +=  $Line -replace "$fstring","$wstring"  }
               
                
               else
               { $FileModified += $Line }
           }
           
           # Updating file
           Set-Content $FileName $FileModified -Force
       }

       }

#Change theconnection SSRS
rsconfig -c -s ${db_ip_private} -i SQL2014 -d 'ReportServerDemo' -a SQL -u Dmitrya -p '******' -t

    Start-service -name iisadmin,was,w3svc
    Stop-Service *ReportSer*
    Start-Service *ReportSer*
    Write-Host "The end of the script" 