//! Note: This example only works on Linux systems that has `nmcli` installed.

// builtin wifi api for handling connection, enabling/disabling of adapter
// checking currently connected network and more...
import "api::wifi" as wifi_api;
import "helpers/net_parser" as parser;
import "psswd_dialog" as psswd_dialog;

fn user_interface(net_info) {
    let networks = parser::parse_network_info(net_info);
    let current_connection = wifi_api::current_connection_linux();

    // A rhai closure.
    // the code inside `{}` gets executed and the result
    // is applied to the `load_network_labels` variable.
    let load_network_labels = {
        let contents = [];
        for network in networks {
            // only add contants if network is not empty
            if network.ssid != "" {
                let children = [
                    label(#{ 
                        text: network.ssid, 
                        dyn_id: "net_label_" + network.ssid,
                    })
                ];

                if current_connection.ssid == network.ssid {
                    children.push(
                        eventbox(#{
                            cursor: "pointer",
                            dyn_id: "net_disconn_btn_holder_" + network.ssid
                        }, [
                            button(#{ 
                                label: "Disconnect",
                                class: "disconn_button",
                                onclick: "scripts/disconnect_wifi",
                                dyn_id: "net_disconn_btn_" + network.ssid 
                            })
                        ])
                    );
                } else {
                    children.push(
                        eventbox(#{
                            cursor: "pointer",
                            dyn_id: "net_conn_btn_holder_" + network.ssid
                        }, [ 
                            button(#{ 
                                label: "Connect", 
                                class: "conn_button", 
                                onclick: "scripts/show_password_box \"" + network.ssid + "\"",
                                dyn_id: "net_conn_btn_" + network.ssid,
                                timeout: "20s"
                            })
                        ])
                    );
                }

                contents.push(
                    box(#{
                        orientation: "h",
                        dyn_id: "net_conn_box_" + network.ssid,
                        class: "net_conn_box",
                    }, children)
                );
            }
        }
        // if a fn/closure ends with an expression that doesnt end in `;`
        // it is equivalent to a return. 
        contents
    };

    let generated_lbls = [];

    // append each network label manually
    for lbl in load_network_labels {
        generated_lbls.push(lbl);
    }

    // initial contents
    let widget_contents = [ 
        label(#{
            text: "Connections", 
            class: "conn_text",
            dyn_id: "conn_heading_id",
        }),

        scroll(#{
            dyn_id: "global_scroll_box",
            propagate_natural_height: true
        }, [ 
            box(#{
                orientation: "v",
                dyn_id: "global_scroll_box_child_container",
            }, generated_lbls),
        ]),
    ];

    // doesnt end in `;` so it is returned.
    box(#{
        orientation: "v",
        valign: "start",
        dyn_id: "root_child",
        space_evenly: false
    }, widget_contents);
}

enter([
    // dont rely on `wifi_api::scan()` as it only runs once
    poll("net_info", #{
        cmd: "nmcli dev wifi rescan && nmcli -t -f SSID,SIGNAL,SECURITY dev wifi",
        interval: "5s",
        initial: ""
    }),

    defwindow("wifi_gui", #{
        monitor: 0,
        windowtype: "normal",
        geometry: #{
            x: "0px",
            y: "0px",
            width: "600px",
            height: "400px",
            anchor: "center" 
        },
    }, user_interface(net_info)),

    defwindow("password_dialog", #{
        monitor: 0,
        windowtype: "dialog",
        geometry: #{
            x: "0px",
            y: "0px",
            width: "100px",
            height: "100px",
            anchor: "center"
        },
    }, psswd_dialog::dialog_ui()),
]);

// -- ewwii bin helper fn -- //
fn disconnect_wifi() {
    wifi_api::disconnect();
}

fn connect_to_wifi(ssid, password) {
    import "api::wifi" as reimported_wifi;
    reimported_wifi::connect(ssid, password);
}
