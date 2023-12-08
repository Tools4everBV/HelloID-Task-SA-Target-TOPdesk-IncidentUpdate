# TOPdesk-Task-SA-Target-TOPdesk-IncidentUpdate
###########################################################
# Form mapping
$formObject = @{
    callerLookup     = $form.callerLookup
    briefDescription = $form.briefDescription
    request          = $form.request
    action           = $form.action
    operator         = $form.operator
    operatorGroup    = $form.operatorGroup
    category         = $form.category
    subcategory      = $form.subcategory
    callType         = $form.callType
    impact           = $form.impact
    urgency          = $form.urgency
    priority         = $form.priority
    duration         = $form.duration
    entryType        = $form.entryType
    processingStatus = $form.processingStatus
    branch           = $form.branch
}
$incidentId = $form.id
$incidentDisplayName = $formObject.briefDescription

try {
    Write-Information "Executing TOPdesk action: [UpdateIncident] for: [$($incidentId)]"
    Write-Verbose "Creating authorization headers"
    # Create authorization headers with TOPdesk API key
    $pair = "${topdeskApiUsername}:${topdeskApiSecret}"
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
    $base64 = [System.Convert]::ToBase64String($bytes)
    $key = "Basic $base64"
    $headers = @{
        "authorization" = $Key
        "Accept"        = "application/json"
    }

    Write-Verbose "Updating TOPdesk Incident: [$($incidentId)]"
    $splatUpdateIncidentParams = @{
        Uri         = "$($topdeskBaseUrl)/tas/api/incidents/id/$($incidentId)"
        Method      = "PATCH"
        Body        = ([System.Text.Encoding]::UTF8.GetBytes(($formObject | ConvertTo-Json -Depth 10)))
        Verbose     = $false
        Headers     = $headers
        ContentType = "application/json; charset=utf-8"
    }
    $response = Invoke-RestMethod @splatUpdateIncidentParams

    $auditLog = @{
        Action            = "UpdateResource"
        System            = "TOPdesk"
        TargetIdentifier  = [String]$response.id
        TargetDisplayName = [String]$response.number
        Message           = "TOPdesk action: [UpdateIncident] for: [$($incidentId)] executed successfully"
        IsError           = $false
    }
    Write-Information -Tags "Audit" -MessageData $auditLog

    Write-Information "TOPdesk action: [UpdateIncident] for: [$($incidentId)] executed successfully"
}
catch {
    $ex = $_
    $auditLog = @{
        Action            = "UpdateResource"
        System            = "TOPdesk"
        TargetIdentifier  = [String]$incidentId
        TargetDisplayName = [String]$incidentDisplayName
        Message           = "Could not execute TOPdesk action: [UpdateIncident] for: [$($incidentId)], error: $($ex.Exception.Message)"
        IsError           = $true
    }
    if ($($ex.Exception.GetType().FullName -eq "Microsoft.PowerShell.Commands.HttpResponseException")) {
        $auditLog.Message = "Could not execute TOPdesk action: [UpdateIncident] for: [$($incidentId)]"
        Write-Error "Could not execute TOPdesk action: [UpdateIncident] for: [$($incidentId)], error: $($ex.ErrorDetails)"
    }
    Write-Information -Tags "Audit" -MessageData $auditLog
    Write-Error "Could not execute TOPdesk action: [UpdateIncident] for: [$($incidentId)], error: $($ex.Exception.Message)"
}
###########################################################