# Debugging Crane Missing Issue - Oct 16, 2025

## 🕵️ **Root Cause Analysis**

### **Issue Discovered**: Wrong Image Tag Reference
**Problem**: Manifest stage was trying to use:
```yaml
name: $ECR_REGISTRY:manifest-tool-20251016  # Multi-arch manifest (doesn't exist yet!)
```

**But actual built images were**:
- `manifest-tool-20251016-amd64` 
- `manifest-tool-20251016-arm64`

### **Why This Happened**
1. **Circular Reference**: Manifest stage tried to use multi-arch manifest-tool image
2. **Bootstrap Problem**: Multi-arch manifest doesn't exist until AFTER manifest stage creates it
3. **Fallback Behavior**: GitLab probably used old cached image or failed silently

## 🔧 **Fixes Applied**

### 1. Use Architecture-Specific Image
```yaml
# Before
name: $ECR_REGISTRY:manifest-tool-20251016

# After  
name: $ECR_REGISTRY:manifest-tool-20251016-amd64
```

### 2. Added Diagnostic Checks
```bash
# Verify crane availability at start of manifest stage
if command -v crane >/dev/null 2>&1; then
  echo "✅ crane is available in this image"
else
  echo "❌ crane not found in image - will install via apk"
fi
```

### 3. Enhanced Error Detection
- Check both crane and manifest-tool availability
- Show version information for debugging
- Clear logging of which image is being used

## 🧠 **Key Insights**

### **Bootstrap Order Matters**
1. **Build stage**: Creates arch-specific images (`-amd64`, `-arm64`)
2. **Manifest stage**: Uses arch-specific image to create multi-arch manifests
3. **Future stages**: Can use multi-arch manifests

### **Self-Reference Problem**
- manifest-tool can't use its own multi-arch manifest until it creates it
- Must use architecture-specific version for manifest creation
- Classic chicken-and-egg problem in image building

### **Caching Complications**  
- GitLab runners cache images at pipeline start
- New builds during same pipeline may not be used
- Need explicit architecture tags to avoid ambiguity

## 🎯 **Expected Fix**

With these changes, the manifest stage should:
1. ✅ Pull the correct `manifest-tool-20251016-amd64` image WITH crane
2. ✅ Verify crane availability with diagnostic output
3. ✅ Successfully create additional tags using crane
4. ✅ Show clear error messages if anything fails

## 📋 **Testing Strategy**

Next pipeline run should show:
```
✅ crane is available in this image
✅ manifest-tool is available
Processing additional tags for test-app:
  Creating additional tag: test-app-latest
  ✅ Tagged [ECR]:test-app-latest
```

---
**Lesson Learned**: Always use architecture-specific images when building multi-arch manifests to avoid circular dependencies!