#!/bin/zsh

gpt() {
  if [[ ! $+commands[curl] ]]; then echo "curl must be installed."; return 1; fi
  if [[ ! $+commands[jq] ]]; then echo "jq must be installed."; return 1; fi
  if [[ ! -v OPENAI_API_KEY ]]; then echo "Must set OPENAI_API_KEY to your API key"; return 1; fi

  local context=${OPENAI_GPT_CONTEXT-"you're an in-line zsh assistant running on a mac iterm terminal. \
Your task is to answer the questions without any commentation at all, providing only the code to run on terminal. \
You can assume that the user understands that they need to fill in placeholders like <PORT>. \
You''re not allowed to explain anything and you are not a chatbot. \
You only provide shell commands or code. \
Keep the responses to one-liner answers as much as possible. \
Do not decorate the answer with tickmarks"}

  local model=${OPENAI_CHAT_MODEL-"gpt-5-nano"}

  local streaming_enabled=${OPENAI_STREAMING_ENABLED-true}

  local input=$*

  if [[ "$streaming_enabled" = true ]]; then
    _gpt_stream $context $model $input
  else
    _gpt_without_streaming $context $model $input
  fi
}

_gpt_without_streaming() {
  local context=$1
  local model=$2
  local input=$3

  emulate -L zsh
  setopt pipefail
  setopt localoptions nomonitor

  _hide_cursor

  # Ensure cursor is restored on exit or Ctrl-C
  trap 'show_cursor; print ""; return' INT

  _start_spinner $model & spinner_pid=$!
   
  local response=$(curl https://api.openai.com/v1/chat/completions -sN \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d '{
      "model": "'"$model"'",
      "messages": [
        {"role": "developer", "content": "'"$context"'" },
        {"role": "user", "content": "'"$input"'"}
      ]
    }'| jq -r 'try .choices[].message.content // .')

  _stop_spinner $spinner_pid

  printf "%s\n" "$response"

  _show_cursor

  return 1
}

_gpt_stream() {
  local context=$1
  local model=$2
  local input=$3

  emulate -L zsh
  setopt pipefail
  setopt localoptions nomonitor

  exec {FD}< <(
    curl https://api.openai.com/v1/chat/completions -sN \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -d '{
        "model": "'"$model"'",
        "stream": true,
        "messages": [
          {"role": "developer", "content": "'"$context"'" },
          {"role": "user", "content": "'"$input"'"}
        ]
      }'
  )

  _hide_cursor

  # Ensure cursor is restored on exit or Ctrl-C
  trap 'stop_spinner $spinner_pid; print ""; return' INT TERM # EXIT

  _start_spinner $model & spinner_pid=$!

  # Wait for the first line of data
  local line
  while true; do
    if read -t 0.05 -u $FD line; then
      _stop_spinner $spinner_pid
      break
    fi
  done

  # Process the first line (already read)
  _parse_chunk "$line"
  
  # Continue reading and parsing the rest of the stream
  while IFS= read -r line <&$FD; do
    _parse_chunk "$line"
  done

  exec {FD}<&-
  echo ""
  return 0
}

_parse_chunk() {
  local line=$1
  local trimmed=$(tr -d '\r' <<< "$line")

  if [[ "$trimmed" = "{" || "$trimmed" = "}" ]]; then 
    echo $line
    return
  fi

  if [[ "$line" == "data: [DONE]" ]]; then
    return
  fi

  local json_data=${line#data: }
  local finish_reason=$(jq -r 'try .choices[0].finish_reason' <<< $json_data 2>/dev/null)

  if [ "$finish_reason" != "stop" ]; then 
    local gpt_response=$(jq -r 'try .choices[0].delta.content // "zsh-gpt-error"' <<< $json_data 2>/dev/null)

    if [ "$gpt_response" = "zsh-gpt-error" ]; then
      echo $line
    else
      _typing_effect $gpt_response
    fi
  fi
}

_typing_effect() {
  local text=$1
  for (( i=0; i<${#text}; i++ )); do
    printf "%s" "${text:$i:1}"
    sleep 0.02
  done
}

_start_spinner() {
  local state=1
  local frames=(".  " ".. " "..." " .." "  ." "   ")

  while :; do
    for f in "${frames[@]}"; do
      printf "\r%s" "waiting for $model$f"
      sleep 0.08
    done
  done
}

_stop_spinner() {
  local pid=$1
  kill "$pid" 2>/dev/null
  wait "$pid" 2>/dev/null
  printf "\r\033[K\033[?25h"
}

_hide_cursor() {
  printf "\033[?25l"
}

_show_cursor() {
  printf "\033[?25h"
}
