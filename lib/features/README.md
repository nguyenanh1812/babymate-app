# Features

Mỗi tính năng (feature) là một thư mục độc lập, tổ chức theo **Clean Architecture**
gồm 3 tầng. Quy ước phụ thuộc: `presentation → domain ← data`
(tầng `domain` không phụ thuộc vào `data` hay `presentation`).

```
features/
└── <feature_name>/
    ├── data/
    │   ├── datasources/      # Nguồn dữ liệu cục bộ (Hive box, file...)
    │   ├── models/           # DTO + ánh xạ sang/từ entity (freezed/json)
    │   └── repositories/     # Triển khai repository của domain
    ├── domain/
    │   ├── entities/         # Đối tượng nghiệp vụ thuần (không phụ thuộc framework)
    │   ├── repositories/     # Interface repository (hợp đồng)
    │   └── usecases/         # Một use case = một hành động nghiệp vụ
    └── presentation/
        ├── bloc/             # Bloc/Cubit + event + state
        ├── pages/            # Màn hình (route đích)
        └── widgets/          # Widget riêng của feature
```

## Quy tắc

- **domain** không import `package:flutter`, Hive, hay bất kỳ thư viện hạ tầng nào.
- **data** chuyển `Exception` thành `Failure` và trả về `Result<T>` cho domain.
- **presentation** chỉ giao tiếp với domain qua use case, không gọi thẳng repository.
- Đăng ký dependency của feature trong `core/di/injection.dart`
  (hoặc hàm `registerXxxFeature(getIt)` riêng).
- Route của feature khai báo trong `core/router/` và thêm hằng số vào `AppRoutes`.

## Feature hiện có

- **`baby/`** — Hồ sơ bé: tạo/chọn/xoá bé, quản lý bé đang chọn (active).
- **`activity/`** — Nhật ký hoạt động: ghi **bú / ngủ / thay tã**, lịch sử theo ngày.
- **`growth/`** — Theo dõi tăng trưởng: ghi cân nặng/chiều cao/vòng đầu theo
  thời gian, biểu đồ xu hướng cân nặng (CustomPainter, không thêm dependency).
- **`pumping/`** — Hút sữa: nhật ký cữ hút (giờ, lượng ml, bên trái/phải/cả hai,
  tổng hôm nay) và lịch nhắc hằng ngày qua thông báo cục bộ
  (`flutter_local_notifications`, dịch vụ ở `core/notifications/`).
- **`inventory/`** — Kho bỉm/sữa: tồn kho qua nhật ký giao dịch (nhập/dùng),
  bỉm tự trừ khi ghi "Thay tã", mua thêm/bóc hộp thủ công, báo cáo theo tháng.
- **`home/`** — Trang chủ: tổng quan hôm nay + ghi nhanh (chỉ có `presentation`,
  tái dùng domain/data của `baby` và `activity`).

Dùng cấu trúc trên làm khuôn khi thêm feature mới (ví dụ: tăng trưởng cân nặng,
nhắc lịch tiêm chủng, cữ bú định kỳ...).
