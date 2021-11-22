param (
    [string]$problem,
    [Parameter(HelpMessage = "show details")]
    [switch]$detail = $False
)

$executable = (Get-ChildItem "$problem\*.exe" | Select-Object FullName)[0].FullName
$cases = (Get-ChildItem -path $problem | Where-Object { $_.Name -match "case(.\d+)?$" } | Select-Object) 
$results = , @()
$correct = 0
$wrong = 0
foreach ($case in $cases) {
    $casedir = $case.FullName
    $casename = ($case.Name | Select-String -pattern "case(?:.(\d+))?$").matches.groups[1]
    $casename = if ([string]::IsNullOrEmpty($casename) -and [string]::IsNullOrWhiteSpace($casename)) { "default" } else { $casename }
    Get-Content("$casedir") | & "$executable" 1> "$($casedir).result"
    
    if (Test-Path "$casedir.answer") {
        $diff = (Compare-Object (Get-Content "$casedir.answer") (Get-Content "$casedir.result") -CaseSensitive -PassThru)
        if ($diff) { $wrong++ }
        else { $correct++ }
        $result = if($diff) {$diff} else {"ok"}
    }
    else {
        $result = "no answer provided"
    }
    if ($detail) {
        Write-Output ([string]::Format("--------Case {0}--------", $casename))
        Write-Output "$result`n"
    }

    $results += $result
}

Write-Output([string]::Format("{0} correct {1} wrong in {2} cases", $correct, $wrong, $cases.Count))