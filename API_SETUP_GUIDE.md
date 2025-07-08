# API Setup Guide

## Overview
This guide explains how to securely set up your OpenAI API key for the Gig app without exposing sensitive credentials in your repository.

## Security Notice
⚠️ **Never commit API keys to your repository!** This can lead to:
- Unauthorized usage of your API credits
- Potential security breaches
- Repository being flagged by GitHub's secret scanning

## Setup Options

### Option 1: Environment Variables (Recommended)

1. **Set the environment variable:**
   ```bash
   export OPENAI_API_KEY="your-actual-api-key-here"
   ```

2. **For persistent setup, add to your shell profile:**
   ```bash
   # For zsh (macOS default)
   echo 'export OPENAI_API_KEY="your-actual-api-key-here"' >> ~/.zshrc
   source ~/.zshrc
   
   # For bash
   echo 'export OPENAI_API_KEY="your-actual-api-key-here"' >> ~/.bash_profile
   source ~/.bash_profile
   ```

3. **Verify the environment variable is set:**
   ```bash
   echo $OPENAI_API_KEY
   ```

### Option 2: Info.plist (Development Only)

1. **Open `Info.plist` in your project**
2. **Uncomment the API key section:**
   ```xml
   <key>OPENAI_API_KEY</key>
   <string>your-actual-api-key-here</string>
   ```
3. **Remove the comment markers (`<!--` and `-->`)**

⚠️ **Warning**: This method is less secure and should only be used for development.

### Option 3: Xcode Environment Variables

1. **Open your project in Xcode**
2. **Select your target**
3. **Go to Edit Scheme**
4. **Select "Run" from the left sidebar**
5. **Go to the "Arguments" tab**
6. **Under "Environment Variables", add:**
   - Name: `OPENAI_API_KEY`
   - Value: `your-actual-api-key-here`

## Getting Your OpenAI API Key

1. **Visit [OpenAI Platform](https://platform.openai.com/)**
2. **Sign in or create an account**
3. **Go to API Keys section**
4. **Create a new API key**
5. **Copy the key (it starts with `sk-`)**

## Verification

To verify your API key is working:

1. **Run the app**
2. **Check the console for one of these messages:**
   - ✅ `OpenAI API Key: sk-...` (if key is found)
   - ⚠️ `Warning: OPENAI_API_KEY not found` (if key is missing)

## Troubleshooting

### "API Key Not Found" Error

1. **Check if environment variable is set:**
   ```bash
   echo $OPENAI_API_KEY
   ```

2. **If empty, set it:**
   ```bash
   export OPENAI_API_KEY="your-key-here"
   ```

3. **Restart Xcode and rebuild the project**

### "Invalid API Key" Error

1. **Verify your key starts with `sk-`**
2. **Check that you copied the entire key**
3. **Ensure your OpenAI account has credits**
4. **Try regenerating the key if needed**

### Build Errors

1. **Clean the build folder:**
   - Xcode → Product → Clean Build Folder
2. **Delete derived data:**
   - Xcode → Window → Projects → Click arrow next to derived data path → Delete
3. **Rebuild the project**

## Security Best Practices

1. **Use environment variables for production**
2. **Never commit API keys to version control**
3. **Rotate API keys regularly**
4. **Monitor API usage in OpenAI dashboard**
5. **Use different keys for development and production**

## Environment-Specific Setup

### Development
- Use environment variables or Info.plist
- Keep keys local to your machine

### Production
- Use environment variables only
- Set up through your deployment platform
- Never use Info.plist for production keys

### CI/CD
- Set environment variables in your CI/CD platform
- Use secret management services
- Never hardcode keys in build scripts

## Support

If you encounter issues:
1. Check the console output for error messages
2. Verify your API key format and validity
3. Ensure your OpenAI account has sufficient credits
4. Check the [OpenAI API documentation](https://platform.openai.com/docs) 