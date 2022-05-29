# 将 "input -f null" 替换为你的文件路径。
$image = "input -f null"
$audio = "input -f null"

# 测试是否能被 2 整除。
add-type -AssemblyName System.Drawing
$image_info = New-Object System.Drawing.Bitmap $image
$ih = $image_info.Height
if ($ih %2 -eq 1){$ih -= 1}
$iw = $image_info.Width
if ($iw %2 -eq 1) {$iw -= 1}
if ($iw -ne $image_info.Width -or $ih -ne $image_info.Height) {$scale = "scale=$iw`:$ih[v];[v]"}

# 将 CQT 的宽度设定为⅓（如果原文件是正方形）
$CQT_width = [int]($ih/0.75)-$iw
if ($CQT_width %2 -eq 1) {$CQT_width -= 1}

$filter = "[1:a]showcqt=s=$CQT_width`x$ih`:bar_g=2:sono_g=2:tc=0.5[vcqt],
           [0]$scale[vcqt]hstack=shortest=1[vo]"

# 默认预设为 256kbps@opus 和 vp9 封装在 webm 格式, 你可随意更改。
# 记得检查一下拓展名替换规则!
# 对于多个输入，请将 \ 添加在输入路径后.

if ($audio -match '\\$') {
    Set-Location $audio
    foreach ($audio_file in Get-ChildItem -Exclude cover.*) {
        $output_file = $audio_file -replace '.flac|.wav|.mp3|.m4a','.webm'
        ffmpeg.exe -hide_banner -loop 1 -i $image -i $audio_file -filter_complex $filter -map '[vo]' -map '1:a' -c:a libopus -b:a 256k -c:v libvpx-vp9 $output_file
    }
}
else {
    $output_file = $audio -replace '.flac|.wav|.mp3|.m4a','.webm'
    ffmpeg.exe -hide_banner -loop 1 -i $image -i $audio -filter_complex $filter -map '[vo]' -map '1:a' -c:a libopus -b:a 256k -c:v libvpx-vp9 $output_file
}
Read-Host -Prompt '按任意键退出'
