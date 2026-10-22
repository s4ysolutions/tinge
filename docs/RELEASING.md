# Releasing Tinge

A GitHub Actions workflow (`.github/workflows/release.yml`) builds the app and creates the release.

## How to make a release

1. Make sure `master` has the code you want to ship.
2. Create and push a tag that starts with `v`:

   ```
   git tag v1.2.0
   git push origin v1.2.0
   ```

3. Open the **Actions** tab on GitHub and watch the "Release" run.
4. When it is done, the release appears under **Releases**. It has:
   - `Tinge-1.2.0.dmg` (drag Tinge to Applications)
   - `Tinge-1.2.0.zip`
   - `Tinge-1.2.0-SHA256SUMS.txt`

Rules:

- The tag must look like `v1.2.0`. A tag like `v1.2.0-rc1` is published as a pre-release.
- The tag name sets the app version (`1.2.0`). The workflow run number sets the build number.
- To test the build without a release, run the workflow by hand (**Actions > Release > Run workflow**). It builds the app and keeps the files as a workflow artifact. It does not create a release.

## Signed or unsigned

The workflow checks the secrets below.

- All six secrets exist: the app is signed with your Developer ID certificate and notarized by Apple.
- Any secret is missing: the app is built unsigned (ad-hoc signed). The workflow still works and the release says that the app is not notarized.

## Secrets to add

Add them in GitHub: **Settings > Secrets and variables > Actions > New repository secret**.

| Secret | Value |
| --- | --- |
| `MACOS_CERTIFICATE_P12` | Developer ID Application certificate as a `.p12` file, base64 text |
| `MACOS_CERTIFICATE_PASSWORD` | The password you set when you exported the `.p12` |
| `APPLE_TEAM_ID` | Your 10-character Apple team ID |
| `NOTARY_KEY_P8` | App Store Connect API key (`.p8` file), base64 text |
| `NOTARY_KEY_ID` | Key ID of that API key |
| `NOTARY_ISSUER_ID` | Issuer ID of your App Store Connect account |

### Developer ID certificate (`MACOS_CERTIFICATE_P12`, `MACOS_CERTIFICATE_PASSWORD`)

You need a paid Apple Developer account. The certificate type must be **Developer ID Application**. The "3rd Party Mac Developer Application" certificate (for the App Store) does not work for this.

1. Go to <https://developer.apple.com/account/resources/certificates/list>.
2. Click **+**, choose **Developer ID Application**, and follow the steps. (Only the account holder can create this certificate.) Download the `.cer` file and double-click it to add it to your keychain.
3. Open **Keychain Access > My Certificates**. Find "Developer ID Application: Your Name (TEAMID)".
4. Right-click it, choose **Export**, pick the `.p12` format, and set a password. This password is `MACOS_CERTIFICATE_PASSWORD`.
5. Make the base64 text and copy it to the clipboard:

   ```
   base64 -i DeveloperID.p12 | pbcopy
   ```

   Paste it as the value of `MACOS_CERTIFICATE_P12`.
6. Delete the `.p12` file from your disk when you are done.

### Team ID (`APPLE_TEAM_ID`)

Find it at <https://developer.apple.com/account> under **Membership details**. It is 10 letters and digits. The Xcode project uses `ZR995K5J82`.

### App Store Connect API key (`NOTARY_KEY_P8`, `NOTARY_KEY_ID`, `NOTARY_ISSUER_ID`)

Apple uses this key to notarize the app.

1. Go to <https://appstoreconnect.apple.com/access/integrations/api>.
2. Open **Team Keys** and click **+**. Give it a name (for example "Tinge CI") and the **Developer** role.
3. Click **Download** next to the new key. You can download the `.p8` file only once.
4. Copy the **Key ID** from the key row. This is `NOTARY_KEY_ID`.
5. Copy the **Issuer ID** from the top of the page. This is `NOTARY_ISSUER_ID`.
6. Make the base64 text of the `.p8` file:

   ```
   base64 -i AuthKey_XXXXXXXXXX.p8 | pbcopy
   ```

   Paste it as the value of `NOTARY_KEY_P8`.
7. Keep the `.p8` file in a safe place (for example a password manager) and remove it from your disk.

## What users see in unsigned mode

The app is not notarized, so macOS blocks it the first time. Users can open it in one of two ways:

- Move Tinge to Applications. Right-click Tinge, choose **Open**, then click **Open** in the dialog.
- Or run this in Terminal:

  ```
  xattr -dr com.apple.quarantine /Applications/Tinge.app
  ```

The release text on GitHub includes this note automatically. In signed mode users see no warning, apart from the normal "downloaded from the internet" question.
