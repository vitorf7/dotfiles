# grpc-test: interactively test a local gRPC API via evans + gum.
#
# Usage: grpc-test [--host HOST] [--port PORT]
#   Defaults: --host localhost --port 8090 (the api service's internal gRPC
#   port per docker-compose.yml). If your local mapping differs (check
#   SERVICE_API_GRPC_EXTERNAL_PORT in .env.local), pass --port explicitly.
#
# `evans cli list <service> -o json` returns:
#   {"methods": [{"name", "fully_qualified_name", "request_type", "response_type"}, ...]}
# __grpc_test_pick_method returns each method's fully_qualified_name directly
# (e.g. energy_entities.service.api.v1.API.CanPerformHomeMove), which is
# already the exact dot-separated target `evans cli call` expects.

function __grpc_test_error
    gum style --border rounded --border-foreground 196 --foreground 196 \
        --padding "1 2" --margin "1 0" -- $argv
end

function __grpc_test_preflight
    set -l missing
    for bin in gum evans uw jq
        type -q $bin
        or set -a missing $bin
    end
    if test (count $missing) -gt 0
        __grpc_test_error "Missing required tool(s): "(string join ", " $missing)"\nInstall them and try again."
        return 1
    end
end

function __grpc_test_login
    set -l token (gum spin --title "Authenticating..." --show-output -- \
        uw iam login --quiet --print | string collect | string trim)

    if test -z "$token"
        __grpc_test_error "Login did not return a token. Check 'uw iam login --quiet --print --copy' works standalone."
        return 1
    end

    echo $token
end

function __grpc_test_pick_service
    set -l host $argv[1]
    set -l port $argv[2]
    set -l token $argv[3]

    set -l services (gum spin --title "Listing services..." --show-output -- \
        evans --reflection --host $host --port $port --header "Authorization=Bearer $token" cli list \
        | string collect)
    # $status here would reflect `string collect`, not evans/gum spin — use pipestatus.
    set -l list_status $pipestatus[1]

    if test $list_status -ne 0
        __grpc_test_error "Failed to list services (exit $list_status). Is the server reachable at $host:$port and does it support reflection?\n$services"
        return 1
    end

    set -l chosen (echo $services | gum choose --header "Select a service")
    if test -z "$chosen"
        return 1
    end
    echo $chosen
end

function __grpc_test_pick_method
    set -l host $argv[1]
    set -l port $argv[2]
    set -l token $argv[3]
    set -l service $argv[4]

    set -l raw_json (gum spin --title "Listing methods for $service..." --show-output -- \
        evans --reflection --host $host --port $port --header "Authorization=Bearer $token" cli list $service -o json \
        | string collect)
    # $status here would reflect `string collect`, not evans/gum spin — use pipestatus.
    set -l list_status $pipestatus[1]

    if test $list_status -ne 0
        __grpc_test_error "Failed to list methods for $service (exit $list_status).\n$raw_json"
        return 1
    end

    set -l methods (echo $raw_json | jq -r '.methods[]?.fully_qualified_name // empty' 2>/dev/null | string collect)

    if test -z "$methods"
        __grpc_test_error "Could not extract method names from evans JSON output — the jq filter\nin __grpc_test_pick_method likely needs adjusting to this schema. Raw output:\n$raw_json"
        return 1
    end

    set -l chosen (echo $methods | gum filter --fuzzy --header "Search methods for $service" --placeholder "Type to filter...")
    if test -z "$chosen"
        return 1
    end
    echo $chosen
end

function __grpc_test_call
    set -l host $argv[1]
    set -l port $argv[2]
    set -l token $argv[3]
    set -l fqmn $argv[4]
    set -l body $argv[5]

    echo $body | gum spin --title "Calling $fqmn..." --show-output -- \
        evans --reflection --host $host --port $port --header "Authorization=Bearer $token" cli call -o json $fqmn
end

function grpc-test
    argparse 'h/host=' 'p/port=' -- $argv
    or return 1

    __grpc_test_preflight
    or return 1

    set -q _flag_host
    and set -l host $_flag_host
    or set -l host localhost

    set -q _flag_port
    and set -l port $_flag_port
    or set -l port 8090

    gum style --border rounded --border-foreground 212 --padding "0 2" \
        "gRPC Test — $host:$port"

    set -l headerToken (__grpc_test_login)
    or return 1

    while true
        set -l service (__grpc_test_pick_service $host $port $headerToken)
        or continue

        set -l fqmn (__grpc_test_pick_method $host $port $headerToken $service)
        or continue

        set -l rawRequestMessage (gum write \
            --header "Request body for $fqmn (JSON)" \
            --placeholder '{"key": "value"}' \
            | string collect)

        set -l response (__grpc_test_call $host $port $headerToken $fqmn $rawRequestMessage)
        set -l call_status $status

        if test $call_status -ne 0
            __grpc_test_error "evans call failed (exit $call_status):\n$response"
        else
            gum style --border rounded --border-foreground 212 --padding "1 2" --margin "1 0" \
                (echo $response | jq . 2>/dev/null; or echo $response)
        end

        set -l next (gum choose "Run another request" "Re-authenticate" "Quit")
        switch "$next"
            case "Run another request"
                continue
            case "Re-authenticate"
                set headerToken (__grpc_test_login)
                or return 1
                continue
            case "*"
                break
        end
    end
end
