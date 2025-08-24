import "std::command" as command_api;

fn dialog_ui() {
    let ssid_to_connect = command_api::run_and_read("cat \"$XDG_RUNTIME_DIR/ewwii_ewifi_gui_template/connect_to.txt\"");

    return box(#{
        class: "password_window",
        dyn_id: "password_area_window",
        orientation: "v"
    }, [
        label(#{ 
            text: "Connecting to wifi...", 
            class: "password_heading",
            dyn_id: "connecting_to_wifi_heading"
        }),
        label(#{ 
            text: "Enter your Password:", 
            dyn_id: "password_label",
            halign: "start"
        }),
        input(#{ 
            class: "password_input",
            dyn_id: "user_password_enter_box",
            password: true,
            // the input widget exposes a `INPUT_VAL` env variable
            // to the command in onaccept and onchange properties.
            onaccept: "scripts/connect_wifi \"" + ssid_to_connect + "\" \"$INPUT_VAL\"",
        })
    ])
}
