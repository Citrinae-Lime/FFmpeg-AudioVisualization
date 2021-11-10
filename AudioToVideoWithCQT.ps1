add-type -AssemblyName System.Drawing
$image = Read-Host -Prompt 'Audio Cover'
$image_info = New-Object System.Drawing.Bitmap $image       # Get image detail

# Set to 1:1
if ($image_info.Height -gt $image_info.Width){
    if ($image_info.Width%2 -eq 0) {$ihw = $image_info.Width}
    else {$ihw = $image_info.Width-1}
}
elseif ($image_info.Height -le $image_info.Width) {
    if ($image_info.Height%2 -eq 0) {$ihw = $image_info.Height}
    else {$ihw = $image_info.Height-1}
}

# Set CQT width to ⅓
if ($ihw %3 -eq 0) {$CQT_width = $ihw/3}
else {$CQT_width = ($ihw-$ihw%3)/3}
if ($ihw %2 -eq 1) {$ihw+1}

$audio = Read-Host -Prompt 'Audio File'
$filter = "[1:0]showcqt=s=$CQT_width`x$ihw:bar_g=2:sono_g=2[vcqt],[0:0]scale=$ihw`:$ihw[vs],[vs]format=yuv420p[v];[v][vcqt]hstack[vo]"

# Is 320kbps@opus and h.265 in mkv container, you can change it if you want
ffmpeg -hide_banner -loop 1 -i $image -i $audio -filter_complex $filter -map '[vo]' -map 1:0 -c:a libopus -b:a 320k -c:v libx265 -shortest "$audio.mkv"
