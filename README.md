# Power-Goo
Advanced Google searching utilizing PowerShell syntax and autocompletion.
    <#
    .SYNOPSIS
    Advanced Google searching utilizing PowerShell syntax and autocompletion.
    
    .DESCRIPTION
    Specify a query to be made. Browser is determined on user default.
    
    .PARAMETER contains
    Specifies the requested query, required.
    
    .PARAMETER notcontains
    Specifies the terms to exclude from the query, comma deliminated.

    .PARAMETER notcontains
    Specifies the terms to include from the base query, comma deliminated.
    
    .PARAMETER Domains
    Specifies the domain to contain the query to.
    
    .PARAMETER FileType
    Specifies the requested file type extension.
    
    .INPUTS
    None. You cannot pipe objects to Add-Extension.
    
    .OUTPUTS
    Outputs query as a Google search in the default browser of the user.
    
    .EXAMPLE
    PS> Power-Goo -contains stuff -notcontains things,objects -Domain github.com -FileType .ps1

  #>
