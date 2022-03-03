# You need FFmpeg to use this!
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process
add-type -AssemblyName System.Drawing
$image = $(Read-Host -Prompt 'Attach pic') -replace '"',''
$image_info = New-Object System.Drawing.Bitmap $image

# Set to divisible by 2 and check if need scale
$ih = $image_info.Height
if ($ih %2 -eq 1){$ih -= 1}
$iw = $image_info.Width
if ($iw %2 -eq 1) {$iw -= 1}
if ($iw -ne $image_info.Width -or $ih -ne $image_info.Height) {$scale = "scale=$iw`:$ih[v];[v]"}

# Set CQT width to ⅓
$CQT_width = [int]($ih/0.75)-$iw
if ($CQT_width %2 -eq 1) {$CQT_width -= 1}

$audio = $(Read-Host -Prompt 'Audio file') -replace '"',''
$filter = "[1]showcqt=s=$CQT_width`x$ih`:bar_g=2:sono_g=2[vcqt],
           [0]$scale[vcqt]hstack=shortest=1[vo]"

# Is 256kbps@opus and vp9 in webm container, you can change it if you want.
# Check the extension replacement rule!
# For folder, please add a \ after the path.

if ($audio -match '\\$') {
    Set-Location $audio
    foreach ($audio_file in Get-ChildItem -Exclude cover.*) {
        $output_file = $audio_file -replace '.flac|.wav|.mp3|.m4a','.webm'
        ffmpeg.exe -hide_banner -loop 1 -i $image -i $audio_file -filter_complex $filter -map '[vo]' -map 1 -c:a libopus -b:a 256k -c:v libvpx-vp9 $output_file
    }
}
else {
    $output_file = $audio -replace '.flac|.wav|.mp3|.m4a','.webm'
    ffmpeg.exe -hide_banner -loop 1 -i $image -i $audio -filter_complex $filter -map '[vo]' -map 1 -c:a libopus -b:a 256k -c:v libvpx-vp9 $output_file
}
Read-Host -Prompt 'Press Enter to exit'