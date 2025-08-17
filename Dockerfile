FROM node:20-bookworm-slim

ARG USERNAME=node
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG TZ=Asia/Ho_Chi_Minh
ARG CLAUDE_CODE_VERSION=latest

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    sudo \
    ca-certificates \
    ripgrep \
    fd-find \
    jq \
    tree \
    bat \
    htop \
    unzip \
    openssh-server \
    zsh \
    tmux \
    vim \
    nano \
    build-essential \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install cloudflared
RUN curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb \
    && dpkg -i cloudflared.deb \
    && rm cloudflared.deb

# Install Claude Code globally
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}

# Configure the node user
RUN groupmod --gid $USER_GID $USERNAME \
    && usermod --uid $USER_UID --gid $USER_GID $USERNAME \
    && chown -R $USER_UID:$USER_GID /home/$USERNAME

# Add node user to sudoers
RUN echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set up command history persistence
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
    && mkdir /commandhistory \
    && touch /commandhistory/.bash_history \
    && chown -R $USERNAME /commandhistory

# Set up SSH
RUN mkdir -p /var/run/sshd && \
    echo 'Port 22' > /etc/ssh/sshd_config.d/99-custom.conf && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config.d/99-custom.conf && \
    echo 'PermitRootLogin no' >> /etc/ssh/sshd_config.d/99-custom.conf && \
    echo 'X11Forwarding no' >> /etc/ssh/sshd_config.d/99-custom.conf

# Set `DEVCONTAINER` environment variable
ENV DEVCONTAINER=true

# Create workspace and config directories
RUN mkdir -p /workspace /home/node/.claude && \
    chown -R node:node /workspace /home/node/.claude

# Set up the user environment
USER $USERNAME
WORKDIR /workspace

# Install Oh My Zsh for better terminal experience
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true

# Add useful aliases to both bash and zsh
RUN echo 'alias ll="ls -la"' >> ~/.bashrc && \
    echo 'alias la="ls -la"' >> ~/.bashrc && \
    echo 'alias ..="cd .."' >> ~/.bashrc && \
    echo 'alias ...="cd ../.."' >> ~/.bashrc && \
    echo 'alias cc="claude"' >> ~/.bashrc && \
    echo 'alias ccd="claude --dangerously-skip-permissions"' >> ~/.bashrc && \
    echo 'alias expose="cloudflared tunnel --url"' >> ~/.bashrc && \
    echo 'alias tunnel="cloudflared tunnel"' >> ~/.bashrc && \
    echo 'expose-port() { cloudflared tunnel --url http://localhost:$1; }' >> ~/.bashrc && \
    echo 'alias ll="ls -la"' >> ~/.zshrc && \
    echo 'alias la="ls -la"' >> ~/.zshrc && \
    echo 'alias ..="cd .."' >> ~/.zshrc && \
    echo 'alias ...="cd ../.."' >> ~/.zshrc && \
    echo 'alias cc="claude"' >> ~/.zshrc && \
    echo 'alias ccd="claude --dangerously-skip-permissions"' >> ~/.zshrc && \
    echo 'alias expose="cloudflared tunnel --url"' >> ~/.zshrc && \
    echo 'alias tunnel="cloudflared tunnel"' >> ~/.zshrc && \
    echo 'expose-port() { cloudflared tunnel --url http://localhost:$1; }' >> ~/.zshrc

# Set default shell to zsh
RUN sudo chsh -s $(which zsh) $USERNAME

# Switch back to root for startup commands
USER root

# Expose SSH port
EXPOSE 22

# Start SSH daemon and keep container running
CMD ["/bin/bash", "-c", "service ssh start && tail -f /dev/null"]
