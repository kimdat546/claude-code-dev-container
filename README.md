# Claude Code Development Environment

A containerized development environment for Claude Code, providing a complete Node.js development stack with SSH access, modern CLI tools, and both Docker Compose and VS Code Dev Container support.

## Overview

This project provides multiple ways to run a Claude Code development environment:
- **Docker Compose**: Standalone container with SSH access
- **VS Code Dev Container**: Integrated development with VS Code
- Pre-installed Claude Code CLI (`@anthropic-ai/claude-code`)
- Complete development toolchain (Node.js 20, Python3, Git, build tools)
- Modern CLI tools (ripgrep, fd-find, bat, tree, jq)
- Persistent storage for workspace and configurations

## Features

- **Node.js 20**: Latest LTS with development tools
- **Claude Code Ready**: Pre-installed CLI with convenient aliases (`cc`, `ccd`)
- **Dual Setup**: Docker Compose for SSH access OR VS Code Dev Container integration
- **Enhanced Terminal**: Oh My Zsh with useful aliases and modern CLI tools
- **Persistent Storage**: Workspace, home directory, and config persist across restarts
- **Development Tools**: Git, Python3, build-essential, tmux, htop, vim, nano

## Quick Start

### Option 1: Docker Compose (SSH Access)

1. **Copy environment file:**
   ```bash
   cp .env.example .env
   # Edit .env to set your secure password
   ```

2. **Start the container:**
   ```bash
   docker-compose up -d
   ```

3. **Connect via SSH:**
   ```bash
   ssh node@localhost -p 2222
   # Use the password from your .env file (default: claude123)
   ```

### Option 2: VS Code Dev Container

1. **Open in VS Code:**
   - Install the "Dev Containers" extension
   - Open this folder in VS Code
   - Press `Ctrl+Shift+P` → "Dev Containers: Reopen in Container"

2. **Start developing:**
   - VS Code will build and connect to the container automatically
   - Terminal opens in `/workspace` with all tools ready

### Using Claude Code

```bash
# Full command
claude

# Using aliases (available in both setups)
cc              # alias for claude
ccd             # alias for claude --dangerously-skip-permissions
```

## Configuration

### Environment Variables (Docker Compose Only)

Configure the Docker Compose setup by creating a `.env` file:

| Variable | Default | Description |
|----------|---------|-------------|
| `NODE_PASSWORD` | `claude123` | SSH password for node user |
| `SSH_PORT` | `2222` | External SSH port mapping |

### Example .env file:
```env
NODE_PASSWORD=your-super-secure-password
SSH_PORT=2222
```

### VS Code Dev Container Configuration

The Dev Container is pre-configured with:
- ESLint, Prettier, GitLens extensions
- Zsh as default terminal
- Format on save enabled
- Claude Code feature automatically installed

## Container Structure

### Volumes (Docker Compose)
- `claude_workspace:/workspace` - Your development workspace
- `claude_home:/home/node` - User home directory  
- `claude_history:/commandhistory` - Command history persistence
- `claude_config:/home/node/.claude` - Claude configuration files

### Pre-installed Tools

**Development:**
- Node.js 20 (LTS) with npm
- Claude Code CLI (`@anthropic-ai/claude-code`)
- Python3 with pip
- Git version control

**System Tools:**
- OpenSSH server (Docker Compose only)
- tmux, htop, tree, vim, nano
- Oh My Zsh shell with enhancements
- build-essential for native modules
- curl, unzip for downloads

**Modern CLI:**
- ripgrep (`rg`) - Fast text search
- fd-find (`fd`) - Fast file search  
- bat - Enhanced cat with syntax highlighting
- jq - JSON processor

### Useful Aliases

Pre-configured aliases in both `.bashrc` and `.zshrc`:
```bash
ll="ls -la"           # Long list format  
la="ls -la"           # List all files
..="cd .."            # Go up one directory
...="cd ../.."        # Go up two directories
cc="claude"           # Claude Code shortcut
ccd="claude --dangerously-skip-permissions"  # Claude with skip permissions
```

## Usage Examples

### Basic Development Workflow

**Docker Compose:**
1. **Connect to container:**
   ```bash
   ssh node@localhost -p 2222
   ```

2. **Navigate to workspace:**
   ```bash
   cd /workspace
   ```

**VS Code Dev Container:**
1. **Open in VS Code** (automatically in `/workspace`)

**Both setups:**
3. **Start a new project:**
   ```bash
   mkdir my-project && cd my-project
   npm init -y
   ```

4. **Use Claude Code:**
   ```bash
   cc  # Start Claude Code session
   ```

### Managing the Container

**Docker Compose:**
```bash
# Start container
docker-compose up -d

# View logs
docker-compose logs -f claude-dev

# Stop container
docker-compose down

# Rebuild container (after changes)
docker-compose up -d --build

# Access container shell directly
docker-compose exec claude-dev bash
```

**VS Code Dev Container:**
- Use Command Palette: `Dev Containers: Rebuild Container`
- Or: `Dev Containers: Reopen in Container`

## Security Notes

**Docker Compose SSH Setup:**
- SSH password authentication enabled (configurable via `.env`)
- Root login disabled, only `node` user access
- The `node` user has passwordless sudo privileges
- X11 forwarding disabled
- Default password should be changed via `.env` file
- Consider SSH keys for production environments

**Both Setups:**
- Container runs with non-root user (`node`)
- Network capabilities limited to development needs

## Troubleshooting

### Common Issues

**Cannot connect via SSH (Docker Compose):**
- Ensure container is running: `docker-compose ps`
- Check port mapping: `docker-compose port claude-dev 22`
- Verify password in `.env` file
- Check logs: `docker-compose logs claude-dev`

**VS Code Dev Container issues:**
- Install "Dev Containers" extension
- Check Docker is running
- Try "Dev Containers: Rebuild Container"

**Tools not found:**
- Restart shell session: `exec zsh` or `exec bash`
- Check Claude Code: `which claude`
- Verify installation: `claude --version`

### Logs and Debugging

**Docker Compose:**
```bash
# Container logs
docker-compose logs -f claude-dev

# SSH service status
docker-compose exec claude-dev service ssh status

# Enter container for debugging
docker-compose exec claude-dev bash
```

**VS Code Dev Container:**
- Check "Dev Containers" output panel in VS Code
- View container logs via Docker Desktop
- Use integrated terminal for debugging

## Customization

**Docker Compose Setup:**
1. Modify `docker-compose.yml` for additional services or ports
2. Add environment variables in `.env` file
3. Mount additional volumes for persistent storage
4. Extend the Dockerfile for additional tools

**VS Code Dev Container:**
1. Modify `devcontainer.json` for additional extensions or settings
2. Update Dockerfile build args in devcontainer.json
3. Add VS Code workspace settings
4. Configure additional dev container features

**Both Setups:**
- Modify Dockerfile to install additional packages
- Update shell configurations in the image build
- Add custom development tools and utilities

## Files Overview

- `Dockerfile` - Container image definition with Node.js 20 and tools
- `docker-compose.yml` - Standalone container with SSH access  
- `devcontainer.json` - VS Code Dev Container configuration
- `.env.example` - Environment variables template
- `README.md` - This documentation

## Contributing

This development environment setup is designed to be flexible and customizable. Feel free to modify and adapt it to your specific Claude Code development needs.