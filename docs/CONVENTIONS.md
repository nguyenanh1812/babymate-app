# Quy ước dự án — BabyMate

## 1. Đặt tên

| Đối tượng | Quy ước | Ví dụ |
|---|---|---|
| File / thư mục | `snake_case` | `feeding_log_repository.dart` |
| Class / enum / typedef | `PascalCase` | `FeedingLogRepository` |
| Biến / hàm / tham số | `camelCase` | `getFeedingLogs()` |
| Hằng số | `lowerCamelCase` | `defaultLocale` |
| Private | tiền tố `_` | `_buildHeader()` |
| Bloc | `XxxBloc` / `XxxCubit`, `XxxEvent`, `XxxState` | `FeedingBloc` |
| UseCase | động từ + danh từ | `AddFeedingLog` |

- File chứa một class chính nên đặt tên theo class đó.
- Entity là danh từ số ít (`Baby`); danh sách dùng số nhiều ở biến (`babies`).

## 2. Code style

- Tuân thủ `flutter_lints` + các rule bổ sung trong `analysis_options.yaml`.
- Bắt buộc `const` ở đâu có thể (đã bật lint `prefer_const_constructors`).
- Ưu tiên `single quotes` cho chuỗi.
- Luôn khai báo kiểu trả về public; tránh `dynamic`.
- Format trước khi commit: `dart format .`
- Không để cảnh báo `flutter analyze` (CI sẽ fail).
- Chuỗi hiển thị cho người dùng phải qua `AppLocalizations`, không hard-code.
- Màu/khoảng cách/typography lấy từ `core/theme`, không dùng số "magic".

## 3. State management (Bloc)

- Một feature có thể có nhiều Bloc/Cubit; mỗi cái một trách nhiệm.
- Dùng **Cubit** cho luồng đơn giản, **Bloc** khi cần mô hình hoá event rõ ràng.
- State nên là `sealed`/`freezed` và bất biến (immutable).
- Bloc chỉ gọi **use case**, không gọi repository/datasource trực tiếp.
- Không đặt logic nghiệp vụ trong widget.

## 4. Git

### Nhánh
```
main          # ổn định, luôn release được
feature/<ten> # tính năng mới
fix/<ten>     # sửa lỗi
chore/<ten>   # việc lặt vặt, cấu hình
```

### Commit — Conventional Commits
```
<type>(<scope>): <mô tả ngắn, tiếng Việt không dấu hoặc tiếng Anh>

type: feat | fix | refactor | chore | docs | test | style | perf
```
Ví dụ: `feat(feeding): them man hinh nhat ky bu`

### Pull Request
- PR nhỏ, tập trung một mục đích.
- Mô tả: làm gì, vì sao, cách kiểm thử.
- `flutter analyze` và `flutter test` phải xanh trước khi merge.

## 5. Test

- Đặt trong `test/`, phản chiếu cấu trúc `lib/`.
- File test kết thúc bằng `_test.dart`.
- Ưu tiên test cho **usecase** và **bloc** (`bloc_test`), mock bằng `mocktail`.
- Tên test mô tả hành vi: `'tra ve CacheFailure khi box loi'`.

## 6. Sinh code (code generation)

Khi sửa model `freezed`/`json`/Hive adapter:
```bash
dart run build_runner build --delete-conflicting-outputs
```
File `*.g.dart` và `*.freezed.dart` **được commit** vào repo.

## 7. Thư mục & ranh giới

- Không import chéo giữa các feature. Nếu cần dùng chung → đưa lên `core/`.
- `core/` không được import bất kỳ thứ gì từ `features/`.
- `domain/` không import Flutter/Hive/json (xem [ARCHITECTURE.md](ARCHITECTURE.md)).
