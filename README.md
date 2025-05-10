### 🌐 [Link-PreView-Version-Web](https://anhtuandev.id.vn/)

**FriendZone** là một nền tảng mạng xã hội lấy cảm hứng từ **Instagram**, phần mềm thời gian thực được xây dựng với WebSocket, nơi người dùng có thể nhắn tin, tương tác và cập nhật trạng thái ngay lập tức – không cần F5!

## 🚀 Tính năng nổi bật

- 🔥 **Giao tiếp thời gian thực** – Tin nhắn, phản hồi, và thông báo được cập nhật ngay lập tức nhờ WebSocket.
- 👥 **Phòng chat riêng và nhóm** – Giao tiếp 1-1 hoặc theo nhóm cực kỳ mượt mà.
- 📡 **Trạng thái người dùng** – Ai đang online/offline?.
- 📝 **Cập nhật trạng thái** – Chia sẻ cảm xúc, hình ảnh, hay bất cứ điều gì bạn muốn.
- 🔒 **Xác thực người dùng** – Bảo mật bằng JWT.
- 📱 **Responsive UI** – Giao diện đẹp, mượt mà trên mọi thiết bị.

## 🧱 Công nghệ sử dụng

- **Backend**: Node.js, Express.js, WebSocket (ws/socket.io)
- **Frontend**: React / NextJs
- **Database**: MongoDB 
- **Auth**: JWT 
- **Realtime Layer**: Socket.IO / ws / WebSocket API

### 🚀 Work Follow Chat Online
![workfollow-Chat](https://github.com/user-attachments/assets/9dbb4cc1-0bde-463e-97c5-f9b32ab46fa0)
![workfollow-Chat](https://github.com/user-attachments/assets/e1d02694-4fde-4e6b-bf35-c291943c1e63)

### 🚀 📝 State Message Chat Online
![workfollow-Chat](https://github.com/user-attachments/assets/c97715b3-7fc4-4d6e-a249-cc71f7a6d852)

## setup cho dự án :
Frontend: Deploy trên Vercel
Có CI/CD tự động
Backend: Deploy trên Render
Hỗ trợ WebSocket tốt
Dễ dàng kết nối với MongoDB
Có SSL miễn phí
Database: Sử dụng MongoDB
Ổn định và đáng tin cậy
Dễ dàng backup và restore
Có monitoring tools
WebSocket: Có 2 lựa chọn:
Sử dụng WebSocket trực tiếp từ backend (nếu deploy trên Render)

## Cơ chế
Tạo tin nhắn tạm thời ngay khi người dùng gửi:
Tạo một tempMessage với đầy đủ thông tin (ID, nội dung, người gửi, người nhận, thời gian)
Sử dụng timestamp làm ID tạm thời
Thêm thông tin người gửi và người nhận từ state hiện tại
Cập nhật state ngay lập tức:
Thêm tin nhắn vào messages state để hiển thị ngay
Cập nhật chats state để hiển thị tin nhắn mới nhất trong danh sách chat
Gửi tin nhắn qua WebSocket:
Sau khi cập nhật UI, gửi tin nhắn qua WebSocket
Nếu có lỗi, có thể thêm logic để xóa tin nhắn tạm thời
Thêm kiểm tra user:
Kiểm tra user tồn tại trước khi gửi tin nhắn
Thêm user vào dependencies của useCallback
Cách này sẽ giúp:
Tin nhắn hiển thị ngay lập tức khi gửi
Người dùng thấy được tin nhắn của mình ngay lập tức
Vẫn đảm bảo tin nhắn được gửi qua WebSocket
Có thể xử lý lỗi nếu gửi thất bại

## 
WebSocket: Giao thức kết nối hai chiều, cho phép server gửi dữ liệu đến client mà không cần client yêu cầu.
Quản lý kết nối: Server biết người dùng nào đang online và có thể gửi tin nhắn đến họ ngay lập tức.
Optimistic UI: Client hiển thị tin nhắn ngay lập tức, không cần đợi phản hồi từ server.
Xử lý sự kiện: Client đăng ký handler cho sự kiện receive_message để cập nhật UI khi nhận được tin nhắn mới.
Đây là một thiết kế tốt cho hệ thống chat real-time, cho phép tin nhắn được gửi và nhận ngay lập tức, đồng thời đảm bảo độ tin cậy và khả năng mở rộng.
