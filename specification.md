# 🧓 Dự án: "An Tâm" – Hệ thống Hỗ trợ Chăm sóc Người cao tuổi

## 1. Tổng quan Dự án (Project Overview)

**“An Tâm”** là một hệ thống ứng dụng “ghép cặp” được thiết kế để kết nối **con cái (đang đi làm, bận rộn)** với **cha mẹ lớn tuổi (sống một mình hoặc ở xa)**.

**Mục tiêu:**  
Giải quyết nỗi lo “Không biết bố mẹ có ổn không?” và rào cản công nghệ của người già, bằng cách tạo ra một cầu nối công nghệ đơn giản nhưng đáng tin cậy.

**Cấu trúc hệ thống gồm hai ứng dụng:**

- **An Tâm – Con:**  
  Dành cho người chăm sóc.  
  Ứng dụng như “trung tâm chỉ huy” để lên lịch, theo dõi, và nhận cảnh báo.
- **An Tâm – Cha Mẹ:**  
  Dành cho người cao tuổi.  
  Giao diện siêu đơn giản (1–3 nút lớn) để check-in hoặc gọi khẩn cấp.

---

## 2. Bối cảnh & Vấn đề (Business Problem & Context)

### Hiện trạng

Ngày càng nhiều người trẻ sống xa cha mẹ, trong khi cha mẹ lớn tuổi cần được quan tâm nhiều hơn.

#### Vấn đề chính:

1. **Nỗi lo thường trực (Carer’s Anxiety):**
   - “Bố đã uống thuốc huyết áp sáng nay chưa?”
   - “Mẹ ở nhà một mình, lỡ bị ngã thì sao?”
   - “Mình bận họp, quên gọi điện nhắc bố mẹ ăn cơm.”

2. **Sự phức tạp của công nghệ:**
   - Người lớn tuổi thấy các ứng dụng như Zalo, Messenger quá rắc rối.
   - Việc “dạy” họ dùng smartphone gây áp lực lớn cho con cái.

3. **Quên và nhầm lẫn:**
   - Người lớn tuổi dễ quên giờ uống thuốc, lịch tái khám.
   - Người con cũng dễ quên nhắc do quá bận, có thể dẫn đến hậu quả nghiêm trọng.

### Cơ hội (Opportunity)

Xây dựng **“cầu nối công nghệ vô hình”**:  
Người con xử lý mọi phức tạp; người cha/mẹ chỉ cần **một hành động đơn giản** – bấm nút, để con cái an tâm ngay lập tức.

---

## 3. Đối tượng Người dùng (Target Audience)

### Persona 1 – “Người Con Bận rộn” (The Carer)
- **Độ tuổi:** 30–45.
- **Đặc điểm:** Đi làm, am hiểu công nghệ, sống xa cha mẹ.
- **Nhu cầu:** Muốn biết tình trạng của cha mẹ (đặc biệt việc uống thuốc) mà không cần gọi điện liên tục.

### Persona 2 – “Người Cha/Mẹ Lớn tuổi” (The Elder)
- **Độ tuổi:** 65+.
- **Đặc điểm:** Sống một mình hoặc với vợ/chồng, không rành công nghệ, hay quên.
- **Nhu cầu:** Giữ độc lập, không muốn làm phiền con cái, có cách đơn giản để gọi trợ giúp khi cần.

---

## 4. Yêu cầu Chức năng (Functional Requirements - FRs)

### FR1 – Module "Thiết lập Lịch trình" *(App “Con”)*
- **FR1.1:** Tạo lịch uống thuốc chi tiết cho Cha/Mẹ.  
  Ví dụ:
  - “Thuốc Huyết áp – 8:00 sáng – hàng ngày – 1 viên”
  - “Thuốc Tiểu đường – 6:00 tối – hàng ngày – 2 viên”
- **FR1.2:** Tạo lịch hẹn khám:  
  Ví dụ: “Tái khám Tim mạch – 9:00, Thứ Sáu, 15/11”.

### FR2 – Module "Check-in Đơn giản" *(App “Cha Mẹ”)*
- **FR2.1:** Giao diện tối giản: chỉ **3 nút lớn**.
- **FR2.2:** Nút **SOS (Khẩn cấp):** Gọi điện thoại trực tiếp đến “Ứng dụng Con”.
- **FR2.3:** Nút **Check-in:** Khi đến giờ thuốc → ứng dụng phát âm báo & hiển thị nút:  
  `[BẤM VÀO ĐÂY ĐỂ BÁO ĐÃ UỐNG THUỐC]`.
- **FR2.4:** Nút **Gọi Con:** Gửi yêu cầu “Gọi lại khi rảnh”.

### FR3 – Module "Bảng điều khiển An Tâm" *(App “Con”)*
- **FR3.1:** Dashboard trạng thái hiển thị:  
  - “Thuốc Huyết áp sáng: Đã uống lúc 8:05.”
  - “Thuốc Tiểu đường tối: Chưa uống.”
- **FR3.2:** Hệ thống cảnh báo:  
  Nếu 8:30 mà cha/mẹ chưa bấm nút, gửi thông báo:  
  “Cảnh báo! Cha/Mẹ chưa xác nhận uống thuốc Huyết áp sáng.”
- **FR3.3:** Nhận cảnh báo SOS: Cuộc gọi & thông báo khẩn cấp.
- **FR3.4:** Lịch sử Check-in: Xem tỷ lệ tuân thủ uống thuốc theo tháng.

### FR4 – Module "Kết nối Gia đình" *(Tính năng mở rộng)*
- **FR4.1:** Chia sẻ ảnh gia đình: App “Con” tải ảnh, App “Cha Mẹ” hiển thị dạng slideshow khi không dùng.

---

## 5. Yêu cầu Phi chức năng (Non-Functional Requirements - NFRs)

- **NFR1: Tính dễ sử dụng & Khả năng truy cập (Accessibility):**
  - Font cực lớn, độ tương phản cao, hỗ trợ **Text-to-Speech** cho mọi nút.

- **NFR2: Độ tin cậy (Reliability):**
  - Hệ thống cảnh báo (FR3.2) & nút **SOS (FR2.2)** phải hoạt động **100% chính xác**, kể cả khi mạng yếu.

- **NFR3: Cài đặt tối giản:**
  - Người Con cài đặt toàn bộ; cha mẹ không cần đăng nhập hay cấu hình.

- **NFR4: Tối ưu pin:**
  - App chạy nền nhẹ, đặc biệt app “Cha Mẹ” vì người già hay quên sạc.

---

## 6. Ràng buộc & Giả định (Constraints & Assumptions)

- **Ràng buộc 1:** Cha/Mẹ phải có smartphone hoặc tablet có Internet (Wifi/4G).
- **Ràng buộc 2:** Ứng dụng **không thay thế thiết bị y tế chuyên dụng** hay dịch vụ chăm sóc tại chỗ.

- **Giả định 1:** Cha/Mẹ có khả năng hiểu hai hành vi cơ bản:
  - “Bấm nút khi uống thuốc xong.”
  - “Bấm nút đỏ khi gặp nguy hiểm.”
- **Giả định 2:** Người Con chịu trách nhiệm 100% về tính chính xác của lịch thuốc.
