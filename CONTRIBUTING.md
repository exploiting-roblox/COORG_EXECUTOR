# Contributing to COORG-EXECUTOR

🎉 **Thank you for your interest in contributing to COORG-EXECUTOR!** 

As the **first professional-grade Roblox executor for Linux**, we welcome contributions that help advance the project while maintaining our high standards of quality, security, and ethical use.

---

## 🚀 **Ways to Contribute**

### 🐛 **Bug Reports**
- Use GitHub Issues with clear reproduction steps
- Include system information (distro, kernel version, etc.)
- Provide logs and error messages
- Test on multiple distributions when possible

### 💡 **Feature Requests** 
- Submit detailed proposals via GitHub Discussions
- Explain the use case and benefit
- Consider implementation complexity
- Ensure alignment with project goals

### 🔧 **Code Contributions**
- Core engine improvements (C/C++)
- GUI enhancements (Python)
- Script development (Lua)
- Documentation improvements
- Test case development

### 📚 **Documentation**
- README improvements
- Code comments and inline documentation
- Installation guides for new distributions
- Usage examples and tutorials

---

## 📋 **Contribution Guidelines**

### **Before Starting**
1. **Check existing issues** to avoid duplicates
2. **Open an issue** for major changes to discuss approach
3. **Fork the repository** and create a feature branch
4. **Review the codebase** to understand architecture

### **Development Standards**

#### **Code Quality**
- ✅ Follow existing code style and conventions
- ✅ Add comprehensive comments for complex logic
- ✅ Include error handling and input validation
- ✅ Write clean, readable, and maintainable code

#### **Security Requirements**
- ✅ No hardcoded credentials or sensitive data
- ✅ Input sanitization for all user inputs
- ✅ Secure memory management (no buffer overflows)
- ✅ Principle of least privilege in design

#### **Testing**
- ✅ Test on multiple Linux distributions
- ✅ Verify compatibility with different kernel versions
- ✅ Test edge cases and error conditions
- ✅ Performance testing for core features

---

## 🛠️ **Development Setup**

### **Prerequisites**
```bash
# Install development dependencies
sudo apt install build-essential gcc python3 python3-pip lua5.3-dev git gdb

# Clone your fork
git clone https://github.com/YOUR_USERNAME/COORG_EXECUTOR.git
cd COORG_EXECUTOR

# Set up development environment
cd LINUX/
chmod +x install_coorg.sh
./install_coorg.sh
```

### **Building from Source**
```bash
# Compile core engine
gcc -O3 -Wall -Wextra coorg_core_engine.c -o coorg_core_engine -ldl -lpthread

# Compile injection library
gcc -shared -fPIC coorg_injected_dll.c -o coorg_injected.so -llua5.3 -ldl

# Test GUI
python3 coorg_gui.py
```

---

## 📝 **Commit Guidelines**

### **Commit Message Format**
```
<type>(<scope>): <description>

<optional body>

<optional footer>
```

### **Types**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code formatting (no logic changes)
- `refactor`: Code restructuring without feature changes
- `test`: Adding or updating tests
- `security`: Security improvements
- `perf`: Performance improvements

### **Examples**
```bash
feat(core): implement advanced memory pattern scanning
fix(gui): resolve crash when no Roblox process found
docs(readme): add installation guide for Arch Linux
security(injection): add buffer overflow protection
```

---

## 🧪 **Testing Requirements**

### **Core Engine Testing**
- ✅ Process injection functionality
- ✅ Memory manipulation operations
- ✅ Anti-detection mechanisms
- ✅ Error handling and recovery

### **GUI Testing**
- ✅ All interface components functional
- ✅ Script loading and execution
- ✅ Settings persistence
- ✅ Cross-desktop environment compatibility

### **Distribution Testing**
Test on at least **3** of the following:
- Ubuntu 20.04+ / Pop!_OS
- Debian 11+ / Linux Mint
- Fedora 35+ / CentOS Stream
- Arch Linux / Manjaro
- openSUSE Leap/Tumbleweed

---

## 🎯 **Code Organization**

### **File Structure**
```
LINUX/
├── coorg_core_engine.c      # Core injection and hooking
├── coorg_injected_dll.c     # UNC API implementation
├── coorg_gui.py             # GUI interface
├── install_coorg.sh         # Installation system
└── docs/                    # Additional documentation
```

### **Coding Standards**

#### **C/C++ (Core Engine)**
- Follow Linux kernel coding style
- Use meaningful variable names
- Comment complex algorithms
- Error checking for all system calls

#### **Python (GUI)**
- Follow PEP 8 style guidelines
- Use type hints where appropriate
- Docstrings for all functions
- Exception handling for file operations

#### **Lua (Scripts)**
- Clear, readable code structure
- Comments explaining game-specific logic
- Error handling for API calls
- Performance considerations

---

## 🛡️ **Ethical Guidelines**

### **Acceptable Contributions**
- ✅ Performance optimizations
- ✅ Bug fixes and stability improvements
- ✅ Educational features and documentation
- ✅ Cross-platform compatibility
- ✅ Security enhancements
- ✅ Code quality improvements

### **Unacceptable Contributions**
- ❌ Features designed solely for griefing
- ❌ Exploits targeting specific users
- ❌ Code that violates platform ToS
- ❌ Malicious or harmful functionality
- ❌ Closed-source or proprietary dependencies

---

## 📊 **Review Process**

### **Pull Request Requirements**
1. **Clear description** of changes and motivation
2. **Testing evidence** on multiple distributions
3. **Documentation updates** if applicable
4. **No breaking changes** without discussion
5. **Security review** for sensitive components

### **Review Timeline**
- **Initial Response:** Within 48 hours
- **Full Review:** Within 1 week
- **Security Review:** May require additional time
- **Merge Decision:** Based on quality and alignment

---

## 🏆 **Recognition**

### **Contributor Types**
- 🐛 **Bug Hunters:** Find and report issues
- 💻 **Code Contributors:** Submit code improvements
- 📚 **Documentation Writers:** Improve guides and docs
- 🧪 **Testers:** Verify functionality across platforms
- 🎨 **UI/UX Designers:** Enhance user experience
- 🔒 **Security Researchers:** Identify vulnerabilities

### **Hall of Fame**
Contributors will be recognized in:
- README.md acknowledgments
- Release notes for major contributions
- Contributor documentation
- Project website (when available)

---

## 💬 **Communication**

### **Preferred Channels**
- **GitHub Issues:** Bug reports and feature requests
- **GitHub Discussions:** General discussion and ideas
- **Pull Requests:** Code review and collaboration
- **Email:** Security vulnerabilities (responsible disclosure)

### **Response Times**
- **Issues/PRs:** 48 hours for initial response
- **Discussions:** Best effort within 1 week
- **Security Reports:** 24 hours acknowledgment

---

## 📚 **Resources**

### **Technical Documentation**
- [UNC API Standards](https://scriptware.notion.site/UNC-Environment-Checking-4e31e35ba59041cc804cbb9fb8ce8e76)
- [Linux System Programming](https://man7.org/linux/man-pages/)
- [Roblox Lua Reference](https://developer.roblox.com/en-us/api-reference)

### **Security Guidelines**
- [OWASP Secure Coding Practices](https://owasp.org/www-project-secure-coding-practices-quick-reference-guide/)
- [Linux Security Best Practices](https://www.cyberciti.biz/tips/linux-security.html)

---

## 🤝 **Code of Conduct**

### **Our Standards**
- ✅ **Respectful communication** with all contributors
- ✅ **Constructive feedback** and collaborative problem-solving
- ✅ **Focus on project goals** and technical merit
- ✅ **Inclusive environment** welcoming diverse perspectives
- ✅ **Ethical development** practices and responsible use

### **Unacceptable Behavior**
- ❌ Harassment, discrimination, or personal attacks
- ❌ Spam, trolling, or disruptive behavior
- ❌ Sharing private information without permission
- ❌ Commercial promotion without permission
- ❌ Violation of applicable laws or platform policies

---

## 🎯 **Getting Started**

Ready to contribute? Here's your roadmap:

1. **🍴 Fork** the repository
2. **📋 Check issues** for good first issues
3. **🔧 Set up** development environment
4. **💡 Choose** an area to contribute
5. **📝 Create** a detailed plan
6. **🚀 Start coding** with quality in mind
7. **🧪 Test thoroughly** across platforms
8. **📤 Submit** a well-documented PR

---

**Thank you for helping make COORG-EXECUTOR the best Roblox executor for Linux!** 🐧🚀

> *"Great software is built by great communities. Your contribution matters."*