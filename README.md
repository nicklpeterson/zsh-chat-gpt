# Usage

## Installation 

* Clone this repository locaally and copy zsh-chat-gpt to your preferred location

### Examples

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

## Environment Variables

Add these to your `.zshrc` file.

#### Required

```zsh
OPENAI_API_KEY=<your_openai_api_key>
```

#### Optional

```zsh
OPENAI_GPT_CONTEXT=<your_context> # see the default context in zsh-chat-gpt.plugin.zsh
OPENAI_CHAT_MODEL=<an_openai_model> # defaults to gpt-5-nano, note that some models don't support streaming
OPENAI_STREAMING_ENABLED=<true|false> # defaults to true, this enables a nice typing effect for responses
```
