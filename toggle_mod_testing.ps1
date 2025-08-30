# Toggle link for the mod into Steam's X4 extensions folder.
# Usage: pwsh ./toggle_mod_testing.ps1

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$modCandidates = @(
  (Join-Path $repoRoot 'extensions\higher_dimensional_space')
)
$localMod = $null
foreach ($p in $modCandidates) { if (Test-Path $p) { $localMod = $p; break } }
if (-not $localMod) { throw "Couldn't find extensions\yvary or extensions\hds_yvary next to this script." }
$modName = Split-Path $localMod -Leaf

# Steam X4 extensions dir (env var wins; uncomment next line to hardcode)
# $steamExt = $env:X4_EXTENSIONS_DIR
# if ([string]::IsNullOrWhiteSpace($steamExt)) {
#   $steamExt = Join-Path ${env:ProgramFiles(x86)} 'Steam\steamapps\common\X4 Foundations\extensions'
# }
$steamExt = 'E:\SteamLibrary\steamapps\common\X4 Foundations\extensions'

if (-not (Test-Path $steamExt)) { New-Item -ItemType Directory -Path $steamExt | Out-Null }

$target = Join-Path $steamExt $modName

# Helper: is path a reparse point (junction/symlink)?
$IsLink = $false
if (Test-Path $target) {
  $attr = (Get-Item $target -Force).Attributes
  $IsLink = [bool]($attr -band [IO.FileAttributes]::ReparsePoint)
}

if (Test-Path $target) {
  if ($IsLink) {
    # SAFE unlink: remove the junction itself (no recursion into target)
    & cmd.exe /c "rmdir `"$target`"" | Out-Null
    Write-Host "Unlinked: $target"
  } else {
    throw "Target exists and is NOT a link/junction: $target"
  }
} else {
  try {
    New-Item -ItemType Junction -Path $target -Value $localMod | Out-Null
  } catch {
    # Fallback creation if New-Item fails
    & cmd.exe /c "mklink /J `"$target`" `"$localMod`"" | Out-Null
  }
  Write-Host "Linked: $target -> $localMod"
}
