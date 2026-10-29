#import "DLSGameBridge.h"

// This bridge intentionally never reports a DLS action as fully successful
// unless it has actually performed an action with at least a minimal check.
// Some behaviors need observation in an authorized test environment.

static NSError *BridgeUnavailable(NSString *action, NSString *reason) {
    return [NSError errorWithDomain:@"DLSMatchMenu.GameBridge"
                               code:1001
                           userInfo:@{NSLocalizedDescriptionKey:
                                 [NSString stringWithFormat:@"%@: %@", action, reason]}];
}

BOOL DLSGameBridgeStartAnti(NSError **error) {
    // No verified implementation can be safely reconstructed from static symbols
    // of the SINOTOOL binary alone. Reporting success here would be misleading.
    if (error) *error = BridgeUnavailable(@"Anti", @"Chưa có module đã xác minh.");
    return NO;
}

#if defined(DLS_ENABLE_EXPERIMENTAL_CLOCK) && DLS_ENABLE_EXPERIMENTAL_CLOCK
#import <mach-o/dyld.h>
#import <mach-o/loader.h>
#import <stdint.h>
#import <string.h>

// DLS executable supplied by the user: LC_UUID 0EDD1632-CA32-3DAA-834D-134A848F20B2.
// Clock method RVA from SINOTOOL's static resolver: 0x12F9610.
// These values MUST NOT be reused for a different DLS build.
static const uint8_t kTestBuildUUID[16] = {
    0x0e, 0xdd, 0x16, 0x32, 0xca, 0x32, 0x3d, 0xaa,
    0x83, 0x4d, 0x13, 0x4a, 0x84, 0x8f, 0x20, 0xb2
};

static const struct mach_header_64 *DLSMatchingExecutable(void) {
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; ++i) {
        const struct mach_header *raw = _dyld_get_image_header(i);
        if (!raw || raw->magic != MH_MAGIC_64 || raw->filetype != MH_EXECUTE) continue;
        const struct mach_header_64 *hdr = (const struct mach_header_64 *)raw;
        const uint8_t *p = (const uint8_t *)(hdr + 1);
        for (uint32_t k = 0; k < hdr->ncmds; ++k) {
            const struct load_command *cmd = (const struct load_command *)p;
            if (cmd->cmdsize < sizeof(*cmd)) break;
            if (cmd->cmd == LC_UUID && cmd->cmdsize >= sizeof(struct uuid_command)) {
                const struct uuid_command *uuid = (const struct uuid_command *)cmd;
                if (memcmp(uuid->uuid, kTestBuildUUID, sizeof(kTestBuildUUID)) == 0) return hdr;
            }
            p += cmd->cmdsize;
        }
    }
    return NULL;
}
#endif

BOOL DLSGameBridgeEndMatch(NSError **error) {
#if defined(DLS_ENABLE_EXPERIMENTAL_CLOCK) && DLS_ENABLE_EXPERIMENTAL_CLOCK
    const struct mach_header_64 *hdr = DLSMatchingExecutable();
    if (!hdr) {
        if (error) *error = BridgeUnavailable(@"Kết thúc trận", @"Sai phiên bản DLS (UUID không khớp).");
        return NO;
    }
    typedef void (*ClockFn)(int, int);
    ClockFn clockSet = (ClockFn)((uintptr_t)hdr + (uintptr_t)0x12F9610);
    clockSet(90, 0);
    // YES here denotes "called TIME_SetClock" only, NOT that the match ended.
    return YES;
#else
    if (error) *error = BridgeUnavailable(@"Kết thúc trận", @"Chưa bật thử nghiệm TIME_SetClock.");
    return NO;
#endif
}

BOOL DLSGameBridgeAddHomeTeamGoal(NSError **error) {
    // A reliable +1 goal action must be linked to the game-owned score event,
    // not by editing UI strings or the HomeScore/AwayScore presentation fields.
    if (error) *error = BridgeUnavailable(@"+1 bàn", @"Chưa xác định được hàm ghi bàn thực.");
    return NO;
}
