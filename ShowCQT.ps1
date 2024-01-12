# You need FFmpeg to use this!
add-type -AssemblyName System.Drawing
$image = $(Read-Host -Prompt 'Attach pic') -replace '"',''
$image_info = New-Object System.Drawing.Bitmap $image

# Set to divisible by 2 and check if need scale
$ih = $image_info.Height
if ($ih %2 -eq 1){$ih -= 1}
$iw = $image_info.Width
if ($iw %2 -eq 1) {$iw -= 1}
if ($iw -ne $image_info.Width -or $ih -ne $image_info.Height) {$scale = "scale=$iw :$ih[v];[v]"}

# Set CQT width to ⅓
$CQT_width = [int]($ih/0.75)-$iw
if ($CQT_width %2 -eq 1) {$CQT_width -= 1}

$audio = $(Read-Host -Prompt 'Audio file') -replace '"',''
$filter = "[1:a]showcqt=s=$CQT_width x$ih :bar_g=2:sono_g=2:tc=0.5[vcqt],
           [0]$scale[vcqt]hstack=shortest=1[vo]"

# Encoder need Intel API, you can change it if you don't want.

foreach ($audio_file in Get-ChildItem $audio -Exclude cover.*) {
    $output_file = $audio_file -replace '\.\w+$','.mkv'
    ffmpeg.exe -hide_banner -loop 1 -i $image -i $audio_file -filter_complex $filter -map '[vo]' -map '1:a' `
    -c:a copy -c:v h264_qsv -preset:v 3 -global_quality 10 -look_ahead 1 -scenario 3 $output_file
}

Read-Host -Prompt 'Press Enter to exit'