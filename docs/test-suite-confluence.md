# Bổ sung Unit Test — SplitPay iOS

> Branch: `test/setup-testcase` · Framework: **Swift Testing** · Tổng cộng: **~206 test / 10 package — 100% PASS**

---

## 1. Bối cảnh & phạm vi

Trước khi bắt đầu, 12 package SwiftPM của dự án **không có test thật nào**: 10 package chỉ chứa stub rỗng sinh sẵn bởi template SPM, Profile có 1 test `#expect(true)`, SplitBill chỉ có `import Testing`. Không có mock, không có fixture, không có script chạy test.

**Phạm vi đã chọn:**

| Hạng mục | Quyết định |
|---|---|
| Framework | Swift Testing (`@Test`, `#expect`, `@Suite`) — thay thế toàn bộ stub XCTest |
| Đối tượng test | Pure logic (Domains/Utils/Network/Router) + toàn bộ ViewModel với mock repository |
| Không test | UI component (SwiftUI view, QR render), data layer Supabase (cần URLProtocol), app target `SplitPay` |

Lý do khả thi: kiến trúc sẵn rất testable — mọi ViewModel là `@MainActor @Observable`, inject dependency qua protocol `I*Repository` (public, khai báo trong `Domains`), nên mỗi package test tự viết mock riêng.

## 2. Kết quả tổng thể

| Package | Engine chạy | Số test | Nội dung chính |
|---|---|---|---|
| Foundation/Domains | `swift test` | 41 | `SplitCalculator` (table-driven + invariant sweep 2…25 người), `Amount`, `DomainError` (22 case × message + `LocalizedError`), `SessionStore`, Models, `PostgresNumeric`, `RepositoryErrorMapper` (~23 branch code Postgres), `TransferStatus` |
| Foundation/Utils | `swift test` | 4 | `DateFormatting.relative` với reference date cố định |
| Foundation/Network | `swift test` | 5 | `HTTPMethod`, `APIEndpoint` default init, `encodableBody` round-trip |
| Foundation/Router | `swift test` | 5 | navigate/back/toRoot, presentSheet |
| Core/CommonUi | xcodebuild | 2 | `AppAlert` — instance giống nhau vẫn khác nhau (id = UUID mới mỗi lần) |
| Features/Authentication | xcodebuild | 35 | `LoginValidator`, `RegisterValidator` (table-driven), Login/Register ViewModel (trim input, error mapping, reentrancy guard, `dismissError`) |
| Features/Transfer | xcodebuild | 38 | Debounce lookup exactly-once, balance guard, confirm/OTP flow, group lịch Today/Yesterday với `Calendar` inject |
| Features/SplitBill | xcodebuild | 49 | Split math, generate QR (create/update path), cancel, phân hoạch active/settled, ScanRepay, RepaymentPin |
| Features/Home | xcodebuild | 12 | Load 3 async-let, recent 4 đầu, display fallbacks, mapping `HomeTransaction` |
| Features/Profile | xcodebuild | 16 | `setupPin`/`changePin` (success / return-false / throw), guard `isSettingUpPin`, signOut, display fallbacks |

Toàn bộ chạy qua script trong **~60 giây**, exit 0.

## 3. Kiến trúc test — 2 engine

Việc chọn engine theo import của từng package:

- **`swift test` (macOS host)** cho `Utils`, `Network`, `Router`, `Domains` — chỉ dùng Foundation, build nhanh không cần simulator. Hai package này cần khai báo `.macOS(.v14)` trong `platforms` của `Package.swift` (Supabase cần macOS 13, `@Observable` cần macOS 14).
- **`xcodebuild test` (iOS simulator)** cho `CommonUi` + 5 feature package — vì import `SystemDesign` (UIKit/SwiftUI). Scheme dùng tên package (`xcodebuild test -scheme Transfer`), chạy với working directory là thư mục package.

## 4. Cấu trúc file test

```
Features/<Pkg>/Tests/<Pkg>Tests/
├── Mocks/
│   ├── MockSplitBillRepository.swift   # final class, @unchecked Sendable
│   └── ...
├── Fixtures.swift                      # makeXxx(...) builder, default arguments
├── SplitFlowViewModelTests.swift       # 1 file / 1 subject
└── ...
```

**Mock pattern:**

```swift
final class MockSplitBillRepository: ISplitBillRepository, @unchecked Sendable {
    var createdBill: SplitBill?            // kết quả trả về
    var error: Error?                      // lỗi mô phỏng
    private(set) var createSplitBillCalls = 0          // đếm lần gọi
    private(set) var lastCreateCommand: CreateSplitBillCommand?  // bắt tham số

    func createSplitBill(_ command: CreateSplitBillCommand) async throws -> SplitBill {
        createSplitBillCalls += 1
        lastCreateCommand = command
        if let error { throw error }
        guard let createdBill else { throw DomainError.notFound }
        return createdBill
    }
}
```

Mock `IAuthRepository` phải đánh dấu `@MainActor` (protocol gốc là `@MainActor`).

**Reentrancy test qua continuation gate** — mock có thể "giữ" lời gọi giữa chừng để test chặn gọi kép:

```swift
// Trong mock:
var holdCreateSplit = false
func resumeCreateSplit() { ... }

// Trong test:
async let first = viewModel.generateQR()
try await Task.sleep(for: .milliseconds(100))   // call 1 vào trạng thái creating
let second = await viewModel.generateQR()       // call 2 → false, không gọi repo
splitBillRepository.resumeCreateSplit()
#expect(await first == true)
#expect(splitBillRepository.createSplitBillCalls == 1)
```

## 5. Convention viết test

- **Tên test là câu**, không prefix `test`: `theFormIsInvalidWhenTheAmountExceedsTheBalance`.
- **Table-driven** với `@Test(arguments:)` cho dữ liệu nhiều case (validator, split math, error mapping).
- **Suite ViewModel** đánh dấu `@Suite @MainActor struct`.
- **Assertion locale-safe**: chuỗi format tiền/ngày chỉ assert cấu trúc (dấu `+`/`-`, hậu tố `"VND"`, `contains`) hoặc so với NumberFormatter cấu hình giống hệt — không pin dấu `,`/`.` theo locale.
- **Grouping lịch inject `Calendar`** qua init (đã refactor `TransactionHistoryViewModel`) — hết flake midnight/UTC.
- **Debounce test được nhờ** `TransferFlowViewModel.accountLookupDebounce` là hằng số public — test sleep đúng theo hằng số thay vì hardcode 400ms.
- Ghi chú **"Not tested: …"** ngay trong file cho phần cố tình bỏ qua (vd. rotation của `idempotencyKey` — private, không có seam quan sát).

## 6. Cách chạy test

```bash
# Toàn bộ suite (~60s) — bảng PASS/FAIL, exit non-zero nếu fail
./scripts/run_tests.sh

# Lọc package theo tên
./scripts/run_tests.sh Transfer

# Chỉ định simulator
SIM_DESTINATION="platform=iOS Simulator,name=iPhone 17 Pro" ./scripts/run_tests.sh

# Chạy tay 1 package Foundation (nhanh, không cần simulator)
cd Foundation/Domains && swift test
swift test --filter SplitCalculatorTests

# Chạy tay 1 package feature (cần simulator)
cd Features/Transfer
xcodebuild test -scheme Transfer -destination "platform=iOS Simulator,name=iPhone 17 Pro"
```

Lưu ý: **không dùng `-quiet` với xcodebuild** — nó ẩn luôn kết quả Swift Testing; lọc output bằng `grep -E "Test run|✘|error:|TEST"`.

Script tự chọn simulator đang boot, fallback sang iPhone available đầu tiên; một package fail không chặn các package còn lại; log đầy đủ lưu ở temp dir, package fail in 60 dòng cuối ra stderr.

## 7. Thay đổi trong production code

Tất cả thay đổi **giữ nguyên hành vi** (behavior-preserving):

| File | Thay đổi | Lý do |
|---|---|---|
| 6 file `Package.swift` (feature + Domains) | Thêm dep `Domains`/`Utils` vào testTarget; tạo target mới `DomainDatasTests` | SPM 6.2 yêu cầu khai báo import tường minh — thiếu sẽ `no such module` |
| `Foundation/{Network,Router,Utils}/Package.swift` | Thêm `.macOS(.v14)` vào `platforms` | Chạy `swift test` trên macOS host |
| `Foundation/Loggers`, `Foundation/SystemDesign` | Xoá testTarget (rỗng / 100% UI) | Target trùng build error / vô ích |
| `TransferFlowViewModel.swift` | Trích `public static let accountLookupDebounce: Duration = .milliseconds(400)` | Test sleep theo hằng số, không hardcode |
| `TransactionHistoryViewModel.swift` | Inject `calendar: Calendar = .current` qua init (default param → không đổi call-site) | Loại flake ngày/múi giờ |
| `DomainError.swift` | Khôi phục `import Foundation` | File bị mất import, `LocalizedError` không build |

## 8. Đảm bảo chất lượng

- **Mutation check**: tạm đổi `.rounded()` → `.rounded(.down)` trong `SplitCalculator` — bộ test phải đỏ. Kết quả ban đầu mutation **sống sót** (các case cũ 100/3, 40/3 đều là thập phân lặp, floor = round), nên đã bổ sung case `100/6 → 16.67` để phân biệt; sau đó mutation bắt đúng, đã revert và suite xanh lại.
- **swiftformat + swiftlint --strict**: toàn bộ file test mới pass (1 violation `type_body_length` đã xử lý bằng cách tách suite OTP riêng).

## 9. Phạm vi cố tình không test

| Phần | Lý do |
|---|---|
| `qrImage` (render UIImage từ payload) | Cần so sánh ảnh — thuộc UI test |
| Rotation của `idempotencyKey` | Property private, không có seam quan sát không đổi hành vi |
| Data layer Supabase qua mạng | Cần URLProtocol mock — ngoài phạm vi đã chốt |
| SwiftUI views, `SplitPay` app target | UI / thin shell |
| `navigateBack` trên path rỗng | `NavigationPath.removeLast` trap — không thể test không crash (có comment trong `RouterTests`) |

## 10. Thêm test mới cho một package

1. Tạo file `Features/<Pkg>/Tests/<Pkg>Tests/<Subject>Tests.swift`, khai báo `@Suite @MainActor struct` (nếu test ViewModel).
2. Nếu cần mock mới: viết trong `Mocks/` theo pattern ở mục 4 — thêm counter `private(set) var`, tham số bắt được `last...`, và continuation gate nếu cần test reentrancy.
3. Fixture mới bổ sung vào `Fixtures.swift` với default arguments.
4. Chạy: `cd Features/<Pkg> && xcodebuild test -scheme <Pkg> -destination "platform=iOS Simulator,name=iPhone 17 Pro"`.
5. Trước khi merge: chạy `./scripts/run_tests.sh` (phải 10/10 PASS) và `swiftformat` + `swiftlint --strict` trên file mới.
