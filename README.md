# Shell User Manager

A utility for managing multiple shell profiles with different configurations and git identities.

## Features

- Select from multiple user profiles at shell startup
- Automatically switch between different shell configurations
- Manage profiles using the `profilectl` command-line tool
- Create profiles from reusable templates
- Integrates with git-user-manager to set the appropriate git identity
- Automatically switches to zsh when a .zshrc file is present
- Sets profile-specific gitconfig
- Supports oh-my-zsh with profile-specific themes and plugins

## Installation

```bash
sudo ./setup.sh
```

## Usage

Upon login, you will be prompted to select a user profile. Profiles are stored in `~/.profiles/`.

Each profile can have its own:
- `.bashrc` / `.zshrc` configuration
- `.gitconfig` settings
- oh-my-zsh customizations
- Integration with git-user-manager for git identity

## Managing Profiles with profilectl

Shell User Manager provides the `profilectl` command-line tool for managing profiles:

```bash
# Create a new profile from a template
profilectl create username [template-name]

# List all available profiles
profilectl list

# Delete a profile
profilectl delete username

# Edit a profile's configuration file
profilectl edit username [filename]
```

### Template Management

`profilectl` also lets you manage reusable templates:

```bash
# List available templates
profilectl template-list

# Create a new template
profilectl template-create template-name

# Edit a template file
profilectl template-edit template-name [filename]
```

Templates are stored in `~/.profiles/templates/` and contain configuration files that will be copied when creating new profiles.

## Creating Profiles Manually

You can also create profiles manually by adding a directory to `~/.profiles/`:

```bash
mkdir -p ~/.profiles/personal
mkdir -p ~/.profiles/work
```

Add your shell configuration files to each profile directory:

```bash
touch ~/.profiles/personal/.bashrc
touch ~/.profiles/personal/.zshrc
touch ~/.profiles/personal/.gitconfig
```

## Oh-My-Zsh Integration

Shell User Manager supports oh-my-zsh with profile-specific customizations. If oh-my-zsh is installed, the setup script will:

1. Create a `.oh-my-zsh-custom` directory in each profile for custom themes and plugins
2. Generate a sample `.zshrc` with oh-my-zsh configuration
3. Set the appropriate environment variables when a profile is selected

To add custom themes or plugins for a specific profile:

```bash
# Add a custom theme
cp my-custom-theme.zsh-theme ~/.profiles/work/.oh-my-zsh-custom/themes/

# Add a custom plugin
mkdir -p ~/.profiles/work/.oh-my-zsh-custom/plugins/my-plugin
cp my-plugin.zsh ~/.profiles/work/.oh-my-zsh-custom/plugins/my-plugin/
```

Then update your profile's `.zshrc` to use these customizations:

```bash
# In ~/.profiles/work/.zshrc
ZSH_THEME="my-custom-theme"
plugins=(git my-plugin)
```

## Integration with git-user-manager

This tool works alongside [git-user-manager](https://github.com/shadowhand/git-user-manager) to switch git identities when you switch profiles.

## License

See the [LICENSE](LICENSE) file for details.