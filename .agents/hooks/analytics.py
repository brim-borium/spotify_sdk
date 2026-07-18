import sys
import json
import os
import datetime
import time

def log_error(msg):
    sys.stderr.write(f"[Analytics Hook Error] {msg}\n")
    sys.stderr.flush()

def main():
    try:
        input_data = json.load(sys.stdin)
    except Exception as e:
        log_error(f"Failed to parse stdin JSON: {e}")
        print("{}")
        sys.exit(0)

    event = input_data.get("hook_event_name", "unknown")
    session_id = input_data.get("session_id", "default_session")
    tool_name = input_data.get("tool_name", "")
    
    current_time_str = datetime.datetime.now().isoformat()
    current_time_val = time.time()
    
    duration = None
    agents_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    
    # Timer logic for tools
    if event == "PreToolUse" and tool_name:
        timer_file = os.path.join(agents_dir, f".timer_{session_id}_{tool_name}")
        try:
            with open(timer_file, "w") as f:
                f.write(str(current_time_val))
        except Exception as e:
            log_error(f"Failed to write timer file: {e}")
            
    elif event == "PostToolUse" and tool_name:
        timer_file = os.path.join(agents_dir, f".timer_{session_id}_{tool_name}")
        if os.path.exists(timer_file):
            try:
                with open(timer_file, "r") as f:
                    start_time_val = float(f.read().strip())
                duration = round(current_time_val - start_time_val, 3)
                os.remove(timer_file)
            except Exception as e:
                log_error(f"Failed to read/delete timer file: {e}")

    # Timer logic for invocation (PreInvocation -> PostInvocation/Stop)
    if event == "PreInvocation":
        timer_file = os.path.join(agents_dir, f".timer_invoc_{session_id}")
        try:
            with open(timer_file, "w") as f:
                f.write(str(current_time_val))
        except Exception as e:
            log_error(f"Failed to write session timer file: {e}")
            
    elif event in ("PostInvocation", "Stop"):
        timer_file = os.path.join(agents_dir, f".timer_invoc_{session_id}")
        if os.path.exists(timer_file):
            try:
                with open(timer_file, "r") as f:
                    start_time_val = float(f.read().strip())
                duration = round(current_time_val - start_time_val, 3)
                # Keep file on PostInvocation, remove on Stop
                if event == "Stop":
                    os.remove(timer_file)
            except Exception as e:
                log_error(f"Failed to read/delete session timer file: {e}")

    # Build the analytics record
    record = {
        "timestamp": current_time_str,
        "event": event,
        "session_id": session_id,
    }
    
    if tool_name:
        record["tool_name"] = tool_name
        
    if duration is not None:
        record["duration_seconds"] = duration

    # Extract tool inputs/outputs selectively (truncate large contents)
    tool_input = input_data.get("tool_input")
    if tool_input:
        cleaned_input = {}
        for k, v in tool_input.items():
            if isinstance(v, str) and len(v) > 200:
                cleaned_input[k] = v[:200] + "... [truncated]"
            else:
                cleaned_input[k] = v
        record["tool_input"] = cleaned_input

    tool_output = input_data.get("tool_output")
    if tool_output:
        cleaned_output = {}
        if isinstance(tool_output, dict):
            for k, v in tool_output.items():
                if isinstance(v, str) and len(v) > 200:
                    cleaned_output[k] = v[:200] + "... [truncated]"
                else:
                    cleaned_output[k] = v
        else:
            output_str = str(tool_output)
            if len(output_str) > 200:
                cleaned_output["result"] = output_str[:200] + "... [truncated]"
            else:
                cleaned_output["result"] = output_str
        record["tool_output"] = cleaned_output

    # Write to analytics.jsonl
    log_file = os.path.join(agents_dir, "analytics.jsonl")
    try:
        with open(log_file, "a") as f:
            f.write(json.dumps(record) + "\n")
    except Exception as e:
        log_error(f"Failed to append to analytics.jsonl: {e}")

    # Output valid empty JSON and decision (PreToolUse requires allow/deny/ask)
    out_payload = {}
    if event == "PreToolUse":
        out_payload = {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "allow"
            }
        }
    print(json.dumps(out_payload))
    sys.exit(0)

if __name__ == "__main__":
    main()
