# Environment Variables Setup Guide

This guide explains how to set up environment variables for the Gig iOS app, specifically for the OpenAI API key.

## 🔐 **Security Best Practices**

- **Never commit API keys to version control**
- **Use environment variables for production**
- **Use Info.plist only for development**
- **Rotate API keys regularly**

## 🛠 **Setup Methods**

### Method 1: Environment Variables (Recommended for Production)

#### For Development:
```bash
# Set environment variable in your shell
export OPENAI_API_KEY="sk-your-actual-api-key-here"

# Or add to your shell profile (~/.zshrc, ~/.bash_profile)
echo 'export OPENAI_API_KEY="sk-your-actual-api-key-here"' >> ~/.zshrc
source ~/.zshrc
```

#### For Xcode Build:
1. Open Xcode
2. Select your project
3. Go to "Edit Scheme"
4. Select "Run" → "Arguments"
5. Add to "Environment Variables":
   - Name: `OPENAI_API_KEY`
   - Value: `sk-your-actual-api-key-here`

#### For CI/CD (GitHub Actions, etc.):
```yaml
env:
  OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
```

### Method 2: Info.plist (Development Only)

The API key can be stored in `Info.plist` for development convenience:

```xml
<key>OPENAI_API_KEY</key>
<string>YOUR_OPENAI_API_KEY_HERE</string>
```

**⚠️ IMPORTANT:** 
- Replace `YOUR_OPENAI_API_KEY_HERE` with your actual API key
- Remove this before production deployment!
- Never commit the actual key to version control

### Method 3: Configuration File (Alternative)

Create a `Config.local.swift` file (add to .gitignore):

```swift
// Config.local.swift
extension Config {
    static let openAIKey: String = "sk-your-actual-api-key-here"
}
```

## 🔍 **How It Works**

The `Config.swift` file implements a fallback system:

1. **First Priority:** Environment variable `OPENAI_API_KEY`
2. **Second Priority:** Info.plist key `OPENAI_API_KEY`
3. **Third Priority:** Hardcoded fallback (DEBUG builds only)

```swift
static let openAIKey: String = {
    // First try to get from environment variable
    if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
        return envKey
    }
    
    // Fallback to Info.plist for development
    if let plistKey = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String {
        return plistKey
    }
    
    // No API key found - this should be set via environment variable or Info.plist
    #if DEBUG
    print("⚠️ Warning: OPENAI_API_KEY not found. Please set it in your environment variables or Info.plist")
    return ""
    #else
    fatalError("OPENAI_API_KEY not found in environment or Info.plist")
    #endif
}()
```

## 🧪 **Testing Your Setup**

### 1. Verify Configuration
The app will print a warning if the API key is invalid:
```
⚠️ Warning: OpenAI API key configuration is invalid
```

### 2. Test AI Integration
1. Open the app
2. Go to Chat
3. Send a message like "I need help with cleaning"
4. Check if AI recommendations appear

### 3. Debug Configuration
Add this to your code temporarily:
```swift
print("API Key configured: \(Config.openAIKey.prefix(10))...")
print("Configuration valid: \(Config.validateConfiguration())")
```

## 🚀 **Production Deployment Checklist**

- [ ] Remove API key from `Info.plist`
- [ ] Set up environment variables in your deployment environment
- [ ] Verify `.gitignore` includes sensitive files
- [ ] Test with production API key
- [ ] Monitor API usage and costs

## 🔧 **Troubleshooting**

### "API key configuration is invalid"
- Check that your API key starts with `sk-`
- Verify the key is not empty
- Ensure the key is properly formatted

### "OPENAI_API_KEY not found"
- Set the environment variable
- Check Info.plist configuration
- Verify the key name matches exactly

### Build Errors
- Ensure `Config.swift` is included in the Xcode project
- Check that all files are properly linked
- Clean and rebuild the project

## 📞 **Support**

If you encounter issues:
1. Check the console output for error messages
2. Verify your OpenAI API key is active
3. Test the API key directly with OpenAI's API
4. Check your network connectivity

## 🔄 **API Key Rotation**

When rotating API keys:
1. Generate new key in OpenAI dashboard
2. Update environment variable or Info.plist
3. Test the new key
4. Revoke the old key after confirming new one works 