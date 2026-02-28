FROM mcr.microsoft.com/devcontainers/cpp:2-ubuntu24.04

ARG LLVM_VERSION=20
ARG NODE_VERSION=22
ARG USERNAME=vscode

# ── LLVM / Clang (full toolchain) ────────────────────────────────────────────
RUN apt-get update \
    && apt-get install -y --no-install-recommends software-properties-common \
    && wget -qO /tmp/llvm.sh https://apt.llvm.org/llvm.sh \
    && chmod +x /tmp/llvm.sh \
    && bash /tmp/llvm.sh ${LLVM_VERSION} all \
    && rm /tmp/llvm.sh \
    # Register all tools with update-alternatives
    && for tool in clang clang++ clangd clang-format clang-tidy clang-query \
    lldb lld lld-link ld.lld \
    llvm-ar llvm-as llvm-cov llvm-dis llvm-dwarfdump \
    llvm-link llvm-nm llvm-objcopy llvm-objdump \
    llvm-profdata llvm-ranlib llvm-readelf llvm-size \
    llvm-strings llvm-strip llvm-symbolizer; do \
    bin="/usr/bin/${tool}-${LLVM_VERSION}"; \
    [ -f "$bin" ] && update-alternatives --install /usr/bin/${tool} ${tool} ${bin} 100 || true; \
    done \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ── ccache + zsh ─────────────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    ccache \
    zsh \
    && rm -rf /var/lib/apt/lists/* \
    # Global ccache config: unlimited cache size
    && echo "max_size = 0" > /etc/ccache.conf \
    # Make ccache intercept clang/clang++ transparently
    && ln -sf /usr/bin/ccache /usr/local/bin/clang \
    && ln -sf /usr/bin/ccache /usr/local/bin/clang++ \
    && ln -sf /usr/bin/ccache /usr/local/bin/cc \
    && ln -sf /usr/bin/ccache /usr/local/bin/c++ \
    # Set zsh as default shell for the dev user
    && chsh -s /usr/bin/zsh ${USERNAME}

# ── Node.js ───────────────────────────────────────────────────────────────────
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# ── User-level setup (oh-my-zsh, plugins, uv, rust) ──────────────────────────
USER ${USERNAME}
WORKDIR /home/${USERNAME}

# oh-my-zsh (unattended, no shell change since we handled it above)
RUN if [ ! -d "$HOME/.oh-my-zsh" ]; then \
            RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; \
        fi

# Third-party zsh plugins (git + extract are bundled with oh-my-zsh)
RUN if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then \
            git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git \
                ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting; \
        fi \
        && if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then \
            git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git \
                ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions; \
        fi

# Enable plugins in .zshrc
RUN sed -i 's/^plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions extract)/' ~/.zshrc

# uv – fast Python package & project manager
RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
    && echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc

# Rust via rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && echo 'source "$HOME/.cargo/env"' >> ~/.zshrc

# ccache / compiler env
RUN echo 'export CCACHE_CONFIGPATH=/etc/ccache.conf' >> ~/.zshrc \
    && echo 'export CC="clang"' >> ~/.zshrc \
    && echo 'export CXX="clang++"' >> ~/.zshrc

USER root
