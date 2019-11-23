If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))

{   
$arguments = "& '" + $myinvocation.mycommand.definition + "'"
Start-Process powershell -Verb runAs -ArgumentList $arguments
Break
}


#Stop-service -name iisadmin,was,w3svc 

$location = ("d:\acsa.org\" )



Set-Location $location

    #Changing  to the acsa.org pages
    
    
       $confiles = Get-ChildItem $location -Recurse | Where-Object {$_.name  -Like "*config*"}  | ForEach-Object { $_.FullName } 

        #editing files 
        foreach ($FileName in $confiles) 
        {
           $FileOriginal = Get-Content $FileName
           [String[]]$FileModified = @()
           [String]$wstring = '${env_name}'
           [String]$fstring = 'www'
          # [String]$f2string = 'bindingInformation'
        
           Foreach ($Line in $FileOriginal) 
           {
               if (($Line -match "$fstring") )
               {  
               $FileModified +=  $Line -replace "$fstring","$wstring"  }
               
                
               else
               { $FileModified += $Line }
           }
           
           # Updating file
           Set-Content $FileName $FileModified -Force
       }

Start-service -name iisadmin,was,w3svc    

Write-Host "The end of the script" 

#Start-Sleep -s 65