#Requires -Version 5.1
<#
.SYNOPSIS
    把 Little Paws 项目初始化成 Git 仓库并推送到 GitHub。

.DESCRIPTION
    依次完成：检查 Git -> 配置提交署名 -> git init -> add/commit -> 关联远程 -> push。
    可以重复运行：已有 .git、已有 origin、没有新改动时会自动跳过对应步骤。

.PARAMETER RepoUrl
    GitHub 仓库地址，例如 https://github.com/你的用户名/little-paws.git

.EXAMPLE
    .\upload-to-github.ps1 -RepoUrl https://github.com/guo07/little-paws.git

.NOTES
    前置条件：
      1. 已安装 Git for Windows（https://git-scm.com/download/win），并且重开过终端；
      2. 已在 GitHub 上新建一个【空仓库】（不要勾选 Add a README / .gitignore）；
      3. 首次 push 时 Git Credential Manager 会弹出浏览器窗口让你登录 GitHub。
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, HelpMessage = 'GitHub 仓库地址，例如 https://github.com/用户名/little-paws.git')]
    [string]$RepoUrl,

    [string]$Message = 'Initial commit: Little Paws 宠物主题静态站点'
)

$ErrorActionPreference = 'Stop'

function Write-Step([string]$Text) {
    Write-Host ""
    Write-Host "==> $Text" -ForegroundColor Cyan
}

function Stop-WithError([string]$Text) {
    Write-Host ""
    Write-Host "[失败] $Text" -ForegroundColor Red
    exit 1
}

# 始终以脚本所在目录（即项目根目录）为工作目录
Set-Location -LiteralPath $PSScriptRoot

# ---------------------------------------------------------------- 1. 检查 Git
Write-Step '1/6 检查 Git'
$gitExe = (Get-Command git -ErrorAction SilentlyContinue).Source
if (-not $gitExe) {
    # PATH 尚未刷新时，直接去常见安装位置找
    $candidates = @(
        "$env:LOCALAPPDATA\Programs\PortableGit\cmd\git.exe",
        "$env:ProgramFiles\Git\cmd\git.exe",
        "${env:ProgramFiles(x86)}\Git\cmd\git.exe",
        "$env:LOCALAPPDATA\Programs\Git\cmd\git.exe"
    )
    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) { $gitExe = $candidate; break }
    }
}
if (-not $gitExe) {
    Stop-WithError @'
没有找到 git 命令。
请先安装 Git for Windows： https://git-scm.com/download/win
安装时一路默认即可，装完【重新打开】VS Code 或 PowerShell，再运行本脚本。
'@
}

# 便携版把 DLL 放在 ucrt64\bin / mingw64\bin，补进 PATH，并统一用它调用 git
$gitRoot = Split-Path (Split-Path -Path $gitExe -Parent) -Parent
foreach ($sub in @('cmd', 'bin', 'ucrt64\bin', 'mingw64\bin')) {
    $dir = Join-Path $gitRoot $sub
    if (Test-Path -LiteralPath $dir) { $env:PATH = "$dir;$env:PATH" }
}
function git { & $gitExe @args }
Write-Host ((git --version) -join '') -ForegroundColor Green

# ------------------------------------------------------- 2. 检查仓库地址格式
Write-Step '2/6 检查仓库地址'
$RepoUrl = $RepoUrl.Trim()
if ($RepoUrl -notmatch '^(https://|git@)') {
    Stop-WithError "仓库地址格式不对：$RepoUrl`n应该形如 https://github.com/用户名/仓库名.git"
}
if ($RepoUrl -match '^https://github\.com/[^/]+/?$') {
    Stop-WithError "这个地址只有用户名、没有仓库名：$RepoUrl"
}
Write-Host "目标仓库：$RepoUrl" -ForegroundColor Green

# --------------------------------------------------------- 3. 提交署名（本仓库）
Write-Step '3/6 配置提交署名'
$userName = git config --get user.name
if ([string]::IsNullOrWhiteSpace($userName)) {
    $userName = Read-Host '请输入你的 GitHub 用户名（会写进提交记录）'
    if ([string]::IsNullOrWhiteSpace($userName)) { Stop-WithError '用户名不能为空。' }
    git config user.name $userName
}
$userEmail = git config --get user.email
if ([string]::IsNullOrWhiteSpace($userEmail)) {
    $userEmail = Read-Host '请输入你的 GitHub 邮箱（会写进提交记录）'
    if ([string]::IsNullOrWhiteSpace($userEmail)) { Stop-WithError '邮箱不能为空。' }
    git config user.email $userEmail
}
Write-Host "署名：$userName <$userEmail>" -ForegroundColor Green

# --------------------------------------------------------------- 4. 初始化仓库
Write-Step '4/6 初始化仓库'
if (Test-Path -LiteralPath '.git') {
    Write-Host '已存在 .git，跳过 git init。' -ForegroundColor Yellow
} else {
    git init -b main
    if ($LASTEXITCODE -ne 0) { Stop-WithError 'git init 执行失败。' }
}
# 统一分支名为 main
$currentBranch = git rev-parse --abbrev-ref HEAD 2>$null
if ($LASTEXITCODE -eq 0 -and $currentBranch -ne 'main' -and $currentBranch -ne 'HEAD') {
    git branch -M main
}

# ------------------------------------------------------------ 5. 暂存并提交
Write-Step '5/6 暂存并提交'
git add -A
if ($LASTEXITCODE -ne 0) { Stop-WithError 'git add 执行失败。' }

$staged = git diff --cached --name-only
if ([string]::IsNullOrWhiteSpace($staged)) {
    Write-Host '没有需要提交的新改动，跳过 commit。' -ForegroundColor Yellow
} else {
    git commit -m $Message
    if ($LASTEXITCODE -ne 0) { Stop-WithError 'git commit 执行失败。' }
    git --no-pager log --oneline -1
}

# ------------------------------------------------------------ 6. 关联并推送
Write-Step '6/6 推送到 GitHub'
$remotes = @(git remote)
if ($remotes -contains 'origin') {
    $oldUrl = (git remote get-url origin).Trim()
    if ($oldUrl -ne $RepoUrl) {
        Write-Host "origin 指向 $oldUrl，改为 $RepoUrl" -ForegroundColor Yellow
        git remote set-url origin $RepoUrl
    }
} else {
    git remote add origin $RepoUrl
}

Write-Host '开始推送（首次会弹出 GitHub 登录窗口，浏览器里授权即可）...' -ForegroundColor Yellow
git push -u origin main
if ($LASTEXITCODE -ne 0) {
    Stop-WithError @'
推送失败，常见原因：
  * 仓库不是空仓库（建仓库时勾了 README / .gitignore）—— 先在 GitHub 上删掉那个仓库重建，或改用：
        git pull origin main --allow-unrelated-histories
    再重新运行本脚本。
  * 账号没有这个仓库的写权限。
  * 网络无法访问 github.com（需要代理，或用 Gitee 镜像）。
'@
}

Write-Host ""
Write-Host '完成。仓库地址：' -NoNewline
Write-Host ($RepoUrl -replace '\.git$', '') -ForegroundColor Green
