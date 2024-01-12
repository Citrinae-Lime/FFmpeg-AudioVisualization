# Replace with your file path
# Input audio
$audio = $(Read-Host -Prompt 'Audio file') -replace '"',''
# Input image
$p = $(Read-Host -Prompt 'Attach pic') -replace '"',''

add-type -AssemblyName System.Drawing
# Output resolution
$width = 1920
$height = [int]($width*0.5625)  # 16:9; 0.75 for 4:3
$UI_WH = [int]($width/2*0.8)
$bg_color = [System.Drawing.Color]::FromArgb(36, 41, 46)
# Title
$font = "Nexa.otf"
$title = ""

$relativeLuminance = 0.2126*$bg_color.R + 0.7152*$bg_color.G + 0.0722*$bg_color.B
if ($relativeLuminance -ge 0.5) {$UI_color = '1D1D1D@0xCD|111111@0xDC'}    #Dark
else {$UI_color = 'F3F3F3@0xCD|F5F5F5@0xDC'} #Light

foreach ($a in Get-ChildItem $audio -Exclude cover.*) {
# If no title is given get it from the tag
if ($title -eq "") {$title = ffprobe.exe -v error -show_entries format_tags=title -of default=noprint_wrappers=1:nokey=1 $a}

$o = $a -replace '\.\w+$','.mkv'

ffmpeg.exe -hide_banner -i $p -i $a `
-filter_complex `
"color=c=$($bg_color.name):s=$width x$height :r=60[bg],
 [0]scale=-1:$UI_WH,pad=w=iw+$($width/10):color=$($bg_color.name)[cover],
 [1:a]showfreqs=s=$UI_WH x$UI_WH :ascale=sqrt:colors=$UI_color :averaging=15:fscale=log,
      drawtext=fontcolor=$($UI_color.Split('|')[0]):fontfile=$font :fontsize=h/10:text=$title[freq];
 [cover][freq]hstack[ui];
 [bg][ui]overlay=x=(W-w)/2:y=(H-h)/2[v]" `
-map '[v]' -map '1:a' -c:a copy -c:v h264_qsv -preset:v 3 -global_quality 10 -look_ahead 1 -scenario 3 -shortest $o
}

Read-Host -Prompt 'Press Enter to exit'