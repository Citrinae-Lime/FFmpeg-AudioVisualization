<#
  .SYNOPSIS
  创建基于 ShowFreqs 的音频可视化。

  .PARAMETER InputAudio
  输入音频，支持所有 FFmpeg 所支持的格式。

  .PARAMETER InputImage
  输入图像，支持所有 FFmpeg 所支持的格式。

  .PARAMETER OutputVideo
  输出媒体，支持所有 FFmpeg 所支持的格式。
  默认使用原文件名.mkv。

  .PARAMETER title
  显示在可视化上方的标题，默认从标签获取。
  特殊字符需转义。

  .PARAMETER font
  指定标题的字体文件。
  默认 Times New Roman。

  .PARAMETER width
  视频宽度。
  默认 2560，高度根据比率（默认16:9）计算得出。

  .EXAMPLE
  .\ShowFreqs.ps1 "D:\Path to\flie.wav" "C:\Path\to cover.jpeg"

  .EXAMPLE
  .\ShowFreqs.ps1 -a "D:\Path to\音频.flac" -p "C:\Path\to cover.png" -title "A2V by FFmpeg" -font Nexa.otf -width 1920
#>

[CmdletBinding()]
Param(   
    [Parameter(Mandatory=$True)][ValidateNotNullOrEmpty()][Alias("a")][String]$InputAudio,
    [Parameter(Mandatory=$True)][ValidateNotNullOrEmpty()][Alias("p")][String]$InputImage,
    [Parameter(Mandatory=$False)][Alias("o")][String]$OutputVideo,

    [Parameter(Mandatory=$False)][AllowEmptyString()][String]$title,
    [Parameter(Mandatory=$False)][String]$font = "$env:windir\Fonts\times.ttf",
    [Parameter(Mandatory=$False)][ValidateNotNull()][Int]$width = 2560
    )

# 计算输出分辨率
$height = [int]($width*0.5625)  # 16:9; 0.75 for 4:3
$UI_WH = [int]($width/2*0.8)

if ($OutputVideo -eq $null) {$OutputVideo = $InputAudio -replace '\.\w+$','.mkv'}
if ($title -eq $null) {$title = ffprobe.exe -v error -show_entries format_tags=title -of default=noprint_wrappers=1:nokey=1 $InputAudio}

$filters = @"
[0]
    scale = 1:1,
    scale = $width`:$height,
    setsar = 1:1
[bg],

[0]
    scale = -1:$UI_WH,
    pad = 
         w = iw+$($width/10)
        :color = random@0x00
[cover],

[1:a]
    showfreqs = 
         s = $UI_WH`x$UI_WH
        :ascale = sqrt
        :colors = F3F3F3|F5F5F5
        :averaging = 15
        :win_func = tukey
        :fscale = log,
    drawtext = 
         fontcolor = F4F4F4
        :fontfile = $font
        :fontsize = h/10
        :text = $title
[freq];

[cover][freq]
    hstack
[ui];

[bg][ui]
    overlay =
        x = (W-w)/2:
        y = (H-h)/2
[v]
"@

ffmpeg.exe -hide_banner -i $InputImage -i $InputAudio `
-filter_complex $filters -map '[v]' -map '1:a' `
-c:a copy -c:v librav1e -shortest $OutputVideo

Read-Host -Prompt '按任意键退出'
