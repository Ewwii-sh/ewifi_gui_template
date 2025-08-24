fn parse_network_info(net_info) {
    let networks = [];

    // loop over net_info and get each value that we need
    for line in net_info.split("\n") {
        if line != "" {
            let parts = line.split(":");

            // Ensure we have at least 3 fields
            let ssid    = if parts.len > 0 { parts[0] } else { "" };
            let signal  = if parts.len > 1 { parts[1] } else { "" };
            let security = if parts.len > 2 { parts[2] } else { "" };

            networks.push(#{
                ssid: ssid,
                signal: signal,
                security: security
            });
        }
    }

    networks
}

