function Power-Goo {
    <#
    .SYNOPSIS
    Advanced Google searching utilizing PowerShell syntax and autocompletion.
    
    .DESCRIPTION
    Specify a query to be made. Browser is determined on user default.
    
    .PARAMETER contains
    Specifies the requested query.
    
    .PARAMETER notcontains
    Specifies the terms to exclude from the query, comma deliminated.

    .PARAMETER include
    Specifies the terms to include from the base query, comma deliminated.
    
    .PARAMETER Domains
    Specifies the domain to contain the query to.
    
    .PARAMETER FileType
    Specifies the requested file type extension.
    
    .PARAMETER Tail
    Requests the last n number of lines from history file.

    .PARAMETER Repeat
    Repeats a line from the history file, see Tail.

    .INPUTS
    None. You cannot pipe objects to Power-Goo.
    
    .OUTPUTS
    Outputs query as a Google search in the default browser of the user.
    
    .EXAMPLE
    PS> Power-Goo -contains stuff -notcontains things,objects -Domain github.com -FileType .ps1
    
    
    .LINK
    Online version: https://github.com/RpNull/Power-Goo
    
    .NOTES
        File Name      : Power-Goo.ps1
        Version        : v.0.1
        Author         : RpNull
        Prerequisite   : PowerShell
        Created        : 1 Aug 21
        Change Date    : 
    
    #>
       
           [CmdletBinding()]
           param (
               [Parameter(Mandatory=$false,
                           HelpMessage='Specify content to include in query.')]
               [string]$contains,
           
               [Parameter(Mandatory=$false,
                           HelpMessage='Specify content to exclude in query.')]
               [string]$notcontains,

                [Parameter(Mandatory=$false,
                           HelpMessage='Specify content to include in addition to base query.')]
               [string]$include,
       
               [Parameter(Mandatory=$false,
                           HelpMessage='Specify a specifc domain to query.')]
               [string]$Domain,

               [Parameter(Mandatory=$false,
                           HelpMessage='Specify a specifc news source to query.')]
               [string]$Source,
           
               [Parameter(Mandatory=$false,
                           HelpMessage='Specify a specifc file type  to query.')]
               [string]$FileType,

               [Parameter(Mandatory=$false,
                           HelpMessage='Repeat a previous search by index number (See -Tail or Log file)')]
               [string]$Repeat,

               [Parameter(Mandatory=$false,
                           HelpMessage='Display the last x number of lines in the log file')]
               [string]$Tail  
              
           )
           
           #Initialize and determine user browser
           BEGIN {
               $default_browser = Get-ItemPropertyValue -Path HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice\ -Name ProgId
               if ($default_browser -contains 'MSEdgeHTM'){
                   $browser = "msedge"
               }
               elseif ($default_browser -contains 'ChromeHTML') {
                   $browser = "chrome"     
               }
               elseif ($default_browser -contains 'FirefoxURL-308046B0AF4A39CB'){
                   $browser = "firefox"
               }
               else{
                   $browser = iexplore
                   Write-Host "IE? Fucks sake"
               }
               
           }
           
           PROCESS {
           $script:search_query = ''
               function Launch_Query {
                   Add-Type -AssemblyName System.Web
                   Write-Host "$script:search_query"
                   $encoded_query = [System.Web.HttpUtility]::UrlEncode("$script:search_query")
                   $query = "https://google.com/search?q=$encoded_query"
                   [system.Diagnostics.Process]::Start($browser, $query) | Out-Null
                                      
               }
               function NotContains{
                   if ($notcontains -ne [string]::Empty){
                       Write-Host "Excluding: $notcontains"
                       $notcontains = $notcontains -replace '\s',''
                       $nca = $notcontains.Split(", ")
                           foreach ($i in $nca){
                               $script:search_query += " -$i "
                           }                 
                   }   
               }
               function Include{
                   if ($Include -ne [string]::Empty){
                       Write-Host "Including: $Include"
                       $Include = $Include -replace '\s',''
                       $ina = $Include.Split(", ")
                           foreach ($i in $ina){
                               $script:search_query += " +$i "
                           }                 
                   }   
               }
               function Domains{
                   if ($Domain -ne [string]::Empty){
                       Write-Host "Site: $Domain"
                       $Domain = $Domain -replace '\s',''
                       $doa = $Domain.Split(", ")
                           foreach ($i in $doa){
                               $script:search_query += " site:$i "
                           }                 
                   }                                       
               }
               function Source{
                   if ($Source -ne [string]::Empty){
                       Write-Host "Source: $Source"
                       $Source = $Source -replace '\s',''
                       $soa = $Domain.Split(", ")
                           foreach ($i in $soa){
                               $script:search_query += " source:$i "
                           }                 
                   }                                       
               }
               function FileType{
                   if ($FileType -ne [string]::Empty){
                       Write-Host "FileType: $FileType"
                       $Filetype = $FileType -replace '\s',''
                       $fta = $FileType.Split(", ")
                           foreach ($i in $fta){
                               $script:search_query += " FileType:$i "
                           }                 
                   }  
               }

               function Tail{
                    if ($Tail -ne [string]::Empty){
                        $Line_Request = $Tail
                        Get-Content $script:History_Path | Select-Object -Last $Line_Request
                    }
            }

                function Repeat{
                    if ($Repeat -ne [string]::Empty){
                        $Rt = $Repeat +1
                        $Line = Get-Content $script:History_Path | Select-Object -Index 4
                        $script:search_query += (($Line -split (':',5))[4])
                        Write-Host $script:search_query
                        Launch_Query

                    }
                }

               
               #Worker // Main        
               if ($contains -ne [string]::Empty){
                   Write-Host "Searching for: $contains"
                   $script:search_query += $contains
                   NotContains
                   Include
                   Domains
                   FileType
                   Launch_Query               
               }
               elseif($Tail -ne [string]::Empty){
                    Tail
               }
               elseif($Repeat -ne [string]::Empty){
                   Repeat
               }
               else{
                   Write-Host "No query"
               }  
           }
           
           #Create a logfile of previous searches, feel free to comment out or change pathing.
           END {
               
                $script:History_Path = "$env:USERPROFILE\Documents\Power-Goo.txt"
                if($script:search_query -ne [string]::Empty){
                    $DT = Get-Date
                    Test-Path $script:History_Path | out-null                     
                        if ($false){
                            New-Item -Path $script:History_Path -ItemType File
                            Add-Content -Path $script:History_Path -Value "1: $DT : $script:search_query"
                        }
                        else{
                            $Current_Count = (Get-Content $script:History_Path).Length + 1
                            Add-Content -Path $script:History_Path -Value "$Current_Count : $DT : $script:search_query"
                        } 
           
                   }
           }
           
           }
