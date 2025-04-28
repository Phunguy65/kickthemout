# Giải thích Chi tiết Kỹ thuật "Kick" bằng ARP Spoofing (như trong KickThemOut)

Kỹ thuật này khai thác giao thức ARP (Address Resolution Protocol) để làm gián đoạn kết nối mạng của các thiết bị trong mạng cục bộ (LAN). Công cụ như `kickthemout.py` tập trung vào việc "đá" (kick) thiết bị ra khỏi mạng bằng cách gửi các gói tin ARP giả mạo, khiến thiết bị mục tiêu không thể liên lạc chính xác với gateway (router) và do đó, mất kết nối Internet.

**Giao thức ARP là gì?**
Trong mạng Ethernet, các thiết bị giao tiếp với nhau bằng địa chỉ MAC (Media Access Control - địa chỉ vật lý). Khi một thiết bị (ví dụ: máy tính của bạn) muốn gửi dữ liệu đến một địa chỉ IP khác trong cùng mạng LAN (ví dụ: gateway), nó cần biết địa chỉ MAC tương ứng với địa chỉ IP đó. ARP là giao thức giúp thực hiện việc ánh xạ này. Thiết bị sẽ gửi một bản tin ARP Request dạng "Ai có địa chỉ IP X.X.X.X? Hãy cho tôi biết địa chỉ MAC của bạn." Thiết bị có địa chỉ IP đó sẽ trả lời bằng một bản tin ARP Reply chứa địa chỉ MAC của nó.

**Cảnh báo:** Việc sử dụng kỹ thuật ARP Spoofing trên mạng không thuộc quyền sở hữu hoặc quản lý của bạn là hành vi vi phạm pháp luật và đạo đức. Thông tin dưới đây chỉ nhằm mục đích phân tích kỹ thuật và giáo dục về bảo mật.

## Các Bước Thực Hiện Chi Tiết (Theo logic KickThemOut)

### Bước 1: Thu thập Thông tin Mạng

**Mục tiêu:** Trước khi tấn công, kẻ tấn công cần biết:
1.  **Địa chỉ IP và MAC của thiết bị mục tiêu:** Để biết gửi gói tin giả mạo đến đâu.
2.  **Địa chỉ IP của Gateway (Router):** Đây là địa chỉ IP mà kẻ tấn công sẽ "mạo danh" trong gói tin ARP giả mạo.
3.  **Địa chỉ MAC của Gateway:** Cần thiết để khôi phục kết nối cho mục tiêu sau khi tấn công kết thúc.
4.  **Địa chỉ MAC của máy tấn công:** Địa chỉ này sẽ được đưa vào gói tin ARP giả mạo.

**Cách thực hiện trong `kickthemout.py`:**
*   **Quét mạng:** Sử dụng module `scan.py` (gọi thư viện `nmap`), công cụ gửi các gói tin (thường là ARP request hoặc ICMP echo request) để khám phá các thiết bị đang hoạt động trong mạng và địa chỉ IP của chúng. Sau đó, nó gửi ARP request đến các IP tìm được để lấy địa chỉ MAC tương ứng.
    ```bash
    # Lệnh nmap tương tự được scan.py sử dụng:
    nmap -sn [Dải_Mạng_Của_Bạn] # Ví dụ: 192.168.1.0/24
    ```
*   **Lấy thông tin Gateway và Attacker:** `kickthemout.py` sử dụng các hàm của thư viện Scapy để:
    *   Tự động xác định default gateway IP (ví dụ: bằng cách gửi gói tin tới một địa chỉ bên ngoài và xem IP nguồn của gói tin trả về).
    *   Lấy địa chỉ MAC của gateway bằng cách gửi ARP request tới IP gateway.
    *   Lấy địa chỉ MAC của chính interface mạng đang sử dụng trên máy tấn công (`get_if_hwaddr(defaultInterface)`).

**Ví dụ thông tin thu thập được:**
*   Mục tiêu: `target_ip = "192.168.1.100"`, `target_mac = "BB:BB:BB:BB:BB:BB"`
*   Gateway: `defaultGatewayIP = "192.168.1.1"`, `defaultGatewayMac = "AA:AA:AA:AA:AA:AA"`
*   Attacker: `my_mac = "CC:CC:CC:CC:CC:CC"`

### Bước 2: Chế tạo và Gửi Gói tin ARP Giả mạo (ARP Poisoning)

**Mục tiêu:** Lừa thiết bị mục tiêu tin rằng địa chỉ MAC của gateway đã thay đổi thành địa chỉ MAC của kẻ tấn công.

**Cơ chế:** Kẻ tấn công tạo ra một gói tin ARP Reply (có Opcode = 2, nghĩa là "đây là câu trả lời") và gửi nó trực tiếp đến địa chỉ MAC của mục tiêu.

**Cấu trúc gói tin ARP Reply giả mạo (theo `spoof.py`):**
*   **Lớp Ethernet (Layer 2):**
    *   `Source MAC`: `my_mac` (MAC của kẻ tấn công)
    *   `Destination MAC`: `target_mac` (MAC của mục tiêu)
*   **Lớp ARP:**
    *   `Opcode`: `2` (Reply)
    *   `Sender MAC Address (SHA)`: `my_mac` (MAC của kẻ tấn công - **đây là phần giả mạo cốt lõi**)
    *   `Sender IP Address (SPA)`: `defaultGatewayIP` (IP của gateway - **kẻ tấn công mạo danh IP này**)
    *   `Target MAC Address (THA)`: `target_mac` (MAC của mục tiêu)
    *   `Target IP Address (TPA)`: `target_ip` (IP của mục tiêu)

Gói tin này về cơ bản nói với mục tiêu: "Tôi là `192.168.1.1` (IP Gateway), và địa chỉ MAC của tôi là `CC:CC:CC:CC:CC:CC` (MAC Attacker)."

**Cách thực hiện trong `kickthemout.py`:**
*   Hàm `spoof.sendPacket(my_mac, defaultGatewayIP, target_ip, target_mac)` được gọi liên tục trong một vòng lặp.
*   Hàm này sử dụng Scapy để tạo gói tin `Ether()/ARP()` với các trường được điền như mô tả ở trên.
*   Hàm `sendp()` của Scapy được sử dụng để gửi gói tin ra mạng ở Layer 2 (Ethernet).
*   Việc gửi lặp đi lặp lại là cần thiết vì các mục nhập trong ARP cache của thiết bị thường có thời gian tồn tại nhất định và sẽ hết hạn, hoặc thiết bị có thể chủ động gửi ARP request để xác minh lại.

```python
# --- Logic chính trong vòng lặp tấn công của kickthemout.py ---
import spoof
import time

# (Giả sử các biến my_mac, defaultGatewayIP, target_ip, target_mac đã có)
try:
    while True:
        # Tạo và gửi gói ARP Reply giả mạo tới mục tiêu
        # nói rằng IP gateway (defaultGatewayIP) có MAC của attacker (my_mac)
        spoof.sendPacket(my_mac, defaultGatewayIP, target_ip, target_mac)

        # In thông tin (ví dụ)
        # print(f"\r[+] Đã gửi gói độc tới {target_ip}", end="")

        # Chờ một khoảng thời gian trước khi gửi lại (có thể tùy chỉnh)
        time.sleep(10) # Mặc định trong kickthemout khi không có -p
except KeyboardInterrupt:
    # Chuyển sang bước khôi phục
    pass
```

### Bước 3: Hậu quả - Mục tiêu Mất Kết nối

**Tại sao mất kết nối?**
1.  **ARP Cache bị nhiễm độc:** Sau khi nhận gói tin ARP giả mạo, mục tiêu cập nhật bảng ARP cache của nó. Mục nhập cho `defaultGatewayIP` bây giờ trỏ đến `my_mac` (MAC của attacker).
2.  **Gửi lưu lượng sai địa chỉ:** Khi mục tiêu muốn gửi một gói tin ra Internet (ví dụ: truy cập google.com), nó cần gửi gói tin đó đến gateway. Hệ điều hành của mục tiêu nhìn vào ARP cache, thấy IP gateway (`192.168.1.1`) tương ứng với MAC `CC:CC:CC:CC:CC:CC`. Do đó, nó đóng gói gói tin IP vào một khung Ethernet với địa chỉ MAC đích là `CC:CC:CC:CC:CC:CC`.
3.  **Gói tin bị loại bỏ:** Khung Ethernet này đến được máy của kẻ tấn công. Tuy nhiên, máy tấn công (theo cấu hình của `kickthemout.py`) không phải là router và không được cấu hình để chuyển tiếp gói tin này đến gateway thật. Hệ điều hành của máy tấn công đơn giản là loại bỏ gói tin này vì nó không dành cho chính nó và không có chỉ dẫn phải làm gì tiếp theo.
4.  **Không có phản hồi:** Vì gói tin của mục tiêu không bao giờ đến được gateway thật và đi ra Internet, mục tiêu sẽ không nhận được bất kỳ phản hồi nào. Đối với người dùng trên máy mục tiêu, điều này biểu hiện như là mất kết nối mạng/Internet.

### Bước 4: Khôi phục Kết nối (Quan trọng!)

**Mục tiêu:** Sửa lại bảng ARP cache của mục tiêu về trạng thái đúng sau khi dừng tấn công.

**Cơ chế:** Kẻ tấn công gửi một (hoặc nhiều) gói tin ARP Reply *đúng* đến mục tiêu.

**Cấu trúc gói tin ARP Reply khôi phục:**
*   **Lớp Ethernet (Layer 2):**
    *   `Source MAC`: `defaultGatewayMac` (MAC *thật* của gateway)
    *   `Destination MAC`: `target_mac` (MAC của mục tiêu)
*   **Lớp ARP:**
    *   `Opcode`: `2` (Reply)
    *   `Sender MAC Address (SHA)`: `defaultGatewayMac` (MAC *thật* của gateway)
    *   `Sender IP Address (SPA)`: `defaultGatewayIP` (IP của gateway)
    *   `Target MAC Address (THA)`: `target_mac` (MAC của mục tiêu)
    *   `Target IP Address (TPA)`: `target_ip` (IP của mục tiêu)

Gói tin này thông báo cho mục tiêu: "Tôi là `192.168.1.1` (IP Gateway), và địa chỉ MAC *thật* của tôi là `AA:AA:AA:AA:AA:AA` (MAC Gateway)."

**Cách thực hiện trong `kickthemout.py`:**
*   Khi người dùng nhấn Ctrl+C (phát sinh `KeyboardInterrupt`), code sẽ nhảy vào khối `except`.
*   Một vòng lặp (`while reArp != 10`) được thực hiện để gửi gói tin khôi phục nhiều lần.
*   Trong mỗi lần lặp, hàm `spoof.sendPacket(defaultGatewayMac, defaultGatewayIP, target_ip, target_mac)` được gọi. Lưu ý các tham số giờ là thông tin *thật* của gateway.
*   Việc gửi nhiều lần giúp đảm bảo mục tiêu nhận được và cập nhật ARP cache của mình, ghi đè lên thông tin giả mạo trước đó.

```python
# --- Logic khôi phục trong khối except KeyboardInterrupt --- 
print("\n[*] Đã nhận tín hiệu dừng. Khôi phục mạng...")
reArp = 1
print(f"[*] Gửi gói tin ARP khôi phục tới {target_ip}...")
while reArp != 10:
    try:
        # Gửi gói ARP Reply đúng: IP Gateway thật và MAC Gateway thật
        spoof.sendPacket(defaultGatewayMac, defaultGatewayIP, target_ip, target_mac)
    except Exception as e_restore:
        print(f"\n[!] Lỗi khi khôi phục: {e_restore}")
    reArp += 1
    time.sleep(0.2)
print("\n[*] Đã gửi xong gói tin khôi phục.")
```

## Biện pháp Phòng chống

Việc phòng chống kỹ thuật này đòi hỏi các biện pháp bảo mật ở tầng mạng LAN:

*   **ARP tĩnh (Static ARP):** Quản trị viên cấu hình thủ công bảng ARP cho các địa chỉ IP quan trọng (như gateway) trên các máy client. Khi một mục nhập là tĩnh, hệ điều hành thường sẽ bỏ qua các cập nhật ARP động (bao gồm cả gói giả mạo) cho IP đó. Nhược điểm là khó quản lý và không linh hoạt cho các mạng lớn hoặc có DHCP.
*   **Phần mềm Phát hiện ARP Spoofing:** Các công cụ như `arpwatch` giám sát hoạt động ARP trên mạng. Chúng có thể phát hiện các dấu hiệu đáng ngờ, chẳng hạn như một địa chỉ IP đột ngột thay đổi địa chỉ MAC liên kết với nó, hoặc nhiều địa chỉ MAC cùng nhận một địa chỉ IP, và gửi cảnh báo cho quản trị viên.
*   **Dynamic ARP Inspection (DAI):** Đây là tính năng bảo mật mạnh mẽ trên các switch mạng quản lý được. DAI hoạt động dựa trên bảng DHCP Snooping (theo dõi việc cấp phát IP qua DHCP) hoặc các cấu hình ARP ACL tĩnh. Switch sẽ kiểm tra mọi gói tin ARP đi vào các cổng không tin cậy (untrusted ports - thường là cổng nối với client). Nếu thông tin IP-MAC trong gói ARP không khớp với bảng ghi đáng tin cậy, switch sẽ loại bỏ gói tin đó, ngăn chặn hiệu quả việc đầu độc ARP cache. Cổng nối đến gateway và DHCP server thường được cấu hình là cổng tin cậy (trusted ports).

Hiểu rõ cách ARP Spoofing hoạt động, như được minh họa qua công cụ `kickthemout.py`, là bước đầu tiên để nhận thức và triển khai các biện pháp bảo vệ mạng LAN hiệu quả. 