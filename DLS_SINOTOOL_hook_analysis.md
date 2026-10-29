# Phân tích tĩnh mục tiêu can thiệp SINOTOOL.dylib trên DLS

## Phương pháp
Giải mã tên symbol C++ bị làm rối trong file dylib; phân tích các lời gọi resolver tại địa chỉ tương đối `0x34CDC8`; đối chiếu Mach-O DLS (arm64, SDK 26.4, min iOS 15.0). Không thực thi game hoặc dylib.

> Chú ý: Đây là 24 vị trí tra cứu địa chỉ trong dylib, KHÔNG có nghĩa là 24 hàm đều bị inline-hook. Nhiều mục là biến dữ liệu; một số hàm được gọi trực tiếp qua function pointer. Offset phụ thuộc đúng bản build DLS, cộng thêm ASLR slide để thành địa chỉ khi chạy.

| Loại | Hàm / biến trong DLS | Offset DLS | Lệnh phân giải trong dylib | Phát hiện |
|---|---|---|---|---|
| C++ data | `CFEBotDetect::ms_tConfig` | `0x2244260` | `0x348010` | Cấu hình phát hiện bot; mã có ghi dữ liệu vào đối tượng được phân giải. |
| C++ data | `CRemoteProfile::s_bBanResetRequest` | `0x2453B50` | `0x3486B4` | Trạng thái yêu cầu reset ban; chưa kiểm chứng kết quả phía máy chủ. |
| Function | `CPlayer::Stop(int)` | `0x13B7EF4` | `0x348B08` | Có lệnh gọi gián tiếp qua con trỏ hàm được phân giải. |
| Function | `CBall::Stop()` | `0x1348FD8` | `0x349000` | Có lệnh gọi gián tiếp qua con trỏ hàm được phân giải. |
| C++ data | `CFEPostMatchCoinAwards::ms_tAwardInfo` | `0x22337B0` | `0x349778` | Thông tin thưởng sau trận. |
| C++ data | `CFEPostMatchCoinAwards::ms_iAwardCount` | `0x2235190` | `0x349E8C` | Số lượng thưởng sau trận. |
| Data symbol | `LOCO_SPEED_SPRINT_MIN` | `0x21E91C8` | `0x34B1B0` | Ngưỡng tốc độ sprint tối thiểu. |
| Data symbol | `LOCO_SPEED_SPRINT_MAX` | `0x21E91CC` | `0x34B54C` | Ngưỡng tốc độ sprint tối đa. |
| Data symbol | `LOCO_SPEED_RUN` | `0x21E95B4` | `0x34B7D8` | Giá trị tốc độ chạy. |
| Data symbol | `LOCO_SPEED_JOG_FAST` | `0x21E95C0` | `0x34BB28` | Giá trị chạy chậm nhanh. |
| Data symbol | `GFXCAMERA_fFOV` | `0x24F283C` | `0x34BEF4` | Trường FOV camera. |
| C++ data | `CFTTCamera::s_fFieldOfView` | `0x2539990` | `0x34C430` | Giá trị góc nhìn camera. |
| C++ data | `CFTTCamera::s_bProjectionMatrixChanged` | `0x25399C0` | `0x34CB40` | Cờ đánh dấu ma trận chiếu đã đổi. |
| Uncertain symbol | `tGame (chuỗi đã khôi phục)` | `0x226C1F0` | `0x34D21C` | Tên rất ngắn, chưa xác định danh tính đối tượng. |
| C++ data | `CGameSetup::ms_iSide` | `0x21E5BE0` | `0x34D708` | Thông số phía đội trong game setup. |
| Uncertain symbol | `tBall (chuỗi đã khôi phục)` | `0x226C0C0` | `0x34D8F4` | Tên rất ngắn, chưa xác định danh tính đối tượng. |
| Function | `TIME_SetClock(int, int)` | `0x12F9610` | `0x366370` | Có đường gọi gián tiếp với đối số quan sát (90, 0). |
| C++ data | `CRemoteProfile::s_tCurrentProfileData` | `0x245B458` | `0x366B5C` | Dữ liệu hồ sơ cục bộ. |
| C++ data | `CRemoteProfile::s_tServerStateShadow` | `0x2453B88` | `0x367224` | Bản phản chiếu trạng thái máy chủ. |
| Function | `CFEPostMatchCoinAwards::AddCoinBonus(int)` | `0xE3B19C` | `0x367A4C` | Có đường gọi với giá trị 50,000. |
| Function | `CFEPostMatchCoinAwards::AddDPBonus(int)` | `0xE3B318` | `0x368104` | Có đường gọi với giá trị 50,000. |
| Function | `CFEPostMatchCoinAwards::AddSPBonus(int)` | `0xE3B494` | `0x3687C0` | Có đường gọi với giá trị 50,000. |
| Function | `CFEPostMatchCoinAwards::AddCPBonus(int)` | `0xE3B610` | `0x368E78` | Có đường gọi với giá trị 50,000. |
| Function | `GL_StaminaReplenishPlayersBy(int, int)` | `0x12FCF0C` | `0x36950C` | Có đường gọi gián tiếp với đối số (100, -1). |

## Kết luận
- DLS chứa các biểu tượng C++ native; Unity Ads xuất hiện trong DLS không chứng minh trò chơi dùng Unity IL2CPP.
- SINOTOOL.dylib có code tải UnityFramework/IL2CPP, nhưng 24 địa chỉ trên khớp logic game C++ native.
- Một số đường gọi quan sát được: TIME_SetClock(90,0), AddCoinBonus(50000), AddDPBonus(50000), AddSPBonus(50000), AddCPBonus(50000), GL_StaminaReplenishPlayersBy(100,-1). Đây là đối số trong binary, chưa chứng minh tác động thực tế hoặc khả năng vượt kiểm tra server.
- Phần bị mã hóa của DLS: Mach-O LC_ENCRYPTION_INFO_64 cryptid=1, cryptoff=23601152, cryptsize=4096.
- Không thay đổi bất kỳ byte nào trong file gốc.
