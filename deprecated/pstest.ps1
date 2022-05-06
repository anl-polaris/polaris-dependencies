cls
# Send in two root directory names, one that exists and one that does not.
# Should then get a "True" and a "False" result out the end.
"temp", "foo" | %{

  $ScriptBlock = {
    # accept the loop variable across the job-context barrier
    param($name) 
    # Show the loop variable has made it through!
    Write-Host "[processing '$name' inside the job]"
    # Execute a command
    Test-Path "D:\rweimer\polaris\pT1-20160609\polarisdeps\$name"
    # Just wait for a bit...
    #Start-Sleep 1
  }

  # Show the loop variable here is correct
  Write-Host "processing $_..."

  # pass the loop variable across the job-context barrier
  Start-Job $ScriptBlock -ArgumentList $_
}

# Wait for all to complete
While (Get-Job -State "Running") { Start-Sleep 1 }

# Display output from all jobs
Get-Job | Receive-Job

# Cleanup
Remove-Job *