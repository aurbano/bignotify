# Code Signing Setup for GitHub Actions

## Required Secrets

To enable code signing and notarization in GitHub Actions, add these secrets to your repository:

### 1. Certificate Secrets

#### `APPLE_CERTIFICATE_BASE64`
Your Developer ID Application certificate in base64 format.

To export:
1. Open Keychain Access
2. Find your "Developer ID Application" certificate
3. Right-click → Export
4. Save as .p12 with a password
5. Convert to base64:
```bash
base64 -i certificate.p12 | pbcopy
```

#### `APPLE_CERTIFICATE_PASSWORD`
The password you used when exporting the .p12 certificate.

#### `APPLE_DEVELOPER_ID`
The identity of your certificate, usually:
```
Developer ID Application: Your Name (TEAMID)
```

To find it:
```bash
security find-identity -v -p codesigning
```

#### `KEYCHAIN_PASSWORD`
Any password for the temporary keychain (e.g., generate with `uuidgen`).

### 2. Notarization Secrets

#### `APPLE_ID`
Your Apple ID email address.

#### `APPLE_ID_PASSWORD`
An app-specific password for your Apple ID.
Generate at: https://appleid.apple.com/account/manage
(Sign in → Security → App-Specific Passwords)

#### `APPLE_TEAM_ID`
Your Apple Developer Team ID (10 characters).
Find it at: https://developer.apple.com/account → Membership

## Adding Secrets to GitHub

1. Go to your repository on GitHub
2. Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add each secret with the values above

## Testing

Once configured, the GitHub Actions workflow will:
1. Sign the app with your Developer ID
2. Notarize it with Apple
3. Staple the notarization ticket
4. Create a signed, notarized DMG

## Without Code Signing

If you don't have an Apple Developer account:
- The workflow will still run and create an unsigned app
- Users will need to right-click and select "Open" on first launch
- Or disable Gatekeeper: `sudo spctl --master-disable` (not recommended)

## Local Code Signing

To sign locally:
```bash
export APPLE_DEVELOPER_ID="Developer ID Application: Your Name (TEAMID)"
./build_app.sh
```

## Troubleshooting

### "errSecInternalComponent" error
The certificate wasn't properly imported. Check the base64 encoding.

### "Unable to build chain to self-signed root"
You may need to install Apple's intermediate certificates:
https://www.apple.com/certificateauthority/

### Notarization fails
- Ensure the app is properly signed first
- Check that all embedded frameworks/libraries are also signed
- Review the notarization log for specific issues

### Testing Certificate Import Locally
```bash
# Create a test keychain
security create-keychain -p testpass test.keychain
security unlock-keychain -p testpass test.keychain

# Import your certificate
security import certificate.p12 -P "certpass" -k test.keychain

# List certificates
security find-identity -v -p codesigning test.keychain

# Delete test keychain
security delete-keychain test.keychain
```