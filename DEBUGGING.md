# Debugging Screensaver Crashes

## Quick Debug Steps

### 1. Check Console Logs

The easiest way to see what's crashing:

1. **Open Console.app** (Applications > Utilities > Console)
2. In the search box, type: `AsciiquariumScreensaver` or `ScreenSaverEngine`
3. Try to open the screensaver settings again
4. Look for error messages, stack traces, or crash reports

### 2. Check System Logs via Terminal

```bash
# View recent screensaver-related logs
log show --predicate 'process == "ScreenSaverEngine"' --last 5m

# Or filter for your screensaver specifically
log show --predicate 'eventMessage contains "Asciiquarium"' --last 5m
```

### 3. Test in Xcode

1. Open the project in Xcode
2. Select the **AsciiquariumScreensaver** scheme
3. Set a breakpoint in `AsciiquariumScreensaverView.init`
4. Run the scheme (Cmd+R)
5. This will launch the screensaver in preview mode with debugging

### 4. Check Common Issues

#### Issue: Force Unwraps
- **Fixed**: Removed force unwraps in `ScreenSaverDefaults.fishCount()` and `ConfigureSheetController`

#### Issue: Zero-sized bounds
- **Fixed**: Added guard in `updateDimensions()` to prevent crashes when bounds are zero

#### Issue: Configuration sheet initialization
- **Fixed**: Made configuration sheet creation safer

### 5. Test Configuration Sheet Separately

If the crash happens when opening the configuration sheet:

1. Comment out the `configureSheet` property temporarily
2. Set `hasConfigureSheet` to `false`
3. See if the screensaver loads without the config panel
4. If it works, the issue is in `ConfigureSheetController`

### 6. Check Bundle Structure

Make sure the `.saver` bundle is properly structured:

```bash
# Check the installed screensaver
ls -la ~/Library/Screen\ Savers/AsciiquariumScreensaver.saver/Contents/

# Should see:
# - Info.plist
# - MacOS/ (with the binary)
# - Resources/ (if any)
```

### 7. Rebuild and Reinstall

Sometimes a clean rebuild fixes issues:

```bash
# Clean build
xcodebuild -project Asciiquarium.xcodeproj \
           -scheme AsciiquariumScreensaver \
           -configuration Release \
           clean

# Rebuild
xcodebuild -project Asciiquarium.xcodeproj \
           -scheme AsciiquariumScreensaver \
           -configuration Release \
           build \
           ARCHS="arm64 x86_64" \
           ONLY_ACTIVE_ARCH=NO \
           SYMROOT=$(PWD)/build

# Remove old version
rm -rf ~/Library/Screen\ Savers/AsciiquariumScreensaver.saver

# Install new version
cp -R ./build/Release/AsciiquariumScreensaver.saver ~/Library/Screen\ Savers/
```

### 8. Check for Missing Dependencies

The screensaver depends on `AsciiquariumCore`. Make sure it's linked correctly:

1. In Xcode, check the **Build Phases** for AsciiquariumScreensaver target
2. Verify `AsciiquariumCore` is in **Link Binary With Libraries**
3. Check that the framework search paths are correct

### 9. Enable Exception Breakpoints

In Xcode:
1. Go to **Debug > Breakpoints > Create Exception Breakpoint**
2. Run the screensaver
3. This will break on any exceptions

### 10. Check Info.plist

Verify the screensaver's Info.plist has the correct:
- Bundle identifier
- Principal class name (should match your `@objc` class name)
- Minimum macOS version

## Common Error Messages

### "Extension process failed"
- Usually means a crash during initialization
- Check Console.app for the actual error
- Often caused by force unwraps, nil optionals, or missing resources

### "Could not load screensaver"
- Bundle structure issue
- Missing binary or Info.plist
- Wrong principal class name

### "Screensaver won't start"
- Check if `init?(frame:isPreview:)` returns nil
- Verify bounds are valid before calling `updateDimensions()`

## Getting More Detailed Logs

Add NSLog statements to track execution:

```swift
override init?(frame: NSRect, isPreview: Bool) {
    NSLog("AsciiquariumScreensaverView: init started")
    // ... your code ...
    NSLog("AsciiquariumScreensaverView: init completed")
}
```

Then check Console.app for these messages.

