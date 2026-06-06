# Kiến trúc — BabyMate

BabyMate dùng **Clean Architecture** kết hợp **Bloc**. Mục tiêu: tách biệt
nghiệp vụ khỏi framework/hạ tầng, dễ test và dễ mở rộng theo từng feature.

## Sơ đồ phụ thuộc

```
        ┌─────────────────┐
        │  presentation   │  Widget, Page, Bloc/Cubit
        │  (Flutter UI)   │
        └────────┬────────┘
                 │ gọi use case
                 ▼
        ┌─────────────────┐
        │     domain      │  Entity, Repository (interface), UseCase
        │  (Dart thuần)   │  ← KHÔNG phụ thuộc Flutter / Hive
        └────────▲────────┘
                 │ triển khai interface
        ┌────────┴────────┐
        │      data       │  Model (DTO), DataSource, Repository impl
        │  (Hive, file)   │
        └─────────────────┘
```

Quy tắc vàng: **`domain` ở trung tâm và không phụ thuộc ai.** `data` và
`presentation` đều hướng về `domain`.

## Trách nhiệm từng tầng

### domain
- `entities/`: đối tượng nghiệp vụ thuần (vd: `Baby`, `FeedingLog`). Không
  import Flutter/Hive/json.
- `repositories/`: **interface** mô tả khả năng cần có, trả về `Result<T>`.
- `usecases/`: mỗi class là một hành động (`AddFeedingLog`, `GetBabies`...),
  implement `UseCase<Type, Params>`.

### data
- `models/`: DTO ánh xạ giữa entity và lớp lưu trữ; dùng `freezed`/`json` hoặc
  Hive adapter. Có hàm `toEntity()` / `fromEntity()`.
- `datasources/`: thao tác trực tiếp với Hive box / file; **ném `Exception`**.
- `repositories/`: implement interface của domain, bắt `Exception` từ
  data source và chuyển thành `Failure`, trả `Result<T>`.

### presentation
- `bloc/`: `Bloc`/`Cubit` giữ state UI, gọi use case, phát `State`.
- `pages/`: màn hình gắn với route.
- `widgets/`: widget tái sử dụng trong feature.

## Xử lý lỗi

- Tầng data ném `CacheException` / `DatabaseException`.
- Repository bắt lại → trả `Result.err(CacheFailure(...))`.
- Use case/Bloc dùng `result.fold(onOk, onErr)` để cập nhật state.
- UI không bao giờ `try/catch` nghiệp vụ; chỉ đọc state.

## Dependency Injection

`get_it` (đăng ký thủ công trong `core/di/injection.dart`). Thứ tự:
`dataSource → repository → usecase → bloc`. Bloc thường đăng ký
`registerFactory` (tạo mới mỗi lần), repository/usecase `registerLazySingleton`.

## Vòng đời khởi tạo

`main.dart` → `bootstrap()` (init Hive, BlocObserver, DI) → `BabyMateApp`
(`MaterialApp.router`) → `go_router` → page đầu tiên.

## Thêm một feature mới (checklist)

1. Tạo thư mục `features/<ten>/` theo khuôn trong `features/README.md`.
2. Viết `entities` + `repository interface` + `usecases` (domain).
3. Viết `models` + `datasource` + `repository impl` (data); chạy build_runner.
4. Viết `bloc` + `pages` + `widgets` (presentation).
5. Đăng ký DI trong `core/di/injection.dart`.
6. Thêm route vào `core/router/` và hằng số vào `AppRoutes`.
7. Thêm chuỗi đa ngôn ngữ vào `lib/l10n/*.arb`.
8. Viết test cho usecase và bloc.
