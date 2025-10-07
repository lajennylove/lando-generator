# 🚀 Lando Generator Installation Guide

This guide will help you install the lando-generator on your system.

## 📋 Prerequisites

- **Lando**: Make sure you have [Lando](https://lando.dev/) installed
- **Git**: Required for cloning repositories
- **SSH Keys**: Your SSH keys should be in `~/.ssh/` directory

## 🛠️ Installation Methods

### Method 1: Automated Installation (Recommended)

1. **Clone the repository**:

   ```bash
   git clone git@github.com:lajennylove/lando-generator.git
   cd lando-generator
   ```

2. **Run the installer**:

   ```bash
   ./install.sh
   ```

3. **Reload your shell**:

   ```bash
   # For Zsh
   source ~/.zshrc

   # For Bash
   source ~/.bashrc
   ```

4. **Test the installation**:
   ```bash
   lando-create --help
   ```

### Method 2: Manual Installation

1. **Clone the repository**:

   ```bash
   git clone git@github.com:lajennylove/lando-generator.git
   cd lando-generator
   ```

2. **Copy SSH keys**:

   ```bash
   cp ~/.ssh/id_ed25519* setup/
   ```

3. **Add function to your shell profile**:

   **For Zsh** (add to `~/.zshrc`):

   ```bash
   # Lando Generator Function
   lando-create() {
       local script_path="/path/to/your/lando-generator/lando-create.sh"

       if [ ! -f "$script_path" ]; then
           echo "❌ Error: lando-create.sh not found at $script_path"
           return 1
       fi

       /bin/bash "$script_path" "$@"
   }
   ```

   **For Bash** (add to `~/.bashrc`):

   ```bash
   # Lando Generator Function
   lando-create() {
       local script_path="/path/to/your/lando-generator/lando-create.sh"

       if [ ! -f "$script_path" ]; then
           echo "❌ Error: lando-create.sh not found at $script_path"
           return 1
       fi

       /bin/bash "$script_path" "$@"
   }
   ```

4. **Reload your shell**:
   ```bash
   source ~/.zshrc  # or ~/.bashrc
   ```

## 🧪 Testing the Installation

1. **Create a test project**:

   ```bash
   mkdir ~/test-project
   cd ~/test-project
   ```

2. **Run lando-create**:

   ```bash
   # Create just the .lando.yml file
   lando-create test-project

   # Or run full setup
   lando-create test-project run-all
   ```

3. **Verify the setup**:
   ```bash
   ls -la .lando.yml
   lando start
   ```

## 🔧 Troubleshooting

### Function Not Found

If you get `lando-create: command not found`:

1. **Check if the function is loaded**:

   ```bash
   type lando-create
   ```

2. **Reload your shell**:

   ```bash
   source ~/.zshrc  # or ~/.bashrc
   ```

3. **Check the function definition**:
   ```bash
   declare -f lando-create
   ```

### SSH Key Issues

If you get SSH key errors:

1. **Check if SSH keys exist**:

   ```bash
   ls -la ~/.ssh/id_ed25519*
   ```

2. **Copy keys to setup directory**:

   ```bash
   cp ~/.ssh/id_ed25519* /path/to/lando-generator/setup/
   ```

3. **Set correct permissions**:
   ```bash
   chmod 600 setup/id_ed25519
   chmod 644 setup/id_ed25519.pub
   ```

### Script Not Found

If you get "lando-create.sh not found":

1. **Check the script path in the function**:

   ```bash
   declare -f lando-create
   ```

2. **Update the path**:
   Edit your `~/.zshrc` or `~/.bashrc` and update the `script_path` variable to the correct location.

## 🎯 Usage Examples

### Basic Usage

```bash
# Navigate to your project directory
cd /path/to/your/project

# Create just the .lando.yml file
lando-create my-project

# Run full setup (WordPress + Sage + Acorn + PEST + ACF + Poet)
lando-create my-project run-all
```

### What Gets Created

When you run `lando-create my-project`, the following files are created in your current directory:

```
your-project/
└── .lando.yml          # Lando configuration file
```

When you run `lando-create my-project run-all`, additionally:

```
your-project/
├── .lando.yml          # Lando configuration file
└── web/                # WordPress installation
    ├── wp-admin/       # WordPress admin
    ├── wp-content/     # WordPress content
    │   └── themes/
    │       └── my-project/  # Sage theme
    ├── wp-includes/    # WordPress core
    └── index.php       # WordPress entry point
```

## 🔄 Updating

To update the lando-generator:

1. **Navigate to the project directory**:

   ```bash
   cd /path/to/lando-generator
   ```

2. **Pull the latest changes**:

   ```bash
   git pull origin main
   ```

3. **Re-run the installer** (optional):
   ```bash
   ./install.sh
   ```

## 🗑️ Uninstalling

To remove the lando-generator:

1. **Remove the function from your shell profile**:
   Edit `~/.zshrc` or `~/.bashrc` and remove the lando-create function.

2. **Reload your shell**:

   ```bash
   source ~/.zshrc  # or ~/.bashrc
   ```

3. **Delete the project directory** (optional):
   ```bash
   rm -rf /path/to/lando-generator
   ```

## 📞 Support

If you encounter any issues:

1. Check the [troubleshooting section](#-troubleshooting) above
2. Review the [main README](README.md) for detailed usage instructions
3. Open an issue on [GitHub](https://github.com/lajennylove/lando-generator/issues)

---

Made with ❤️ by lajennylove
