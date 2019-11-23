# If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))

# {   
# $arguments = "& '" + $myinvocation.mycommand.definition + "'"
# Start-Process powershell -Verb runAs -ArgumentList $arguments
# Break
# }

#Stop-service -name iisadmin,was,w3svc 

$collection = @( "c:\Windows\System32\inetsrv\config\" )


foreach ($location in $collection) 
{
Set-Location $location

    #Changing  to the acsa.org pages
    
    
       $confiles = Get-ChildItem $location -Recurse | Where-Object {$_.name  -Like "*config*"}  | ForEach-Object { $_.FullName } 

        #editing files 
        foreach ($FileName in $confiles) 
        {
           $FileOriginal = Get-Content $FileName
           [String[]]$FileModified = @()
           [String]$wstring = '${env_name}.acsa.org'
           [String]$fstring = 'acsa.org'
           [String]$f2string = 'bindingInformation'
        
           Foreach ($Line in $FileOriginal) 
           {
               if (($Line -match "$fstring") -And ($Line -match "$f2string"))
               {  
               $FileModified +=  $Line -replace "$fstring","$wstring"  }
               
                
               else
               { $FileModified += $Line }
           }
           
           # Updating file
           Set-Content $FileName $FileModified -Force
       }
}

#Start-service -name iisadmin,was,w3svc 
Write-Host "The end of the script" 