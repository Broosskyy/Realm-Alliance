# V2.09 Phase 1 Final Acceptance Runner
$Proj = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Godot = Get-ChildItem (Join-Path $env:USERPROFILE "Downloads") -Recurse -Filter "*console.exe" -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "Godot*" } | Select-Object -First 1
if (-not $Godot) {
  $Godot = Get-ChildItem (Join-Path $env:USERPROFILE "Downloads") -Filter "Godot*.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
}
if (-not $Godot) { Write-Error "Godot not found in Downloads"; exit 2 }
Write-Host "Godot:" $Godot.FullName
Write-Host "Project:" $Proj
Write-Host "`n=== Domain QA ==="
& $Godot.FullName --headless --path $Proj res://V209WorldDomainQaHost.tscn
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "`n=== Runtime QA (rendering required for screenshots) ==="
& $Godot.FullName --path $Proj res://V209WorldRuntimeQaHost.tscn
exit $LASTEXITCODE
