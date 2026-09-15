<#
.SYNOPSIS
  clipboard-bridge: Windowsクリップボードをリモートのnvim(god77)へ
  TCP経由で公開する常駐サーバー。127.0.0.1 のみにバインドするので、
  到達できるのは ssh -R でトンネルされた場合のみ。

  プロトコル(すべて little-endian uint32):
    ペースト: client が 'P' を送る
              → server が <len:u32><UTF-8本文> を返す
    コピー  : client が 'C' <len:u32><UTF-8本文> を送る
              → server は応答しない(現状未使用、将来用に実装だけしておく)

  セキュリティに関する注意は docs/clipboard-bridge-design.md の
  11節を参照。特に、長さフィールド(len)に対する上限チェックは
  意図的に入れている(不正な長さで巨大メモリ確保させない)。
#>
param(
    [int]$Port = 52599,
    [int]$MaxPayloadBytes = 10MB
)

$ErrorActionPreference = "Stop"

function Read-Exact([System.IO.Stream]$Stream, [int]$Count) {
    $buf = New-Object byte[] $Count
    $read = 0
    while ($read -lt $Count) {
        $n = $Stream.Read($buf, $read, $Count - $read)
        if ($n -le 0) { throw "connection closed early" }
        $read += $n
    }
    return $buf
}

$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, $Port)
$listener.Start()
Write-Host "clipboard-bridge: listening on 127.0.0.1:$Port (Ctrl+C to stop)"

while ($true) {
    $client = $listener.AcceptTcpClient()
    try {
        $stream = $client.GetStream()
        $stream.ReadTimeout = 5000   # 不正/中断された接続で無限ブロックしない
        $cmd = [char](Read-Exact $stream 1)[0]

        if ($cmd -eq 'P') {
            $text = ""
            try {
                $got = Get-Clipboard -Raw -ErrorAction Stop
                if ($null -ne $got) { $text = $got }
            } catch {
                $text = ""
            }
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($text)
            $stream.Write([BitConverter]::GetBytes([uint32]$bytes.Length), 0, 4)
            if ($bytes.Length -gt 0) { $stream.Write($bytes, 0, $bytes.Length) }
        }
        elseif ($cmd -eq 'C') {
            $len = [BitConverter]::ToUInt32((Read-Exact $stream 4), 0)
            if ($len -gt $MaxPayloadBytes) {
                throw "payload too large: $len bytes (limit $MaxPayloadBytes)"
            }
            $text = if ($len -gt 0) {
                [System.Text.Encoding]::UTF8.GetString((Read-Exact $stream $len))
            } else { "" }
            Set-Clipboard -Value $text
        }
    } catch {
        Write-Warning "clipboard-bridge: $_"
    } finally {
        $client.Close()
    }
}
