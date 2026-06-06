# CLAUDE.md

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

---

# BabyMate — Ngữ cảnh dự án

Ứng dụng Flutter hỗ trợ **chăm sóc trẻ sơ sinh** những tháng đầu đời. Người
dùng chính: bố/mẹ trực tiếp chăm bé. **Offline-first** — dữ liệu lưu cục bộ.

## Stack
- Flutter (Dart 3, Material 3), **Bloc** (`flutter_bloc`) quản lý state.
- **Clean Architecture**: `data / domain / presentation` cho mỗi feature.
- Điều hướng `go_router`, DI `get_it` (đăng ký thủ công), lưu trữ `hive`.
- Model `freezed` + `json_serializable`; đa ngôn ngữ ARB (vi mặc định, en).

## Tài liệu phải đọc trước khi code
- `docs/ARCHITECTURE.md` — ranh giới tầng, hướng phụ thuộc, cách thêm feature.
- `docs/CONVENTIONS.md` — đặt tên, git, test, sinh code.
- `lib/features/README.md` — khuôn thư mục của một feature.

## Ranh giới bắt buộc tôn trọng
- `domain/` KHÔNG import Flutter/Hive/json. Repository ở domain là interface,
  trả về `Result<T>` (xem `core/error/`).
- `data/` ném `Exception`, repository impl chuyển thành `Failure`.
- `presentation/` (Bloc) chỉ gọi **use case**, không gọi repository trực tiếp.
- Không import chéo giữa các feature; dùng chung thì đưa lên `core/`.
- `core/` không import gì từ `features/`.
- Chuỗi hiển thị qua `AppLocalizations`; màu/spacing lấy từ `core/theme`.

## Lệnh
```bash
flutter analyze                                            # phải sạch
dart format .
flutter test
dart run build_runner build --delete-conflicting-outputs  # sau khi sửa model
flutter gen-l10n                                           # sau khi sửa .arb
```

## Lưu ý
- File sinh tự động (`*.g.dart`, `*.freezed.dart`, `lib/l10n/app_localizations*.dart`)
  được commit; đã loại khỏi analyzer.
- Khung hiện CHƯA có feature nào — `home` chỉ là màn hình placeholder.
