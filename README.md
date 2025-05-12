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
- **Frontend**: Flutter
- **Database**: MongoDB 
- **Auth**: JWT 
- **Realtime Layer**: Socket.IO / ws / WebSocket API

### 🚀SOLID CODE
 Dự án đã áp dụng các nguyên tắc SOLID:
Single Responsibility Principle (SRP):
Mỗi repository chỉ chịu trách nhiệm cho một domain cụ thể (Auth, Post, User)
Mỗi use case chỉ thực hiện một nhiệm vụ duy nhất (Login, Register, GetPosts, etc.)
Các data source được tách biệt theo chức năng (AuthRemoteDataSource, PostRemoteDataSource, etc.)
Open/Closed Principle (OCP):
Các repository được định nghĩa bằng abstract class, cho phép mở rộng mà không cần sửa đổi code hiện có
Có thể thêm các implementation mới của repository mà không ảnh hưởng đến code đang chạy
UseCase được thiết kế theo abstract class UseCase<Type, Params>, cho phép thêm các use case mới
Liskov Substitution Principle (LSP):
Các implementation của repository (AuthRepositoryImpl, PostRepositoryImpl) có thể thay thế interface của chúng mà không làm thay đổi behavior
Các use case implement từ base UseCase class và tuân thủ contract của nó
Interface Segregation Principle (ISP):
Các repository interface được chia nhỏ theo domain (AuthRepository, PostRepository, UserRepository)
Mỗi interface chỉ chứa các method cần thiết cho domain đó
Không có interface nào bị force implement các method không cần thiết
Dependency Inversion Principle (DIP):
Các use case phụ thuộc vào repository interface (abstraction) thay vì implementation
Dependency injection được sử dụng thông qua constructor
Các dependency được inject thông qua get_it (dependency injection container)
