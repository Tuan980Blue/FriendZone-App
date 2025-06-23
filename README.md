<h1 align="center">❤️ FriendZone App ❤️</h1>

<p align="center">
  <a href="https://anhtuandev.id.vn/" target="_blank"><strong>🔗 Xem bản preview web tại đây</strong></a>
</p>

---

## 🧾 Giới thiệu

**FriendZone** là một ứng dụng mạng xã hội **thời gian thực** lấy cảm hứng từ *Instagram*.  
Người dùng có thể nhắn tin, tương tác bài post, và cập nhật trạng thái ngay **lập tức** nhờ vào WebSocket — **không cần F5!**

---

## 📸 Giao diện Minh Hoạ

<p align="center">
  <img src="https://github.com/user-attachments/assets/da070465-89f6-4455-b4b4-753fccac89dd" alt="Giao diện 1" width="200"/>
  <img src="https://github.com/user-attachments/assets/f6d9a9d9-8777-4e7e-872b-3189e6903c96" alt="Giao diện 2" width="200"/>
</p>

---



## 🚀 Tính năng nổi bật

- 📝 <span style="font-size:16px"><strong>Đăng bài viết:</strong></span> Chia sẻ nội dung cá nhân một cách dễ dàng.  
- ❤️ <strong>Tương tác bài đăng:</strong> Like, bình luận và kết nối với bạn bè.  
- 🔥 <strong>Giao tiếp thời gian thực:</strong> Tin nhắn & thông báo được cập nhật ngay lập tức qua WebSocket.  
- 💬 <strong>Phòng chat riêng & nhóm:</strong> Giao tiếp 1-1 hoặc theo nhóm cực kỳ mượt mà.  
- 🟢 <strong>Trạng thái người dùng:</strong> Biết ngay ai đang online/offline.  
- 📸 <strong>Cập nhật trạng thái:</strong> Chia sẻ cảm xúc, hình ảnh, hoặc bất kỳ điều gì bạn muốn.  
- 🔐 <strong>Xác thực người dùng:</strong> Bảo mật an toàn bằng JWT.  
- 📱 <strong>Responsive UI:</strong> Giao diện mượt mà, tương thích trên mọi thiết bị.

---

## 🧱 Công nghệ sử dụng

| 💡 Thành phần    | ⚙️ Công nghệ                                           |
|------------------|--------------------------------------------------------|
| **Backend**      | Node.js, Express.js, WebSocket (`ws` / `socket.io`)    |
| **Frontend**     | Flutter                                                |
| **Database**     | MongoDB                                                |
| **Authentication** | JWT                                                 |
| **Realtime Layer** | Socket.IO / WebSocket API                            |

---

## 📐 Áp dụng nguyên lý SOLID

> *Dự án tuân thủ đầy đủ các nguyên tắc SOLID để mã nguồn sạch, rõ ràng và dễ mở rộng.*

### 🧩 **S – Single Responsibility Principle**
- Mỗi repository chỉ chịu trách nhiệm một domain: `Auth`, `Post`, `User`.
- Mỗi Use Case thực hiện đúng một nhiệm vụ: `Login`, `Register`, `GetPosts`...
- Các Data Source được tách riêng: `AuthRemoteDataSource`, `PostRemoteDataSource`.

### 🧱 **O – Open/Closed Principle**
- Repository xây dựng dưới dạng abstract class.
- Có thể mở rộng repository mà không cần chỉnh sửa code cũ.
- `UseCase` kế thừa `UseCase<Type, Params>` để dễ dàng mở rộng.

### 🔁 **L – Liskov Substitution Principle**
- Implementation như `AuthRepositoryImpl` có thể thay thế interface của nó mà không làm thay đổi hành vi.

### 🔍 **I – Interface Segregation Principle**
- Interface được chia nhỏ theo domain: `AuthRepository`, `PostRepository`, `UserRepository`.
- Không ép buộc các implementation chứa những phương thức không dùng đến.

### 🧠 **D – Dependency Inversion Principle**
- Use Case chỉ phụ thuộc vào abstraction (interface).
- Dùng dependency injection qua constructor và `get_it`.

---

## 👤 Tác giả

- 💼 Website: [anhtuandev.id.vn](https://tuananhhuflit.id.vn/)
- 📧 Email: anhtuan21jr@gmail.com

---

<p align="center">
  ⭐️ Cảm ơn bạn đã ghé thăm! Nếu thấy hữu ích, hãy để lại một ⭐️ nhé!
</p>
