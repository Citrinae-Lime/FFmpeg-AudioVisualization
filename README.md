# FFmpeg-AudioVisualization

这些是使用 FFmpeg 创建音频可视化的 PowerShell 脚本，
脚本以可视化使用的过滤器命名。  

使用效果可在 [我的B站账号](https://space.bilibili.com/5677062/) 中查看。

## 使用方法  

- 将 [FFmpeg](https://github.com/FFmpeg/FFmpeg) 添加到path或者同一文件夹下
1. 下载脚本到电脑
2. 查看帮助
    ```PowerShell
    Get-Help ShowFreps.ps1 -full
    ```
3. 通用方法
    ```PowerShell
    .\ShowCQT.ps1 infile.audio infile.image
    ```
4. 若提示执行策略问题则额外执行一遍
    ```PowerShell
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process
    ```