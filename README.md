
```markdown
# 🚀 Debian Production-Grade Mail Server

一个专为 Debian 系统打造的生产级、高送达率、易管理的轻量级邮件服务器自动化部署与管理套件。完美解决云厂商 25 端口限制问题，支持通过 SMTP Relay 中继安全发信。

---

## 📥 一键部署脚本

请根据您的服务器网络环境及下载工具，选择以下 **5 种方式之一**进行一键部署：

### 1. curl 方式（海外 / 通用）
```bash
mkdir -p ~/debian-mail-server && cd ~/debian-mail-server && curl -sSL [https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/mail.sh](https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/mail.sh) -o mail.sh && curl -sSL [https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/deploy.sh](https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/deploy.sh) -o deploy.sh && curl -sSL [https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/manage.sh](https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/manage.sh) -o manage.sh && curl -sSL [https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/uninstall.sh](https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/uninstall.sh) -o uninstall.sh && chmod +x *.sh && ./mail.sh

```

### 2. curl 方式（国内 CDN 加速）

```bash
mkdir -p ~/debian-mail-server && cd ~/debian-mail-server && curl -sSL [https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/mail.sh](https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/mail.sh) -o mail.sh && curl -sSL [https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/deploy.sh](https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/deploy.sh) -o deploy.sh && curl -sSL [https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/manage.sh](https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/manage.sh) -o manage.sh && curl -sSL [https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/uninstall.sh](https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/uninstall.sh) -o uninstall.sh && chmod +x *.sh && ./mail.sh

```

### 3. wget 方式（海外 / 通用）

```bash
mkdir -p ~/debian-mail-server && cd ~/debian-mail-server && wget -q [https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/mail.sh](https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/mail.sh) -O mail.sh && wget -q [https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/deploy.sh](https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/deploy.sh) -O deploy.sh && wget -q [https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/manage.sh](https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/manage.sh) -O manage.sh && wget -q [https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/uninstall.sh](https://raw.githubusercontent.com/nqwtim/debian-mail-server/main/uninstall.sh) -O uninstall.sh && chmod +x *.sh && ./mail.sh

```

### 4. wget 方式（国内 CDN 加速）

```bash
mkdir -p ~/debian-mail-server && cd ~/debian-mail-server && wget -q [https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/mail.sh](https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/mail.sh) -O mail.sh && wget -q [https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/deploy.sh](https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/deploy.sh) -O deploy.sh && wget -q [https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/manage.sh](https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/manage.sh) -O manage.sh && wget -q [https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/uninstall.sh](https://cdn.jsdelivr.net/gh/nqwtim/debian-mail-server@main/uninstall.sh) -O uninstall.sh && chmod +x *.sh && ./mail.sh

```

### 5. Git 克隆方式（开发者推荐 / 支持 git pull 更新）

```bash
git clone [https://github.com/nqwtim/debian-mail-server.git](https://github.com/nqwtim/debian-mail-server.git) ~/debian-mail-server && cd ~/debian-mail-server && chmod +x *.sh && ./mail.sh

```

---

## 🛠️ 脚本组件说明

* **`mail.sh`**：主控制面板，提供交互式管理界面，支持 ASCII 兼容模式，杜绝乱码隐患。
* **`deploy.sh`**：核心部署脚本，自动安装配置 Postfix、Dovecot、OpenDKIM 及 SSL 证书。
* **`manage.sh`**：账号管理脚本，用于快捷增删改查邮箱用户及密码。
* **`uninstall.sh`**：一键彻底卸载与清理残留环境。

---

## 🌐 生产级邮件服务器 DNS & rDNS 完整解析配置指南

要保证邮件服务器能够**正常收发邮件**并且**不落入垃圾箱**（进 Inbox 而非 Spam），必须在 DNS 服务商（如 Cloudflare、DNSPod 等）以及 VPS 提供商处完成以下解析配置。

---

### 一、 基础通信记录 (A & MX)

基础记录用于定位你的邮件服务器 IP 以及指定域名的邮件接收入口。

#### 1. A 记录 (或 AAAA 记录)

* **主机记录 (Host)**: `mail`
* **记录值 (Value)**: `你的服务器公网 IP` (例如 `159.54.188.214`)
* **作用**: 将邮件服务器域名映射到具体服务器 IP。

> ⚠️ **Cloudflare 用户特别注意**：如果使用 Cloudflare，**必须将云朵状态设置为“仅限 DNS (灰色小云朵)”**，切勿开启 CDN 代理（黄色小云朵），否则会阻断 SMTP/IMAP 非 HTTP 协议端口！

#### 2. MX 记录 (Mail Exchanger)

* **主机记录 (Host)**: `@` (或留空，表示主域名)
* **记录值 (Value)**: `mail.yourdomain.com`
* **MX 优先级**: `10`
* **作用**: **收信必需**。告诉全网所有发信服务器，发往 `@yourdomain.com` 的邮件应该投递给哪台服务器。

---

### 二、 邮件安全与防伪造三剑客 (SPF, DKIM, DMARC)

这三项配置用于向 Gmail、Outlook、QQ 邮箱等权威服务商证明“这封邮件确实由你合法发送”，是防止邮件进垃圾箱的关键。

#### 1. SPF 记录 (Sender Policy Framework)

声明哪些 IP 或服务商有权代表你的域名发信。

* **记录类型**: `TXT`
* **主机记录 (Host)**: `@`
* **记录值 (Value)**:
* **25 端口直连发信**:
```text
v=spf1 mx ip4:你的服务器IP ~all

```


* **使用了 SMTP Relay 中继发信 (以甲骨文 OCI 为例)**:
```text
v=spf1 mx include:oraclecloud.com ~all

```


* **使用了 Brevo / Sendinblue 中继**:
```text
v=spf1 mx include:spf.brevo.com ~all

```





> 💡 **参数语法详解**:
> * `v=spf1`: 必须以此开头，标识 SPF 协议版本。
> * `mx`: 允许当前域名的 MX 记录 IP 发信。
> * `ip4:x.x.x.x`: 明确指定允许发信的 IPv4 地址。
> * `include:xxx`: 授权第三方中继服务商代表本域名发信。
> * `~all` (SoftFail): 建议值，表示未列出的 IP 属于“疑似伪造”，通常会将邮件放入垃圾箱而非直接丢弃。
> 
> 

---

#### 2. DKIM 记录 (DomainKeys Identified Mail)

利用数字签名机制对发出的每封邮件进行防篡改签名，接收方通过 DNS 上的公钥进行校验。

* **记录类型**: `TXT`
* **主机记录 (Host)**: `mail._domainkey` *(注：`mail` 为 OpenDKIM 的默认 Selector 选项)*
* **记录值 (Value)**: `v=DKIM1; k=rsa; p=你的公钥内容...`

##### 🔑 如何获取并拼接 DKIM 记录值？

在服务器上完成 `deploy.sh` 部署后，运行以下命令获取密钥：

```bash
cat /etc/postfix/dkim/mail.txt

```

控制台会输出类似如下内容：

```text
mail._domainkey IN TXT ( "v=DKIM1; h=sha256; k=rsa; "
  "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC3..."
  "..." )  ; ----- DKIM key mail for yourdomain.com

```

👉 **拼接方式**: 提取括号内 `p=` 后面的所有字符串，去掉**双引号**、**空格**与**换行**，将其合并为一整段连续的长字符串粘贴至 DNS 的 TXT Value 框中。

---

#### 3. DMARC 记录 (Domain-based Message Authentication)

告诉接收方当邮件未通过 SPF 或 DKIM 校验时该如何处理，并接收合规报告。

* **记录类型**: `TXT`
* **主机记录 (Host)**: `_dmarc`
* **记录值 (Value)**:
```text
v=DMARC1; p=none; rua=mailto:dmarc-reports@yourdomain.com; ruf=mailto:dmarc-reports@yourdomain.com; fo=1;

```



> 💡 **参数语法详解**:
> * `v=DMARC1`: DMARC 协议版本。
> * `p=none`: 监控模式（推荐初期使用）。即使校验失败也正常接收，仅生成报告。稳定后可升级为 `p=quarantine` (隔离到垃圾箱) 或 `p=reject` (直接拒收)。
> * `rua=mailto:...`: 接收每日汇总分析报告的邮箱。
> * `ruf=mailto:...`: 接收即时失败异常报告的邮箱。
> * `fo=1`: 只要 SPF 或 DKIM 其中一项失败就发送失败报告。
> 
> 

---

### 三、 反向 DNS 解析 (PTR / rDNS)

PTR (Pointer Record) 用于将服务器 IP 反向解析为域名。各大邮件服务商（尤其是 Gmail）会强制校验 IP 的 PTR 是否与发件域名匹配。

* **作用**: 证明这台 VPS IP 的使用者确实拥有该域名，大幅提升信任度（防垃圾拦截核心依据）。
* **⚠️ 关键区别**: **PTR 记录不在域名解析商 (Cloudflare / DNSPod) 处设置，而是在 your VPS 厂商控制台设置！**

#### 常见云厂商 PTR 配置路径：

* **甲骨文云 (Oracle Cloud OCI)**: 实例详情页 -> 附加的 VNIC -> IPv4 地址 -> 编辑 -> **反向 DNS 域名 (Reverse DNS)** -> 填入 `mail.yourdomain.com`。
* **Vultr / DigitalOcean / Linode**: 网络 (Networking) -> IP 管理 -> **Reverse DNS / PTR** -> 编辑并填入 `mail.yourdomain.com`。
* **阿里云 / 腾讯云 (海外节点)**: 工单系统或 IP 地址管理页面申请添加 rDNS。

---

### 四、 客户端自动配置与服务发现记录 (SRV & CNAME)

添加以下记录后，第三方客户端（如 Outlook、Thunderbird、Apple Mail 等）在登录时只需输入邮箱与密码，即可自动填入 IMAP 和 SMTP 服务器地址与端口。

#### 1. CNAME 自动发现记录

| 记录类型 | 主机记录 (Host) | 解析值 (Value) | 作用 |
| --- | --- | --- | --- |
| **CNAME** | `autoconfig` | `mail.yourdomain.com` | Thunderbird / Mozilla 体系客户端自动配置 |
| **CNAME** | `autodiscover` | `mail.yourdomain.com` | Outlook / Microsoft 体系客户端自动配置 |

#### 2. SRV 协议服务记录

明确宣告服务开启的加密端口与主机名：

* **IMAP 安全连接 SRV 记录**:
* **记录类型**: `SRV`
* **主机记录 (Host)**: `_imaps._tcp`
* **优先级 (Priority)**: `0`
* **权重 (Weight)**: `0`
* **端口 (Port)**: `993`
* **目标 (Target)**: `mail.yourdomain.com`


* **SMTP 加密发信 SRV 记录**:
* **记录类型**: `SRV`
* **主机记录 (Host)**: `_submission._tcp`
* **优先级 (Priority)**: `0`
* **权重 (Weight)**: `0`
* **端口 (Port)**: `587`
* **目标 (Target)**: `mail.yourdomain.com`



---

### 五、 💡 使用 OCI / 第三方 SMTP Relay 中继时的 DNS 特殊配置

如果开启了中继发信避开云厂商 25 端口限制（如 Oracle Cloud OCI Email Delivery），DNS 校验策略需作如下调整：

1. **SPF 必须包含中继源**：将 SPF 记录修改为 `v=spf1 mx include:oraclecloud.com ~all`。
2. **DKIM 需由云厂商托管**：无需在本地配置 OpenDKIM，请直接在 OCI 控制台的 `Email Delivery` -> `DKIM Keys` 中创建 DKIM，并将 OCI 提供的两条 CNAME 或 TXT 记录添加至 DNS。
3. **DMARC 保持不变**：照常添加 `_dmarc` 的 TXT 记录即可。

---

### 六、 全套 DNS 配置快速速查表

| 分类 | 记录类型 | 主机记录 (Host) | 解析值 / 指向内容 (Value) | 备注 / 优先级 |
| --- | --- | --- | --- | --- |
| **基础** | **A** | `mail` | `服务器 IP` | 需关闭 Cloudflare 代理 |
| **基础** | **MX** | `@` | `mail.yourdomain.com` | 优先级 `10` |
| **安全** | **TXT (SPF)** | `@` | `v=spf1 mx ip4:服务器IP ~all` | 若用中继需加 `include:` |
| **安全** | **TXT (DKIM)** | `mail._domainkey` | `v=DKIM1; k=rsa; p=公钥...` | 来源于本地或中继控制台 |
| **安全** | **TXT (DMARC)** | `_dmarc` | `v=DMARC1; p=none; rua=...` | 监控与失败策略 |
| **自动发现** | **CNAME** | `autoconfig` | `mail.yourdomain.com` | Thunderbird 自动配置 |
| **自动发现** | **CNAME** | `autodiscover` | `mail.yourdomain.com` | Outlook 自动配置 |
| **服务发现** | **SRV** | `_imaps._tcp` | `mail.yourdomain.com` | 端口 `993`, 优先级/权重 `0` |
| **服务发现** | **SRV** | `_submission._tcp` | `mail.yourdomain.com` | 端口 `587`, 优先级/权重 `0` |
| **反向解析** | **PTR** | `IP 地址` | `mail.yourdomain.com` | **必须在 VPS 后台设置** |

---

## 🧪 验证与测试工具

配置完成后（由于 DNS 存在生效缓存，通常需等待 5-15 分钟），建议使用以下在线工具检测配置正确性：

1. **综合发信得分测试 (强烈推荐)**: [Mail-Tester](https://www.mail-tester.com/) （按照提示发送测试邮件，完美配置可获得 10/10 满分）
2. **MX / SPF / DKIM 在线检测**: [MXToolbox](https://mxtoolbox.com/)
3. **DMARC 验证工具**: [DMARC Analyzer](https://www.dmarcanalyzer.com/)

```

```
