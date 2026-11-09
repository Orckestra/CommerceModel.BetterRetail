

function Retry {
    <#
    .SYNOPSIS
    Enable a retry over a scriptblock
    .DESCRIPTION
    When the scriptblock throw an exception, it will wait a few seconds and retry.
    When the max count is reach, the exception will be thrown.
    The delay is *2.
    The exception thrown during the retry is log 
    .EXAMPLE
            Retry -message "Unable to rename database, locked by another process" -func {
            $DatabaseConnection | Invoke-SqlQuery -Query $query
        }  
    .PARAMETER func
    Script to retry.
    .PARAMETER message
    The message to show when retrying.
    .PARAMETER count
    Number of tentative. Will always call the function at least once. Set -1 for no retry.
    .PARAMETER startDelayInSeconds
    time to wait for the first retry. For each retry this time will be multiply by 2.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][scriptblock]$func, 
        [Parameter(Mandatory = $true)][string]$message, 
        [Parameter(Mandatory = $false)][int]$count = 7,
        [Parameter(Mandatory = $false)][int]$startDelayInSeconds = 1
    )
    Process {
        $i = $count
        $timeout = $startDelayInSeconds

        while ($true) {
            try {
                $func.Invoke($i);
                break
            }
            catch [system.exception] {
                if ($i -lt 0) {
                    throw $_.Exception
                }
                else {
                    Write-Warning "Retrying $message in $timeout seconds..."
                    Write-Host $_.Exception

                    if ($_.Exception.Response) {
                        $result = $_.Exception.Response.GetResponseStream()
                        $reader = New-Object System.IO.StreamReader($result)
                        $reader.BaseStream.Position = 0
                        $reader.DiscardBufferedData()
                        $responseBody = $reader.ReadToEnd();
                        Write-Host $responseBody
                    }

                    Start-Sleep -s $timeout
                    $i--
                    $timeout *= 2
                }
            }
        }
    }
}