# 将 "input -f null" 替换为你的文件路径。
# 音频路径
$a = "input -f null"
# 图像路径
$p = "input -f null"
# 输出分辨率
$width = 2560
$height = [int]$width*0.5625  # 16:9; 0.75 for 4:3
$UI_WH = [int]$width/2*0.8
# 标题（需指定字体文件，特殊字符需转义）
$font = font.ttf
$title = "A2V by FFmpeg"

ffmpeg.exe -hide_banner -i $p -i $a `
-filter_complex "[0]scale=1:1:flags=neighbor,scale=$width`:$height,setsar=1:1[bg],
                 [0]scale=$UI_WH`:$UI_WH,pad=w=iw+$($width/10):color=random@0x00[cover],
                 [1:a]showfreqs=s=$UI_WH`x$UI_WH`:ascale=sqrt:colors=F3F3F3|F5F5F5:averaging=15:fscale=log,
                 drawtext=fontcolor=F4F4F4:fontfile=$font`:fontsize=86:text=$title[freq];
                 [cover][freq]hstack[ui];
                 [bg][ui]overlay=x=(W-w)/2:y=(H-h)/2[v]" `
-map '[v]' -map '1:a' -c:a libopus -c:v libvpx-vp9 -shortest Freqs_A2V.webm

Read-Host -Prompt '按任意键退出'
