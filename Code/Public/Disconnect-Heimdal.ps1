function Disconnect-Heimdal {
    <#
        .Synopsis
            Disconnects from the Heimdal Security API by clearing the session information stored in the global variable.

        .Description
            This function clears the session information stored in the global variable, effectively disconnecting from the Heimdal Security API.

        .Example
            Disconnect-Heimdal
            This example disconnects from the Heimdal Security API by clearing the session information.
    #>
    [CmdletBinding()]
    param ()

    # Clear the session information stored in the global variable
    if ( $script:HDSession ) {
        $script:HDSession = $null
        Write-Verbose "Disconnected from Heimdal Security API. Session information cleared."
    } else {
        Write-Verbose "No active session found for Heimdal Security API."
    }
}
