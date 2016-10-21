/*
 * This file is part of budgie-desktop
 *
 * Copyright (C) 2015-2016 Solus Project
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 */

public class PlacesIndicatorWindow : Gtk.Popover {
    private GLib.VolumeMonitor volume_monitor;

    private MessageRevealer message_bar;
    private PlacesSection places_section;
    private Gtk.ListBox mounts_listbox;

    private GLib.GenericSet<string> places_list;

    private bool _show_places = true;
    private bool _show_drives = true;
    private bool _show_networks = true;

    private GLib.FileMonitor bookmarks_monitor;

    public bool show_places {
        get { return _show_places; }
        set {
            _show_places = value;
            toggle_section_visibility("places");
        }
    }

    public bool show_drives {
        get { return _show_drives; }
        set {
            _show_drives = value;
            toggle_section_visibility("drives");
        }
    }

    public bool show_networks {
        get { return _show_networks; }
        set {
            _show_networks = value;
            toggle_section_visibility("networks");
        }
    }

    private GLib.UserDirectory[] DEFAULT_DIRECTORIES = {
        GLib.UserDirectory.DOCUMENTS,
        GLib.UserDirectory.DOWNLOAD,
        GLib.UserDirectory.MUSIC,
        GLib.UserDirectory.PICTURES,
        GLib.UserDirectory.VIDEOS
    };

    public PlacesIndicatorWindow(Gtk.Widget? window_parent) {
        Object(relative_to: window_parent);
        set_size_request(280, 0);
        get_style_context().add_class("places-menu");

        places_list = new GLib.GenericSet<string>(str_hash, str_equal);

        Gtk.Box main_content = new Gtk.Box(Gtk.Orientation.VERTICAL, 5);
        add(main_content);

        message_bar = new MessageRevealer();
        message_bar.set_no_show_all(true);
        main_content.pack_start(message_bar, false, true, 0);

        places_section = new PlacesSection();
        main_content.pack_start(places_section, false, true, 0);

        mounts_listbox = new Gtk.ListBox();
        mounts_listbox.set_selection_mode(Gtk.SelectionMode.NONE);
        mounts_listbox.set_header_func(list_header_func);
        main_content.pack_start(mounts_listbox, true, true, 0);

        set_up_placeholder();

        volume_monitor = GLib.VolumeMonitor.get();

        connect_signals();

        main_content.show_all();
    }

    /**
     * Provide section headers in the mounts list
     * Ripped out of budgie-menu
     */
    private void list_header_func(Gtk.ListBoxRow? before, Gtk.ListBoxRow? after)
    {
        ListItem? child = null;
        string? prev = null;
        string? next = null;

        if (before != null) {
            child = before.get_child() as ListItem;
            prev = child.get_item_category();
        }

        if (after != null) {
            child = after.get_child() as ListItem;
            next = child.get_item_category();
        }

        if (before == null || after == null || prev != next) {
            Gtk.Label label = new Gtk.Label(GLib.Markup.printf_escaped("<span font=\"11\">%s</span>", prev));
            label.get_style_context().add_class("dim-label");
            label.halign = Gtk.Align.START;
            label.use_markup = true;
            before.set_header(label);
            label.margin = 3;
        } else {
            before.set_header(null);
        }
    }

    /*
     * Construct the listbox placeholder
     */
    private void set_up_placeholder()
    {
        Gtk.Box placeholder_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 6);
        placeholder_box.margin = 10;
        placeholder_box.set_halign(Gtk.Align.CENTER);
        placeholder_box.set_valign(Gtk.Align.CENTER);
        mounts_listbox.set_placeholder(placeholder_box);

        Gtk.Image placeholder_image = new Gtk.Image.from_icon_name(
            "drive-harddisk-symbolic", Gtk.IconSize.DIALOG);
        placeholder_image.pixel_size = 64;
        placeholder_box.pack_start(placeholder_image, false, false, 6);

        Gtk.Label placeholder_label = new Gtk.Label(
            "<span font=\"11\">%s</span>".printf(_("Nothing to display right now")));
        placeholder_label.use_markup = true;
        placeholder_box.pack_start(placeholder_label, false, false, 0);
        Gtk.Label placeholder_label1 = new Gtk.Label(
            @"<span font=\"10\">%s\n%s</span>".printf(_("Mount some drives"), _("Enable more sections")));
        placeholder_label1.use_markup = true;
        placeholder_label1.set_justify(Gtk.Justification.CENTER);
        placeholder_label1.get_style_context().add_class("dim-label");
        placeholder_box.pack_start(placeholder_label1, false, false, 0);

        placeholder_box.show_all();
    }

    /*
     * Returns a GLib.File for the bookmarks file location
     */
    private GLib.File get_bookmarks_file()
    {
        string path = GLib.Path.build_filename(GLib.Environment.get_user_config_dir(), "gtk-3.0", "bookmarks");
        return GLib.File.new_for_path(path);
    }

    /*
     * Sets up a file monitor for the bookmarks file and listens for changes
     */
    private void connect_bookmarks_monitor()
    {
        GLib.File bookmarks_file = get_bookmarks_file();
        if (!bookmarks_file.query_exists()) {
            return;
        }

        try {
            bookmarks_monitor = bookmarks_file.monitor_file(GLib.FileMonitorFlags.NONE, null);
            bookmarks_monitor.set_rate_limit(1000);

            // Refresh special directories (including the bookmarks) when the file changes
            bookmarks_monitor.changed.connect((src, dest, event)=> {
                if (event == GLib.FileMonitorEvent.CHANGES_DONE_HINT) {
                    refresh_special_dirs();
                }
            });
        } catch (GLib.IOError e) {
            warning(e.message);
        }
    }

    /*
     * Connect all the signals
     */
    private void connect_signals()
    {
        connect_bookmarks_monitor();
        volume_monitor.volume_added.connect(refresh_mounts);
        volume_monitor.volume_removed.connect(refresh_mounts);
        volume_monitor.drive_connected.connect(refresh_mounts);
        volume_monitor.drive_disconnected.connect(refresh_mounts);
        volume_monitor.mount_added.connect(refresh_mounts);
        volume_monitor.mount_removed.connect(refresh_mounts);
    }

    /*
     * Figures out if we should expand the places section
     * (Expand if it's the only enabled section)
     */
    private void check_expand()
    {
        if (((!show_drives && !show_networks) || mounts_listbox.get_children().length() == 0) && show_places) {
            mounts_listbox.set_no_show_all(true);
            mounts_listbox.hide();
            places_section.reveal(true);
        } else if (show_drives || show_networks) {
            mounts_listbox.set_no_show_all(false);
            mounts_listbox.show();
            // Only contract the places section if it wasn't previously expanded by the user
            if (places_section.expanded_by == "code") {
                places_section.reveal(false);
            }
        } else {
            mounts_listbox.set_no_show_all(false);
            mounts_listbox.show();
        }
    }

    /*
     * Figures out which stuff should be visible
     * Called when a setting changes
     */
    private void toggle_section_visibility(string section)
    {
        switch (section) {
            case "places":
                if (show_places) {
                    places_section.show();
                    // Stop it from re-appearing when opening the popover
                    places_section.set_no_show_all(false);
                    refresh_special_dirs();
                } else {
                    places_section.set_no_show_all(true);
                    places_section.hide();
                }
                break;
            case "drives":
            case "networks":
                refresh_mounts();
                break;
            default:
                break;
        }

        // Always retract the places section revealer when enabling/disabling sections
        places_section.reveal(false);
        check_expand();
    }

    /*
     * Reads the bookmarks file and adds all of the bookmarks to the view
     */
    private void refresh_bookmarks()
    {
        GLib.File bookmarks_file = get_bookmarks_file();
        if (!bookmarks_file.query_exists()) {
            return;
        }
        try {
            var dis = new GLib.DataInputStream(bookmarks_file.read());
            string line;
            while ((line = dis.read_line(null)) != null) {
                add_place(line, "bookmark");
            }
        } catch (GLib.Error e) {
            warning(e.message);
        }
    }

    /*
     * Adds special dirs to the view
     */
    private void refresh_special_dirs()
    {
        places_list.remove_all();
        places_section.clear();

        // Add home dir
        string path = GLib.Environment.get_home_dir();
        add_place(@"file://$path", "place");

        foreach (var special_dir in DEFAULT_DIRECTORIES) {
            path = GLib.Environment.get_user_special_dir(special_dir);
            add_place(@"file://$path", "place");
        }

        refresh_bookmarks();
    }

    /*
     * Check if a mount is interesting to us
     */
    private bool is_interesting(GLib.Mount? mount)
    {
        if (mount.is_shadowed()) {
            return false;
        }
        return true;
    }

    /*
     * Finds all relevant mounts and adds them to the view
     */
    private void refresh_mounts()
    {
        foreach (Gtk.Widget item in mounts_listbox.get_children()) {
            item.destroy();
        }

        // Add volumes connected with a drive
        foreach (GLib.Drive drive in volume_monitor.get_connected_drives()) {
            foreach (GLib.Volume volume in drive.get_volumes()) {
                GLib.Mount mount = volume.get_mount();
                if (mount == null) {
                    add_volume(volume);
                } else {
                    add_mount(mount, volume.get_identifier("class"));
                }
            }
        }

        // Add volumes not connected with a drive
        foreach (GLib.Volume volume in volume_monitor.get_volumes()) {
            if (volume.get_drive() != null) {
                continue;
            }
            GLib.Mount mount = volume.get_mount();
            if (mount == null) {
                add_volume(volume);
            } else {
                add_mount(mount, volume.get_identifier("class"));
            }
        }

        get_child().show_all();
        check_expand();
    }

    /*
     * Adds a volume to the view
     */
    private void add_volume(GLib.Volume volume)
    {
        if ((volume.get_identifier("class") == "network" && !show_networks) ||
            (volume.get_identifier("class") == "device" && !show_drives))
        {
            return;
        }

        VolumeItem volume_item = new VolumeItem(volume);
        mounts_listbox.add(volume_item);
        volume_item.get_parent().set_can_focus(false);

        volume_item.send_message.connect((message_content, message_type)=> {
            message_bar.set_content(message_content, message_type);
        });
    }

    /*
     * Adds a mount to the view
     */
    private void add_mount(GLib.Mount mount, string? class)
    {
        if ((class == "network" && !show_networks) || (class == "device" && !show_drives)) {
            return;
        }

        if (!mount.can_unmount() && !mount.can_eject()) {
            return;
        }

        if (!is_interesting(mount)) {
            return;
        }

        MountItem mount_item = new MountItem(mount, class);
        mounts_listbox.add(mount_item);
        mount_item.get_parent().set_can_focus(false);

        mount_item.send_message.connect((message_content, message_type)=> {
            message_bar.set_content(message_content, message_type);
        });
    }

    /*
     * Add a place item to the places view
     */
    private void add_place(string path, string class)
    {
        string unescaped_path = GLib.Uri.unescape_string(path);
        if (places_list.contains(unescaped_path)) {
            return;
        }

        /*
         * Check if $path is "file:/// /" because nautilus saves the
         * root directory as that for some (stupid, I'm sure) reason.
        */
        if (path == "file:/// /") {
            path = "file:///";
        }

        GLib.File file = GLib.File.new_for_uri(path);
        PlaceItem place_item = new PlaceItem(file, "place");
        places_list.add(unescaped_path);
        places_section.add_item(place_item);
    }
}