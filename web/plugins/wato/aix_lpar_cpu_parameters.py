register_check_parameters(
    _("Operating System Resources"),    # Subgroup
    "lpar_cpu",                         # Checkgroup - must match the one defined check_info
    _("Aix LPAR CPU Usage Levels"),     # Title
    Dictionary(                         # Valuespec
        title = _("CPU Parameters"),
        optional_keys = ["avg_min","pct_usage_levels","num_usage_levels"],
        elements = [
            ( "pct_usage_levels",
                Tuple (
                    title = _("Levels for cpu usage in %"),
                    elements = [
                        Percentage(
                            title = _("Warning at:" ),
                            maxvalue = 1500.0,
                            unit = "percentage"
                        ),
                        Percentage(
                            title = _("Critical at:"),
                            maxvalue = 1500.0,
                            unit = "percentage"
                        ),
                    ]
                )
            ),
            ( "num_usage_levels",
                Tuple (
                    title = _("Levels for cpu usage in number of cores"),
                    elements = [
                        Percentage(
                            title = _("Warning at:" ),
                            maxvalue = 1500.0,
                            unit = "cores"
                        ),
                        Percentage(
                            title = _("Critical at:"),
                            maxvalue = 1500.0,
                            unit = "cores"
                        ),
                    ]
                )
            ),
            ( "avg_min",
                Integer(
                    title = _("Averaging on:"),
                    label = _("Averaging on"),
                    maxvalue = 144,
                    unit = "minutes",
                    default_value = 15
                )
            )
        ]
    ),
    None,                               # Itemspec
    "dict"                              # Matchtype: dict, all o list
)
