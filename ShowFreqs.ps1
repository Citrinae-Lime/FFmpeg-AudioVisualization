# Replace "input -f null" with your file path
# Input audio
$a = "input -f null"
# Input image
$p = "input -f null"
# Output resolution
$width = 2560
$height = [int]$width*0.5625  # 16:9; 0.75 for 4:3
$UI_WH = [int]$width/2*0.8
$bg_color = "random"
# Title
$font = font.ttf
$title = "A2V by FFmpeg"

ffmpeg.exe -hide_banner -i $p -i $a `
-filter_complex "color=c=$bg_color`:s=$width`x$height`:r=60[bg],
                 [0]scale=$UI_WH`:$UI_WH,pad=w=iw+$($width/10):color=$bg_color[cover],
                 [1:a]showfreqs=s=$UI_WH`x$UI_WH`:ascale=sqrt:colors=F3F3F3|F5F5F5:averaging=15:fscale=log,
                 drawtext=fontcolor=F4F4F4:fontfile=$font`:fontsize=86:text=$title[freq];
                 [cover][freq]hstack[ui];
                 [bg][ui]overlay=x=(W-w)/2:y=(H-h)/2[v]" `
-map '[v]' -map '1:a' -c:a libopus -c:v libvpx-vp9 -shortest Freqs_A2V.webm

Read-Host -Prompt 'Press Enter to exit'
