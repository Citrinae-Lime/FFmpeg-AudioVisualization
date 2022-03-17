# Input audio
$a = "input -f null"
# Input image
$v = "input -f null"
# Output resolution
$width = 2560
$height = [int]$width*0.5625  # 16:9, 0.75 for 4:3
$UI_WH = [int]$width/2*0.8
# Title
$title = "A2V by FFmpeg"

ffmpeg.exe -hide_banner -i $p -i $v `
-filter_complex "[0]scale=1:1:flags=neighbor,scale=$width`:$height,setsar=1:1[bg],
                 [0]scale=$UI_WH`:$UI_WH,pad=w=iw+$($width/10):color=random@0x00[cover],
                 [1]showfreqs=s=$UI_WH`x$UI_WH`:ascale=cbrt:colors=$light`:averaging=20,
                 drawtext=fontcolor=F3F3F3:fontfile=Nexa.otf:fontsize=90:text=$text[ferqs];
                 [cover][ferqs]hstack[ui];
                 [bg][ui]overlay=x=(W-w)/2:y=(H-h)/2[v]" `
-map '[v]' -map '1:0' -c:a libopus -c:v libvpx-vp9 Ferqs_A2V.mkv
