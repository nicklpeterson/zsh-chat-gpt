# zsh-chat-gpt

#### Command hints from Chat GPT in your terminal!

Inspired by and adapted from [zsh-gpt](https://github.com/antonjs/zsh-gpt)

![zsh-chat-gpt](https://github.com/user-attachments/assets/9c4bed75-bf2a-4818-be04-47bfdc460891)

## Installation

#### [Oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)

1. Clone this repository in oh-my-zsh's plugins directory:

    ```zsh
    git clone https://github.com/nicklpeterson/zsh-chat-gpt.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-chat-gpt
    ```

2. Activate the plugin in `~/.zshrc`:

    ```zsh
    plugins=( [plugins...] zsh-chat-gpt)
    ```

3. Restart zsh (such as by opening a new instance of your terminal emulator).


#### Manual

1. Clone the repo
    ```zsh
    git clone https://github.com/nicklpeterson/zsh-chat-gpt.git ~/somewhere
    ```
2. Add this line to your `~/.zshrc` file
    ```zsh
    autoload -U compinit; compinit
    source ~/somewhere/zsh-chat-gpt/zsh-chat-gpt.plugin.zsh
    ```

    
## Environment Variables

Add these to your `~/.zshrc` file.

#### Required

```zsh
export OPENAI_API_KEY=<your_openai_api_key>
```

#### Optional

```zsh
export OPENAI_GPT_CONTEXT=<your_context> # see the default context in zsh-chat-gpt.plugin.zsh
export OPENAI_CHAT_MODEL=<an_openai_model> # defaults to gpt-5-nano, note that some models don't support streaming
export OPENAI_STREAMING_ENABLED=<true|false> # defaults to true, this enables a nice typing effect for responses
```
