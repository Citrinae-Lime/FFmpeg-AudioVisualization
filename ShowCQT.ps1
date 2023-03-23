﻿# 将 "input -f null" 替换为你的文件路径。
$image = "input -f null"
$audio = "input -f null"

# 测试是否能被 2 整除。
add-type -AssemblyName System.Drawing
$image_info = New-Object System.Drawing.Bitmap $image
$ih = $image_info.Height
$ih -= $ih%2
$iw = $image_info.Width
$iw -= $iw%2
if ($iw -ne $image_info.Width -or $ih -ne $image_info.Height) {$scale = "scale=$iw`:$ih[v];[v]"}

# 将 CQT 的宽度设定为⅓
$CQT_width = ($iw-$iw%3)/3
$CQT_width -= $CQT_width%2

$filter = "[1:a]showcqt=s=$CQT_width`x$ih`:bar_g=2:sono_g=2:tc=0.5[vcqt],
           [0]$scale[vcqt]hstack=shortest=1[vo]"

# 默认预设为 256kbps@opus 和 vp9 封装在 webm 格式, 你可随意更改。
# 记得检查一下拓展名!
# 对于批量处理，请将 \ 添加在输入路径后。

if ($audio -match '\\$') {
    $audio_files = $(Get-ChildItem -Path $audio -Exclude cover.*).FullName
}
else {$audio_files = $audio}

foreach ($audio_file in $audio_files) {
    $output_file = $audio_file -replace '.flac|.wav|.mp3|.m4a','.webm'
    ffmpeg.exe -hide_banner -loop 1 -i $image -i $audio_file -filter_complex $filter -map '[vo]' -map '1:a' -c:a libopus -vbr 2 -b:a 256k -c:v libvpx-vp9 $output_file
}
Read-Host -Prompt '按任意键退出'
