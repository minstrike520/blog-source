---
title: Cloudflare Basics
date: 2025-12-30 23:41:00
updated: 2025-12-30 23:41:00
tags:
  - IT-Basics
---
在沒有固定外部 IP（Public IP）且位於 NAT（如宿舍、公司內部網路）後方的環境下，最現代、安全且簡單的解決方案是使用 **Cloudflare Tunnel**。

這項技術會在你的樹莓派與 Cloudflare 伺服器之間建立一條加密通道。當使用者訪問你的網域時，Cloudflare 會將流量透過這條通道導向你的樹莓派，你**完全不需要**在路由器上設定網址轉發（Port Forwarding）。

---

## 實作步驟指南

### 1. 安裝 Cloudflared 代理程式

首先，你需要在樹莓派上安裝 Cloudflare 提供的工具 `cloudflared`。

{% codeblock lang:javascript wrap:true %}
// A very very very long line of code that might need to wrap if the wrap option is enabled and your CSS supports it.
{% endcodeblock %}


```bash wrap:true
# 更新系統並安裝必要套件
sudo apt update && sudo apt install curl -y

# 下載並安裝 cloudflared (適用於樹莓派 ARM 架構)
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64.deb -o cloudflared.deb
sudo dpkg -i cloudflared.deb
```

### 2. 登入 Cloudflare 帳戶

執行以下指令會產生一個連結，請在瀏覽器中開啟並選擇你要使用的網域：

```bash
cloudflared tunnel login
```

### 3. 建立 Tunnel 隧道

建立一個隧道並給它一個名字（例如 `pi-server`）：

```bash
cloudflared tunnel create pi-server
```

執行後會得到一個 **Tunnel ID**（一串長代碼），請記下來。

### 4. 設定設定檔 (config.yml)

在 `~/.cloudflared/` 資料夾下建立設定檔，告訴 Cloudflare 如何轉發流量：

```yaml
tunnel: <您的 Tunnel ID>
credentials-file: /home/pi/.cloudflared/<您的 Tunnel ID>.json

ingress:
  - hostname: yourdomain.com  # 您的網域
    service: http://localhost:80  # 樹莓派上 Web Server 執行的埠位
  - service: http_status:404
```

### 5. 綁定 DNS 與啟動

將你的網域指向這個隧道，並啟動它：

```bash
# 綁定 DNS
cloudflared tunnel route dns pi-server yourdomain.com

# 啟動隧道
cloudflared tunnel run pi-server
```

---

## 為什麼選擇 Cloudflare Tunnel？

- **無需對外 IP：** 即使是移動網路或嚴格的宿舍防火牆也能穿透。
    
- **安全性極高：** 你不需要開啟任何路由器埠位（Port），減少被攻擊的風險。
    
- **內建 SSL：** Cloudflare 會自動幫你的網域加上 HTTPS 憑證。
    
- **隱藏真實 IP：** 駭客無法直接探測到你宿舍的網路位置。
    

---

## 進階建議

1. **設定為系統服務：** 使用 `sudo cloudflared service install` 讓隧道在樹莓派開機時自動啟動。
    
2. **Web 控制台：** 你也可以直接在 [Cloudflare Zero Trust Dashboard](https://one.dash.cloudflare.com/) 透過網頁介面建立隧道，完全不需要在終端機寫設定檔，這對新手更友好。

> cloudflared 可以用 systemctl 控制嗎？

可以的，`cloudflared` 完整支援 `systemd` (即 `systemctl`)，這也是在伺服器環境中確保服務穩定、開機自動啟動的最佳實踐。

以下是將 Cloudflare Tunnel 設定為系統服務的兩種主要方法：

### 方法一：使用內建指令自動安裝 (最推薦)

如果你已經手動建立了 `config.yml` 並測試成功，可以使用以下指令將其安裝為系統服務：

1. **執行安裝指令：**
    
    
```bash
sudo cloudflared service install
```

```
sudo cloudflared --config /home/username/.cloudflared/config.yml service install
```
    
_這個指令會自動根據你的設定檔，在 `/etc/systemd/system/` 下建立一個名為 `cloudflared.service` 的檔案，並將設定檔拷貝到 `/etc/cloudflared/`。_
    
2. **啟動並設定開機自啟：**
    
```bash
sudo systemctl enable cloudflared
sudo systemctl start cloudflared
```
    
3. **檢查狀態：**
    
```bash
sudo systemctl status cloudflared
```

---

### 方法二：透過 Cloudflare Dashboard (Zero Trust) 遠端管理

如果你是在 Cloudflare 官網後台的 **Zero Trust -> Networks -> Tunnels** 建立隧道，設定過程會更簡單。當你點擊 "Create a tunnel" 並選擇 Linux 時，網頁會直接提供你一段類似這樣的指令：

```bash
sudo cloudflared service install [YOUR_TOKEN_HERE]
```

**這種方式的優點：**

- **自動化：** 它會自動下載必要檔案並直接註冊成 `systemctl` 服務。
    
- **免設定檔：** 你不需要在樹莓派上手寫 `config.yml`，所有的網址對應 (Ingress Rules) 都可以直接在 Cloudflare 網頁上修改，修改後即刻生效，無需重啟服務。
    

---

### 常用的 systemctl 操作指令

一旦安裝完成，你就可以像管理其他 Linux 服務一樣操作它：

- **重啟服務：** `sudo systemctl restart cloudflared` (修改設定後常用)
    
- **停止服務：** `sudo systemctl stop cloudflared`
    
- 查看即時日誌：
    
如果隧道連線有問題，可以透過這條指令查看詳細報錯：

```bash
journalctl -u cloudflared -f
```
    

### 注意事項

- **權限問題：** 以系統服務執行時，`cloudflared` 通常會以 `root` 或專屬帳號運行，請確保你的憑證檔案 (cert.pem 或 json 檔) 的路徑是全域可讀取的（通常放在 `/etc/cloudflared/`）。
    
- **路徑偏移：** 使用 `service install` 指令後，預設的設定檔位置會從 `~/.cloudflared/` 移至 `/etc/cloudflared/`。如果你手動修改了原本家目錄下的設定，記得同步到 `/etc/` 下。

> 用 ssh 需要有什麼特別設置嗎？本來client可以透過IP直連，但用ssh.yourdomain.com之後就會卡在connecting。

這是非常經典的問題！SSH 和網頁（HTTP）的運作方式不同，不能直接用瀏覽器或一般的 SSH 指令連線。

原因是 **Cloudflare 預設只處理 HTTP/HTTPS 流量**。當你嘗試 `ssh user@ssh.yourdomain.com` 時，Cloudflare 會認為這是網頁請求，導致連線被阻斷。

要解決這個問題，你有兩種主要方式：

---

### 方法一：客戶端也安裝 cloudflared (最穩定)

這是 Cloudflare 官方推薦的做法。你的連線邏輯會變成：

你的電腦 (SSH Client) <-> cloudflared <-> Cloudflare <-> 樹莓派 (Server)

1. **在你的電腦（Client）安裝 cloudflared**：
    - **Windows (PowerShell):** `winget install Cloudflare.cloudflared`
    - **Mac (Homebrew):** `brew install cloudflared`
        
2. **修改你的 SSH 設定檔**：
    在你的電腦（不是樹莓派）編輯 ~/.ssh/config（Windows 通常在 C:\Users\你的名字\.ssh\config），加入以下內容：
    
    ```
    Host ssh.yourdomain.com
        ProxyCommand cloudflared access ssh --hostname %h
    ```
    
3. **直接連線**：
    現在你只需要輸入原本的指令，它就會自動透過隧道連線了：
    
    ```bash
    ssh pi@ssh.yourdomain.com
    ```
    

---

### 方法二：使用瀏覽器終端機 (無須安裝工具)

如果你在別人的電腦上，無法安裝 `cloudflared`，你可以開啟 Cloudflare 的「網頁版 SSH」。

1. 登入 **Cloudflare Zero Trust Dashboard**。
    
2. 前往 **Access** -> **Applications** -> **Add an application**。
    
3. 選擇 **Self-hosted**，設定名稱並輸入你的子網域 `ssh.yourdomain.com`。
    
4. 在 **Settings** 分頁中，找到 **Browser-rendered terminal** 並將其勾選開啟。
    
5. 設定完成後，你只要在瀏覽器輸入 `https://ssh.yourdomain.com`，通過身分驗證後，網頁就會直接跳出一個終端機視窗供你操作。
    
---

### 為什麼會卡住？（技術細節）

當你使用網域連線時，封包會先到達 Cloudflare 的邊緣伺服器。

- **HTTP:** Cloudflare 知道如何拆解並轉發。
    
- **SSH:** 這是一種非 HTTP 的 TCP 協議。Cloudflare 為了安全，預設不會隨便轉發 TCP 封包，除非你使用 `cloudflared` 工具將 SSH 封包封裝在 WebSocket 隧道中（這就是方法一 `ProxyCommand` 在做的事）。
    

---

### 檢查清單 (Troubleshooting)

如果還是連不上，請確認：

1. **樹莓派端設定：** 在 `config.yml` 或 Dashboard 中，`service` 是否正確指向 `ssh://localhost:22`。
    
2. **防火牆：** 樹莓派本身的 `ufw` 或 `iptables` 是否允許本機 22 埠（通常預設是開的）。
    
3. **Zero Trust 策略：** 如果你在後台設定了 **Access Policy**（例如限制只有你的 Email 能登入），請確保你在連線時有完成身分驗證。
    

**您目前的客戶端（你的電腦）是 Windows 還是 Mac/Linux？我可以提供更詳細的 `~/.ssh/config` 設定說明。**
