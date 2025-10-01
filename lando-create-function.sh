# Add this function to your ~/.zshrc file
# Then you can use: lando-create <project-name> [run-all] from any directory

lando-create() {
    local script_path="/Users/lajennylove/code/projects/lando-generator/lando-create.sh"
    
    if [ ! -f "$script_path" ]; then
        echo "❌ Error: lando-create.sh not found at $script_path"
        echo "Please update the script_path in your .zshrc function"
        return 1
    fi
    
    # Call the script from the central location
    bash "$script_path" "$@"
}
