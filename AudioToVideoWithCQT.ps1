# You need FFmpeg to use this!

add-type -AssemblyName System.Drawing
$image = Read-Host -Prompt 'Audio Cover'
$image_info = New-Object System.Drawing.Bitmap $image       # Get image detail

# Set to divisible by 2
if ($image_info.Height %2 -eq 0){$ih = $image_info.Height}
    else {$ih = $image_info.Height-1}
if ($image_info.Width %2 -eq 0) {$iw = $image_info.Width}
    else {$iw = $image_info.Width-1}

# Set CQT width to ⅓
if ($iw %3 -eq 0) {$CQT_width = $iw/3}
else {$CQT_width = ($iw-$iw%3)/3
      if ($CQT_width%2 -eq 1) {$CQT_width += 1}
}

$audio = Read-Host -Prompt 'Audio File'
$filter = "[1:0]showcqt=s=$CQT_width`x$ih`:bar_g=2:sono_g=2[vcqt],[0:0]scale=$iw`:$ih,format=yuv420p[v];[v][vcqt]hstack[vo]"
# Is 256kbps@opus and x265 in mkv container, you can change it if you want.
$output_opitons = "-map '[vo]' -map 1:0 -c:a libopus -b:a 256k -c:v libx265 -shortest"

# For folder, please add a \ after the path.
if ($audio -match '\\$') {
    foreach ($audio_file in Get-ChildItem $audio -Exclude Cover.*) {
        $output_file = $audio_file.Name -replace "\.\w*",".mkv"
        ffmpeg -hide_banner -loop 1 -i $image -i $audio_file.fullname -filter_complex $filter $output_opitons "$output_file"
    }
}
else {
    $output_file = $audio -replace "\.\w*",".mkv"
    ffmpeg -hide_banner -loop 1 -i $image -i $audio -filter_complex $filter $output_opitons "$output_file"
}
Read-Host -Prompt "Press Enter to exit"