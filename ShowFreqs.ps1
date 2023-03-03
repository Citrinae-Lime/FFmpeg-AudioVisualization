# Replace "input -f null" with your file path
# Input audio
$a = "input -f null"
# Input image
$p = "input -f null"

add-type -AssemblyName System.Drawing
# Output resolution
$width = 2560
$height = [int]($width*0.5625)  # 16:9; 0.75 for 4:3
$UI_WH = [int]($width/2*0.8)
$bg_color = [System.Drawing.Color]::FromArgb(36, 41, 46)
# Title
$font = "Nexa.otf"
$title = "A2V use FFmpeg&showfreqs"

$relativeLuminance = 0.2126*$bg_color.R + 0.7152*$bg_color.G + 0.0722*$bg_color.B
if ($relativeLuminance -ge 0.5){$UI_color = "0x171717"}
else {$UI_color = "0xF4F4F4"}

ffmpeg.exe -hide_banner -i $p -i $a `
-filter_complex `
"color=c=$($bg_color.name):s=$width x$height :r=60[bg],
 [0]scale=$UI_WH :$UI_WH,pad=w=iw+$($width/10):color=$($bg_color.name)[cover],
 [1:a]showfreqs=s=$UI_WH x$UI_WH :ascale=sqrt:colors=$UI_color|$UI_color :averaging=15:fscale=log,
      drawtext=fontcolor=$UI_color :fontfile=$font :fontsize=h/10:text=$title[freq];
 [cover][freq]hstack[ui];
 [bg][ui]overlay=x=(W-w)/2:y=(H-h)/2[v]" `
-map '[v]' -map '1:a' -c:a copy -c:v hevc_qsv -preset:v 3 -global_quality 10 -look_ahead 1 -scenario 3 -shortest Freqs_A2V.mkv

Read-Host -Prompt 'Press Enter to exit'
