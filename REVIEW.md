# Tinge code review

This review lists problems in the current code and what to change. It does not change code.
Items are sorted by priority. Priority 1 is security or a feature that does not work. Priority 2 is an old API that will stop working. Priority 3 is cleanup.

Paths are relative to the repo root. Line numbers match the code after the HiDPI fix.

---

## Priority 1

### 1. Dropbox OAuth uses v1 endpoints and a client secret in the app

- **File:** `tinge/DropboxUploadStorage.m:112`, `:118`, `:132`
- **Why:** The authorize URL and token URL use Dropbox API v1 (`/1/oauth2/...`). The app sends the client ID and client secret as a Basic auth header (`:132`). Anything in an app binary can be read, so the secret is not secret. A desktop app should not hold a client secret.
- **Suggested change:** Move to the Dropbox OAuth 2 flow with PKCE (no client secret) and the v2 endpoints. Remove the secret from the source and rotate it in the Dropbox app console.

### 2. Access token is stored in NSUserDefaults

- **File:** `tinge/OAuthStorage.m:12-15`, `:17-23`
- **Why:** NSUserDefaults writes to a plist file in `~/Library/Preferences`. Any process that runs as the user can read it. A token should be stored in the Keychain.
- **Suggested change:** Store the token with `SecItemAdd` and read it with `SecItemCopyMatching`. Read the old NSUserDefaults value once for migration, then delete it.

### 3. Temporary upload file name comes from the window title and is not always removed

- **File:** `tinge/EditorWindowController.m:483` (path built from `[self.window title]`); removals at `tinge/UploadWindowController.m:240` (success only) and `:295`
- **Why:** The path now starts from `NSTemporaryDirectory()`, which is good. But the file name is the window title, which the user can change. A name with spaces or `#` can make `URLWithString:` return nil. The file is removed only on some paths, so screenshots can stay on disk.
- **Suggested change:** Use a unique name (for example a UUID) and `fileURLWithPath:`. Delete the file on every end path, including errors.

### 4. Screen capture API is deprecated, and missing permission fails silently

- **File:** `tinge/AppDelegate.m:179` (`CGDisplayCreateImage`), `:186` (nil case is only a `TODO`); `tinge/ScreenshotWindow.m:35` (`CGDisplayCapture`), `:74` (`CGDisplayRelease`); `tinge/AppDelegate.m:169-172` (`currentDisplay` always returns 0)
- **Why:** `CGDisplayCreateImage` is deprecated in macOS 15. Since macOS 10.15 it needs Screen Recording permission (TCC). Without it, the image has no windows, and the app shows no message. The app is sandboxed, so the same permission applies there. `CGDisplayCapture` locks the whole display. A normal overlay window does not need this. `currentDisplay` always returns index 0 of the CG display list. That index is not guaranteed to be the screen the user sees as main, so the user cannot pick a display.
- **Suggested change:** Use ScreenCaptureKit (`SCScreenshotManager`, macOS 14+) for capture. Call `CGPreflightScreenCaptureAccess()` and, if needed, `CGRequestScreenCaptureAccess()`. Show a clear message with a link to System Settings > Privacy & Security > Screen Recording when access is missing. Remove `CGDisplayCapture` if the overlay does not need it. Pick the display from the user's choice, not from index 0.

### 5. ~~Release build grants broad file access, and the entitlements path has the wrong folder case~~ — FIXED

- **Status:** Done. Debug and Release now use one file, `tinge/tinge.entitlements`, with only `app-sandbox`, `files.user-selected.read-write` (Save dialog) and `network.client` (Dropbox). Removed: `files.all`, `assets.pictures.read-write`, `files.downloads.read-write` (no code uses them; files saved through the Save dialog still work). `TingeRelease.entitlements` is deleted.

---

## Priority 2

### 6. NSURLConnection is deprecated

- **File:** `tinge/OAuth2WindowController.m:22`, `:130-131` (includes a modal run loop mode), `:137-185`; `tinge/UploadWindowController.m:66`, `:170` (`NSInputStream` read on the main thread), `:177`, `:191`, `:209-210` (run loop timer)
- **Why:** `NSURLConnection` was deprecated in macOS 10.11. The upload also reads the file through an `NSInputStream` on the main thread.
- **Suggested change:** Use `NSURLSession`. For uploads, use an upload task (or a background session) so the work runs off the main thread. Remove the run loop mode workaround.

### 7. Token JSON is parsed with string search

- **File:** `tinge/DropboxUploadStorage.m:199-216`
- **Why:** The code looks for the text `"access_token": "` and reads up to the next quote. This breaks if the spacing or key order changes. Error results are returned as text with a leading space, which is easy to miss.
- **Suggested change:** Parse the response with `NSJSONSerialization`. Check the HTTP status code first. Return a real `NSError`.

### 8. Manual memory management (MRC) in both app build configurations

- **File:** `Tinge.xcodeproj/project.pbxproj:677` (Debug) and `:699` (Release) set `CLANG_ENABLE_OBJC_ARC = NO`, which overrides the project-level `YES`; `tinge/EditorWindowController.m:349` (bitmap data passed to `CGDataProviderCreateWithData` with a NULL release callback, and the bitmap rep is autoreleased); `tinge/ScreenshotView.m:27`, `:38` (manual `CFRetain` / `CFRelease`)
- **Why:** Manual retain and release is easy to get wrong. The bitmap at `EditorWindowController.m:349` is owned by an autoreleased object, so the CGImage can point to memory that is already freed.
- **Suggested change:** Move the app target to ARC. Keep the bitmap alive for the life of the CGImage (or copy the bytes into a `CFData` with a release callback).

### 9. Deprecated process and login item APIs

- **File:** `tinge/PresentationManager.m:29`, `:42`; `tinge/ImageDocument.m:270` (`TransformProcessType`); `tinge/AppDelegate.m:239-281` (`LSSharedFileList`)
- **Why:** `TransformProcessType` is an old way to change the app mode. `AppDelegate.m:91` and `ImageDocument.m:271` already use `setActivationPolicy:`, so the older calls are not needed. `LSSharedFileList` is deprecated for login items.
- **Suggested change:** Remove the `TransformProcessType` calls and use `[NSApp setActivationPolicy:]` only. Use `SMAppService.mainApp` (macOS 13+) for login items.

---

## Priority 3

### 10. Deployment target is 12.0

- **File:** `Tinge.xcodeproj/project.pbxproj` (`MACOSX_DEPLOYMENT_TARGET`)
- **Why:** The installed Xcode 27 needs 12.0 or later. Six values that were 10.9 or 10.14 were raised to 12.0 for the HiDPI fix build. The HiDPI code needs macOS 10.7 or later.
- **Suggested change:** Pick the minimum macOS version you want to support, test on it, and keep the value in one place.

### 11. MASShortcut is a vendored copy in the repo

- **File:** `MASShortcut/` (folder at the repo root), `MASShortcut/MASHotKey.m:21` (`RegisterEventHotKey`, a Carbon API), `MASShortcut/MASKeyCodes.h`
- **Why:** The copy is old and not tracked by version. Updates must be copied by hand. It uses the Carbon hot key API.
- **Suggested change:** Add MASShortcut as a Swift Package or a pinned git submodule. Check the upstream project for a newer version that supports ARC and current macOS.

### 12. Carbon header only for one key code

- **File:** `tinge/ScreenshotWindow.m:9` (`#import <Carbon/Carbon.h>`), `:68` (`kVK_Escape`)
- **Why:** Carbon is a large legacy header. Only one constant is used.
- **Suggested change:** Use `HIToolbox/Events.h`, or compare with key code `53` and a named constant.

### 13. No NSHighResolutionCapable key in Info.plist

- **File:** `tinge/Info.plist`
- **Why:** The key is not set. The HiDPI fix works with point sizes, but the app still needs a check on a Retina screen. Without the key, the app can look blurry or wrong in size.
- **Suggested change:** Add `NSHighResolutionCapable` set to `YES` and test on a Retina screen.

### 14. ImageDocument looks unused and has the old pixel-size bug

- **File:** `tinge/ImageDocument.m:254-263`, `:281`; `tinge/ImageDocument.h`, `tinge/ImageDocument.xib`
- **Why:** `Base.lproj/MainMenu.xib` does not reference `ImageDocument`. The class still uses pixel sizes for the view frame, like the code fixed for the editor.
- **Suggested change:** Confirm it is unused, then remove it. If it is used, apply the same point-size fix.

### 15. Error text contains the full server response

- **File:** `tinge/DropboxUploadStorage.m:203-216`
- **Why:** The error text includes the full response from the server, and it can be shown in the UI. Responses can contain account data.
- **Suggested change:** Show a short message. Log the full response only in debug builds.

### 16. Editor point size uses the main display only

- **File:** `tinge/EditorWindowController.m:325` (`TingePixelsPerPoint(CGMainDisplayID())`)
- **Why:** The crop uses the scale of the display that was captured (`tinge/ScreenshotView.m`). The editor window size uses the main display. Both match today, because only display 0 is captured. If a capture from another display is ever used, the editor window size will be wrong. The editor also opens images from files (`tinge/UploadWindowController.m:296`), which have no display.
- **Suggested change:** Pass the scale into `startEdit:` from the caller, and store it in the editor.

### 17. ToolArrow keeps a static path that is never released

- **File:** `tinge/ToolArrow.m:23-33` (static `endPath`), `:78-79` (`float` used for `sinf` / `cosf`)
- **Why:** The static path is created once and never released. This is a small, one-time leak. The `float` values lose precision.
- **Suggested change:** Keep the path for the app life, but document it. Use `double` with `sin` / `cos`.
