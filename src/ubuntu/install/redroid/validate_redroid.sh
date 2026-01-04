#!/usr/bin/env bash
# Redroid Validation Script
# This script validates that Redroid and all related tools are properly configured

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Helper functions
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_test() {
    echo -e "${YELLOW}[TEST]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓ PASS]${NC} $1"
    ((PASSED++))
}

print_fail() {
    echo -e "${RED}[✗ FAIL]${NC} $1"
    ((FAILED++))
}

print_warning() {
    echo -e "${YELLOW}[⚠ WARN]${NC} $1"
    ((WARNINGS++))
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Test 1: Check ADB installation
test_adb() {
    print_header "Testing ADB (Android Debug Bridge)"
    
    print_test "Checking if ADB is installed..."
    if command -v adb &> /dev/null; then
        ADB_VERSION=$(adb version | head -n 1)
        print_success "ADB is installed: $ADB_VERSION"
    else
        print_fail "ADB is not installed"
        return 1
    fi
}

# Test 2: Check scrcpy installation
test_scrcpy() {
    print_header "Testing scrcpy (Screen Mirror)"
    
    print_test "Checking if scrcpy is installed..."
    if command -v scrcpy &> /dev/null; then
        SCRCPY_VERSION=$(scrcpy --version 2>&1 | head -n 1)
        print_success "scrcpy is installed: $SCRCPY_VERSION"
    else
        print_fail "scrcpy is not installed"
        return 1
    fi
    
    print_test "Checking scrcpy desktop launcher..."
    if [ -f "/usr/share/applications/scrcpy.desktop" ]; then
        print_success "scrcpy desktop launcher exists"
    else
        print_warning "scrcpy desktop launcher not found"
    fi
}

# Test 3: Check Android SDK
test_android_sdk() {
    print_header "Testing Android SDK"
    
    print_test "Checking ANDROID_HOME environment variable..."
    if [ -n "$ANDROID_HOME" ]; then
        print_success "ANDROID_HOME is set: $ANDROID_HOME"
    else
        print_warning "ANDROID_HOME is not set in current session"
        print_info "Checking /etc/profile.d/android.sh..."
        if [ -f "/etc/profile.d/android.sh" ]; then
            print_info "Android environment file exists. Source it with: source /etc/profile.d/android.sh"
        fi
    fi
    
    print_test "Checking Android SDK directory..."
    if [ -d "/opt/android-sdk" ]; then
        print_success "Android SDK directory exists: /opt/android-sdk"
    else
        print_fail "Android SDK directory not found"
        return 1
    fi
    
    print_test "Checking Android command-line tools..."
    if [ -d "/opt/android-sdk/cmdline-tools/latest" ]; then
        print_success "Android command-line tools installed"
    else
        print_fail "Android command-line tools not found"
        return 1
    fi
    
    print_test "Checking sdkmanager..."
    if [ -f "/opt/android-sdk/cmdline-tools/latest/bin/sdkmanager" ]; then
        print_success "sdkmanager binary exists"
    else
        print_fail "sdkmanager not found"
        return 1
    fi
    
    print_test "Checking platform-tools..."
    if [ -d "/opt/android-sdk/platform-tools" ]; then
        print_success "Android platform-tools installed"
    else
        print_warning "Android platform-tools not found"
    fi
}

# Test 4: Check Flutter installation
test_flutter() {
    print_header "Testing Flutter"
    
    print_test "Checking if Flutter is installed..."
    if [ -d "/opt/flutter/flutter" ]; then
        print_success "Flutter directory exists: /opt/flutter/flutter"
    else
        print_warning "Flutter directory not found at /opt/flutter/flutter"
        return 0
    fi
    
    print_test "Checking Flutter binary..."
    if [ -f "/opt/flutter/flutter/bin/flutter" ]; then
        print_success "Flutter binary exists"
        
        # Check if Flutter is in PATH
        if command -v flutter &> /dev/null; then
            FLUTTER_VERSION=$(flutter --version 2>&1 | head -n 1)
            print_success "Flutter is in PATH: $FLUTTER_VERSION"
        else
            print_warning "Flutter is not in PATH. Add to PATH with: export PATH=/opt/flutter/flutter/bin:\$PATH"
        fi
    else
        print_warning "Flutter binary not found"
    fi
}

# Test 5: Check FVM installation
test_fvm() {
    print_header "Testing FVM (Flutter Version Manager)"
    
    print_test "Checking PUB_CACHE..."
    if [ -d "/opt/flutter/.pub-cache" ]; then
        print_success "PUB_CACHE directory exists"
    else
        print_warning "PUB_CACHE directory not found"
        return 0
    fi
    
    print_test "Checking FVM installation..."
    if [ -f "/opt/flutter/.pub-cache/bin/fvm" ]; then
        print_success "FVM binary exists"
        
        if command -v fvm &> /dev/null; then
            FVM_VERSION=$(fvm --version 2>&1)
            print_success "FVM is in PATH: $FVM_VERSION"
        else
            print_warning "FVM is not in PATH. Add to PATH with: export PATH=/opt/flutter/.pub-cache/bin:\$PATH"
        fi
    else
        print_warning "FVM not found"
    fi
}

# Test 6: Check Redroid connectivity
test_redroid_connection() {
    print_header "Testing Redroid Connection"
    
    print_test "Attempting to connect to Redroid (localhost:5555)..."
    
    # Try to connect
    adb connect localhost:5555 &> /dev/null || true
    sleep 2
    
    # Check devices
    DEVICES=$(adb devices | grep -v "List of devices" | grep -v "^$" | wc -l)
    
    if [ "$DEVICES" -gt 0 ]; then
        print_success "Redroid device connected"
        print_info "Connected devices:"
        adb devices | grep -v "List of devices" | grep -v "^$" | while read line; do
            echo -e "  ${GREEN}→${NC} $line"
        done
        
        # Get Android version
        print_test "Getting Android version..."
        ANDROID_VERSION=$(adb shell getprop ro.build.version.release 2>/dev/null || echo "unknown")
        if [ "$ANDROID_VERSION" != "unknown" ]; then
            print_success "Android version: $ANDROID_VERSION"
        fi
        
        # Get device model
        print_test "Getting device model..."
        DEVICE_MODEL=$(adb shell getprop ro.product.model 2>/dev/null || echo "unknown")
        if [ "$DEVICE_MODEL" != "unknown" ]; then
            print_success "Device model: $DEVICE_MODEL"
        fi
    else
        print_warning "No Redroid device connected"
        print_info "Redroid might not be running. Check if the Redroid container is active."
        print_info "Try: docker ps | grep redroid"
    fi
}

# Test 7: Check required dependencies
test_dependencies() {
    print_header "Testing Required Dependencies"
    
    DEPS=("ffmpeg" "wget" "git" "jq")
    
    for dep in "${DEPS[@]}"; do
        print_test "Checking $dep..."
        if command -v "$dep" &> /dev/null; then
            print_success "$dep is installed"
        else
            print_fail "$dep is not installed"
        fi
    done
}

# Test 8: Environment variables summary
test_environment() {
    print_header "Environment Variables Summary"
    
    print_info "Current environment configuration:"
    echo ""
    
    if [ -n "$ANDROID_HOME" ]; then
        echo -e "  ${GREEN}ANDROID_HOME${NC} = $ANDROID_HOME"
    else
        echo -e "  ${RED}ANDROID_HOME${NC} = (not set)"
    fi
    
    if [ -n "$ANDROID_SDK_ROOT" ]; then
        echo -e "  ${GREEN}ANDROID_SDK_ROOT${NC} = $ANDROID_SDK_ROOT"
    else
        echo -e "  ${RED}ANDROID_SDK_ROOT${NC} = (not set)"
    fi
    
    if [ -n "$FLUTTER_HOME" ]; then
        echo -e "  ${GREEN}FLUTTER_HOME${NC} = $FLUTTER_HOME"
    else
        echo -e "  ${YELLOW}FLUTTER_HOME${NC} = (not set)"
    fi
    
    if [ -n "$PUB_CACHE" ]; then
        echo -e "  ${GREEN}PUB_CACHE${NC} = $PUB_CACHE"
    else
        echo -e "  ${YELLOW}PUB_CACHE${NC} = (not set)"
    fi
    
    echo ""
    print_info "To load all environment variables, run:"
    echo -e "  ${BLUE}source /etc/profile.d/android.sh${NC}"
    echo -e "  ${BLUE}source /etc/profile.d/fvm.sh${NC}"
}

# Main execution
main() {
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════╗"
    echo "║   Redroid Validation Script v1.0       ║"
    echo "║   Testing Redroid & Android SDK Setup  ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Run all tests
    test_adb || true
    test_scrcpy || true
    test_android_sdk || true
    test_flutter || true
    test_fvm || true
    test_dependencies || true
    test_redroid_connection || true
    test_environment
    
    # Summary
    print_header "Validation Summary"
    echo -e "${GREEN}Passed:${NC}   $PASSED"
    echo -e "${RED}Failed:${NC}   $FAILED"
    echo -e "${YELLOW}Warnings:${NC} $WARNINGS"
    echo ""
    
    if [ $FAILED -eq 0 ]; then
        echo -e "${GREEN}✓ All critical tests passed!${NC}"
        
        if [ $WARNINGS -gt 0 ]; then
            echo -e "${YELLOW}⚠ Some warnings were found. Review them above.${NC}"
        fi
        
        echo ""
        print_info "Next steps to use Redroid:"
        echo -e "  1. ${BLUE}adb connect localhost:5555${NC}  - Connect to Redroid"
        echo -e "  2. ${BLUE}adb devices${NC}                 - List connected devices"
        echo -e "  3. ${BLUE}scrcpy --serial localhost:5555${NC} - Mirror Android screen"
        echo -e "  4. ${BLUE}adb install app.apk${NC}         - Install an APK"
        
        exit 0
    else
        echo -e "${RED}✗ Some tests failed. Please review the errors above.${NC}"
        exit 1
    fi
}

# Run main function
main
