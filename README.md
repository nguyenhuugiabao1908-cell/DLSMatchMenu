# DLS Match Tools — source and tested HTML preview

## Scope
- Floating round icon with animated water-like gradient, tap to open/close, drag to reposition.
- Dark panel with only two buttons: **Kết thúc trận** and **+1 bàn thắng**.
- On initialization, `DLSGameBridgeStartAnti()` runs. An Anti success popup is shown **only if** it returns verified success.
- Screen outside overlay remains touchable.

## Important: functional limitations
This is **not a verified working DLS gameplay dylib**. By default the game bridge (`source/DLSGameBridge.m`) returns NO for Anti, end-match, and goals; the original SINOTOOL.dylib is not copied or bundled. The anti/cheat functions of the third-party binary are not proven reliable; the menu is not entitled to claim anti-bot success. DLS methods and versions require device-side validation. Calling `TIME_SetClock(90,0)` may update the displayed clock without causing a real match result. No confirmed goal-scoring function is known, and fake score fields would not work reliably. An **optional experimental** clock function lookup is available for the exact supplied DLS UUID (`0EDD1632-CA32-3DAA-834D-134A848F20B2`) using the SINOTOOL-recovered RVA `0x12F9610`. The experimental version calls `TIME_SetClock(90,0)` only, which has not been validated to end the match, may not be thread-safe, and may crash. It is disabled by default.

## HTML preview
The standalone HTML (`preview/index.html`) implements tap-to-toggle, touch drag and mouse drag. The earlier preview accidentally showed a blocking demo popup on startup; v1.1 removes that popup so the menu is immediately usable. The actual iOS Anti popup remains conditional on verified success. **JavaScript must run**. iPhone Quick Look / in-chat HTML viewers may disable scripts, making any HTML demo static. Use a browser that executes the local page. The demo never interacts with the game and never claims Anti is actually activated.

## Build iOS dylib
The folder contains a ready-to-build Xcode command-line project and `.github/workflows/ios-dylib.yml` for GitHub Actions with a macOS runner. Upload the **contents** of the folder to a GitHub repository, open **Actions → Build iOS dylib → Run workflow**, download the build artifact `DLSMatchMenu-arm64-unsigned`. To try the **unverified clock test**, explicitly enable the `experimental_clock` checkbox on the workflow Run screen. The unverified test is not recommended for important game data.

On macOS with Xcode run `bash ./build_ios.sh` (experimental clock: `DLS_ENABLE_EXPERIMENTAL_CLOCK=1 bash ./build_ios.sh`); it produces `build/DLSMatchMenu.dylib` (ARM64 Mach-O, **unsigned**). The script resolves the iPhoneOS SDK and clang through `xcrun`. Link to Foundation, UIKit, QuartzCore. To load a library within an app you own or are permitted to modify, it must be integrated and code-signed with the app's executable. This doesn't install or inject itself.

**Why this package contains no compiled dylib:** The current Linux runtime can compile ARM64 object files, but does not have the iPhoneOS SDK or a working Darwin/iOS linker. Renaming an object, the original SINOTOOL, or an uncompiled source file to `.dylib` would misrepresent the result.

## Original research
See `DLS_SINOTOOL_hook_analysis.md` for static symbol/offset evidence. No claim that memory offsets are universal or bypass server-side protections.
