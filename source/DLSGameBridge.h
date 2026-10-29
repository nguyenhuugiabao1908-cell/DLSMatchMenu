#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Return YES only after the real anti module has initialized AND verified its active state.
/// Never return YES just because an address was found or a byte was written.
FOUNDATION_EXPORT BOOL DLSGameBridgeStartAnti(NSError * _Nullable * _Nullable error);
/// Return YES only if gameplay actually accepts the end-match action.
FOUNDATION_EXPORT BOOL DLSGameBridgeEndMatch(NSError * _Nullable * _Nullable error);
/// Return YES only if gameplay actually accepts +1 goal for the locally controlled team.
FOUNDATION_EXPORT BOOL DLSGameBridgeAddHomeTeamGoal(NSError * _Nullable * _Nullable error);

NS_ASSUME_NONNULL_END
