# mint a junifer oauth2 token for the active apix domain (junifer-uat / junifer-prod)
# and add it to apix config, using JUNIFER_{ENV}_CLIENT_ID / JUNIFER_{ENV}_CLIENT_SECRET
function auth_junifer
    set apix_config_path ~/.apix.yaml
    set -l domain (yq -r '.active' "$apix_config_path")

    if test -z "$domain"; or test "$domain" = "null"
        echo "No active apix domain set - see `apix list` / `apix switch`"
        return 1
    end

    if not contains -- $domain junifer-uat junifer-prod
        echo "Active apix domain '$domain' is not a junifer domain (expected junifer-uat or junifer-prod)"
        return 1
    end

    set -l env_suffix (string replace 'junifer-' '' $domain | string upper)
    set -l client_id_var JUNIFER_{$env_suffix}_CLIENT_ID
    set -l client_secret_var JUNIFER_{$env_suffix}_CLIENT_SECRET

    if not set -q $client_id_var; or not set -q $client_secret_var
        echo "$client_id_var / $client_secret_var not set - export both before running auth_junifer"
        return 1
    end

    set -l client_id $$client_id_var
    set -l client_secret $$client_secret_var

    set -l token (curl --location --request POST 'https://uk.id.gentrackcloud.com/v1/token' \
        --user "$client_id:$client_secret" \
        --header 'Content-Type: application/x-www-form-urlencoded' \
        --data-urlencode 'grant_type=client_credentials' | jq -r '.access_token')

    if test -z "$token"; or test "$token" = "null"
        echo "Failed to obtain junifer token for domain '$domain'"
        return 1
    end

    env DOMAIN="$domain" TOKEN="$token" yq -i \
        '.domains[strenv(DOMAIN)].headers.Authorization = "Bearer " + strenv(TOKEN)' \
        "$apix_config_path"

    echo "Token set for apix domain '$domain'"
end
