# BabyMate 🍼

Ứng dụng hỗ trợ **chăm sóc trẻ sơ sinh trong những tháng đầu đời**. Đối tượng
sử dụng chính là bố/mẹ — những người trực tiếp chăm bé. Ứng dụng hoạt động
**offline-first**: mọi dữ liệu được lưu cục bộ trên thiết bị.

## 🧱 Công nghệ

| Hạng mục | Lựa chọn |
|---|---|
| Framework | Flutter (Dart 3, Material 3) |
| Kiến trúc | Clean Architecture (data / domain / presentation) |
| Quản lý state | `flutter_bloc` (Bloc & Cubit) |
| Điều hướng | `go_router` |
| DI | `get_it` (đăng ký thủ công) |
| Lưu trữ cục bộ | `hive` (offline-first) |
| Model | `freezed` + `json_serializable` |
| Đa ngôn ngữ | `flutter_localizations` + ARB (vi mặc định, en) |
| Test | `flutter_test`, `bloc_test`, `mocktail` |

## 📁 Cấu trúc thư mục

```
lib/
├── main.dart              # Điểm vào (flavor dev)
├── app.dart              # Widget gốc (MaterialApp.router)
├── bootstrap.dart        # Khởi tạo Hive, DI, BlocObserver
├── core/                 # Hạ tầng dùng chung, không thuộc feature nào
│   ├── bloc/             # BlocObserver
│   ├── config/           # AppConfig, Flavor
│   ├── constants/        # Hằng số, key lưu trữ
│   ├── di/               # Service locator (get_it)
│   ├── error/            # Failure, Exception, Result
│   ├── router/           # go_router + tên route
│   ├── storage/          # LocalStorage (Hive)
│   ├── theme/            # Màu, typography, spacing, theme
│   ├── usecase/          # Base UseCase
│   ├── utils/            # Logger, extension
│   └── widgets/          # Widget dùng chung
├── features/             # Tính năng theo Clean Architecture (xem features/README.md)
└── l10n/                 # File .arb + code sinh tự động
```

Chi tiết kiến trúc: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) ·
Quy ước code & git: [docs/CONVENTIONS.md](docs/CONVENTIONS.md)

## 🚀 Bắt đầu

Yêu cầu: Flutter 3.24+, Dart 3.5+.

```bash
flutter pub get          # cài dependencies
dart run build_runner build --delete-conflicting-outputs  # sinh code (freezed/json/hive)
flutter gen-l10n         # sinh code đa ngôn ngữ (tự chạy khi pub get)
flutter run              # chạy app (môi trường dev)
```

## 🛠️ Lệnh thường dùng

```bash
flutter analyze                         # phân tích tĩnh
dart format .                           # định dạng code
flutter test                            # chạy test
dart run build_runner watch             # tự sinh code khi sửa model
```

## 🌐 Đa ngôn ngữ

Thêm chuỗi mới vào `lib/l10n/app_vi.arb` (và `app_en.arb`), sau đó chạy
`flutter gen-l10n`. Dùng trong UI: `AppLocalizations.of(context).<key>`.

## 🌱 Flavor

Mặc định chạy môi trường `dev` (`lib/main.dart`). Khi cần tách môi trường,
tạo `lib/main_prod.dart` gọi `bootstrap(..., config: AppConfig.prod)` và chạy
với `flutter run --target lib/main_prod.dart`.
