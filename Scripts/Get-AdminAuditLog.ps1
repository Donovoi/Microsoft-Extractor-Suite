# This contains function for getting Admin Audit Log

function Get-AdminAuditLog {
<#
    .SYNOPSIS
    Search the contents of the administrator audit log.

    .DESCRIPTION
    Administrator audit logging records when a user or administrator makes a change in your organization (in the Exchange admin center or by using cmdlets).
	The output will be written to a CSV file called "AdminAuditLog.csv".

	.PARAMETER StartDate
    startDate is the parameter specifying the start date of the date range.

	.PARAMETER EndDate
    endDate is the parameter specifying the end date of the date range.

	.PARAMETER OutputDir
    OutputDir is the parameter specifying the output directory.
	Default: Output\AdminAuditLog
    
    .EXAMPLE
    Get-AdminAuditLog
	Displays the total number of logs within the admin audit log.

	.EXAMPLE
	Get-AdminAuditLog -StartDate 1/4/2023 -EndDate 5/4/2023
	Collects the admin audit log between 1/4/2023 and 5/4/2023
#>
    [CmdletBinding()]
	param (
		[string]$StartDate,
		[string]$EndDate,
		[string]$outputDir = "Output\AdminAuditLog"
	)

    write-logFile -Message "[INFO] Running Get-AdminAuditLog" -Color "Green"

	$date = [datetime]::Now.ToString('yyyyMMddHHmmss') 
    $outputFile = "$($date)-AdminAuditLog.csv"


	if (!(test-path $OutputDir)) {
		New-Item -ItemType Directory -Force -Name $outputDir | Out-Null
		write-LogFile -Message "[INFO] Creating the following directory: $outputDir"
	}
	
	else {
		if (Test-Path -Path $OutputDir) {
			write-LogFile -Message "[INFO] Custom directory set to: $OutputDir"
		}
	
		else {
			write-Error "[Error] Custom directory invalid: $OutputDir exiting script" -ErrorAction Stop
			write-LogFile -Message "[Error] Custom directory invalid: $OutputDir exiting script"
		}
	}

	$outputDirectory = Join-Path $OutputDir $outputFile

	StartDate
	EndDate

    Write-LogFile -Message "[INFO] Extracting all available Admin Audit Logs between $($script:StartDate.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssK")) and $($script:EndDate.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssK"))" -Color "Green"

	try {
		$results = Search-UnifiedAuditLog -RecordType 'ExchangeAdmin' -ResultSize 5000 -StartDate $script:startDate -EndDate $script:EndDate
		$results | Export-Csv $outputDirectory -NoTypeInformation -Append -Encoding UTF8
	}
	catch {
		write-logFile -Message "[INFO] Ensure you are connected to M365 by running the Connect-M365 command before executing this script" -Color "Yellow"
		Write-logFile -Message "[ERROR] An error occurred: $($_.Exception.Message)" -Color "Red"
		throw
	}   

    write-logFile -Message "[INFO] Output is written to: $outputDirectory" -Color "Green"
}
