gnome = import('gnome')

local_vapis = []
local_vapidir = meson.current_source_dir()
built_vapidir = meson.current_build_dir()

gir = dependency('gobject-introspection-1.0')
gir_dir = gir.get_pkgconfig_variable('girdir')

polkit_gobject_vapi = gnome.generate_vapi('polkit-gobject-1',
    install: false,
    sources: ['polkit-gobject-1-custom.vala', join_paths(gir_dir, 'Polkit-1.0.gir')],
    packages: ['gio-2.0', 'gio-unix-2.0'],
    vapi_dirs: local_vapidir,
    metadata_dirs: local_vapidir,
)

polkit_agent_vapi = gnome.generate_vapi('polkit-agent-1',
    install: false,
    sources: ['polkit-agent-1-custom.vala', join_paths(gir_dir, 'PolkitAgent-1.0.gir')],
    packages: ['gio-2.0', 'gio-unix-2.0', polkit_gobject_vapi],
    vapi_dirs: local_vapidir,
    metadata_dirs: local_vapidir,
)

mutter_gir_dir = dep_mutter.get_pkgconfig_variable('typelibdir')
mutter_api = dep_mutter.get_pkgconfig_variable('apiversion')

mutter_cogl_vapi = gnome.generate_vapi('mutter-cogl-' + mutter_api,
    install: false,
    sources: [
        'mutter-cogl-'+mutter_api+'-custom.vala',
        join_paths(mutter_gir_dir, 'Cogl-'+mutter_api+'.gir')
    ],
    packages: ['pango'],
    vapi_dirs: local_vapidir,
    metadata_dirs: local_vapidir,
    gir_dirs: mutter_gir_dir,
)

mutter_clutter_vapi = gnome.generate_vapi('mutter-clutter-' + mutter_api,
    install: false,
    sources: [
        'mutter-clutter-'+mutter_api+'-custom.vala',
        join_paths(mutter_gir_dir, 'Clutter-'+mutter_api+'.gir')
    ],
    packages: [
        'atk',
        'cairo',
        'json-glib-1.0',
        mutter_cogl_vapi,
        'pango'
    ],
    vapi_dirs: local_vapidir,
    metadata_dirs: local_vapidir,
    gir_dirs: mutter_gir_dir,
)

# We need to create an empty file matching the expected vapi name
libmutter_fake_vapi = custom_target('libmutter-fake-vapi',
    command: ['echo'],
    output: 'libmutter-' + mutter_api + '.vapi',
    capture: true,
)

libmutter_vapi = gnome.generate_vapi('mutter-' + mutter_api,
    install: false,
    sources: [
        join_paths(mutter_gir_dir, 'Meta-'+mutter_api+'.gir')
    ],
    packages: [
        'gdk-3.0',
        'gdk-pixbuf-2.0',
        'gtk+-3.0',
        'mutter-clutter-4',
        'mutter-cogl-4',
        'x11',
        'xfixes-4.0',
        'json-glib-1.0',
        mutter_clutter_vapi
    ],
    vapi_dirs: local_vapidir,
    metadata_dirs: local_vapidir,
    gir_dirs: mutter_gir_dir,
)
